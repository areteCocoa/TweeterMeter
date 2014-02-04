//
//  TMTerm.m
//  TweeterMeter
//
//  Created by Thomas Ring on 12/23/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import "TMTerm.h"
#import "Tweet.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TMTerm()

@property (strong, nonatomic) Term *managedTerm;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSEntityDescription *entity;
@property (strong, nonatomic) NSPersistentStoreCoordinator *store;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation TMTerm

@synthesize context = _context, managedTerm = _managedTerm;

- (id)initTermWithManagedTerm: (Term *)managedTerm withContext:(NSManagedObjectContext *)context {
    self.entity = managedTerm.entity;
    self.store = context.persistentStoreCoordinator;
    
    self.name = managedTerm.name;
    
    self.tweets = [NSMutableSet set];
    self.tweets = [managedTerm.tweets mutableCopy];
    
    self.popularWords = [NSMutableDictionary dictionary];
    self.popularTags =  [NSMutableDictionary dictionary];
    self.popularUsers = [NSMutableDictionary dictionary];
    
    self.context = [[NSManagedObjectContext alloc] init];
    [self.context setPersistentStoreCoordinator:context.persistentStoreCoordinator];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", self.name];
    [fetch setPredicate:predicate];
    [fetch setEntity:managedTerm.entity];
    
    NSError *error;
    NSArray *array = [self.context executeFetchRequest:fetch error:&error];
    if (!error) {
        if ([[array firstObject] isKindOfClass:[Term class]]) {
            self.managedTerm = [array firstObject];
        }
    } else {
        NSLog(@"Error: %@", error);
    }
    
    self.frequencyWords = [NSMutableDictionary dictionary];
    for (FrequencyWord* word in managedTerm.frequencyWords) {
        [self.frequencyWords setObject:word forKey:word.name];
        
        [self.popularWords setObject:word.frequency forKey:word.name];
    }
    
    self.frequencyTags = [NSMutableDictionary dictionary];
    for (FrequencyTag* tag in managedTerm.frequencyTags) {
        [self.frequencyTags setObject:tag forKey:tag.name];
        
        [self.popularTags setObject:tag.frequency forKey:tag.name];
    }
    
    self.frequencyUsers = [NSMutableDictionary dictionary];
    for (FrequencyUser* user in managedTerm.frequencyUsers) {
        [self.frequencyUsers setObject:user forKey:user.name];
        
        [self.popularUsers setObject:user.frequency forKey:user.name];
    }
    
    NSLog(@"Tweets loaded: %lu", (unsigned long)self.managedTerm.tweets.count);
    
    [self fetchNumberOfTweets:1 withContext:self.context];
    
    return self;
}

- (void)countString: (NSString *)word {
    NSLog(@"%@", word);
    char firstCharacter = [word characterAtIndex:0];
    NSMutableDictionary *dictionary;
    if (firstCharacter == '#') {
        dictionary = self.popularTags;
    } else if (firstCharacter == '@') {
        dictionary = self.popularUsers;
    } else {
        dictionary = self.popularWords;
    }
    
    NSNumber *oldValue = [dictionary objectForKey:word];
    if (!oldValue) {
        [dictionary setObject:@1 forKey:word];
    } else {
        [dictionary setObject:@([oldValue intValue] + 1) forKey:word];
    }
}

#pragma mark Twitter Methods

- (void)fetchNumberOfTweets:(int)number withContext:(NSManagedObjectContext *)context {
    ACAccountStore *store = [[ACAccountStore alloc] init];
    if ([SLComposeViewController
         isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [store accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [store
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [store accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                 NSDictionary *params = @{@"q" : _name,
                                          @"result_type" : @"recent",
                                          @"count" : [NSString stringWithFormat:@"%i", number]};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              NSDictionary *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  // create tweets from data
                                  id statuses = [timelineData valueForKey:@"statuses"];
                                  if ([statuses isKindOfClass:[NSArray class]]) {
                                      for (NSDictionary *dictionary in statuses) {
                                          [self addTweet:dictionary inContext:context];
                                      }
                                      [self.delegate tweetsDidUpdate];
                                      if ([self saveContext:context]) {
                                          [self.delegate tweetsDidSave];
                                      }
                                  }
                                   
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %ld",
                                    (long)urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
}

- (void)addTweet: (NSDictionary *)rawTweet inContext: (NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:context];
    Tweet *tweet;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text == %@", [rawTweet objectForKey:@"text"]];
    NSFetchRequest* fetch = [[NSFetchRequest alloc] init];
    [fetch setPredicate:predicate];
    [fetch setEntity:entity];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:fetch error:&error];
    if (error) {
        NSLog(@"Error! %@", error);
    } else if ([array firstObject]) {
        id object = [array firstObject];
        if ([object isKindOfClass:[Tweet class]]) {
            NSLog(@"Object already exists! %@", [array firstObject]);
            tweet = object;
        }
    } else {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        tweet.user = [[rawTweet valueForKey:@"user"] valueForKey:@"name"];
        tweet.text = [rawTweet valueForKey:@"text"];
        tweet.term = self.managedTerm;
    }
    
    // Analyze Tweet
    [self analyzeTweet:tweet];
    
    [self.tweets addObject:tweet];
    [self.managedTerm addTweetsObject:tweet];
}

// Goes through tweet looking for certain words
- (void)analyzeTweet: (Tweet *)tweet {
    NSString *text = tweet.text;
    NSMutableArray *uneditedWords = (NSMutableArray *)[text componentsSeparatedByString:@" "];
    if ([uneditedWords containsObject:@""]) {
        [uneditedWords removeObjectIdenticalTo:@""];
    }
    NSArray *words = [NSArray arrayWithArray:uneditedWords];
    
    // NSNumber *old;
    NSString *wordString;
    FrequencyWord *frequencyWord;
    
    for (NSUInteger index = 0; index < words.count; index++) {
        wordString = words[index];
        if (wordString.length != 0) {
            frequencyWord = [self getFrequencyWordWithName:wordString];
            frequencyWord.frequency = @([frequencyWord.frequency floatValue] + 1);
            
            [self countString:frequencyWord.name];
        }
    }
    
    NSLog(@"Words: %@, Users: %@, Hashtags: %@", self.popularWords, self.popularUsers, self.popularTags);
}

- (FrequencyObject *)getFrequencyObjectWithName: (NSString *)name {
    if ([name characterAtIndex:0] == '#') {
        FrequencyTag *tag;
        return tag;
    } else if ([name characterAtIndex:0] == '@') {
        FrequencyUser *user;
        return user;
    } else {
        FrequencyWord *word;
        return word;
    }
}

- (FrequencyWord *)getFrequencyWordWithName: (NSString *)name {
    FrequencyWord *word;
    
    // Access it without going to the database
    NSSet *set = [self.managedTerm.frequencyWords objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        FrequencyWord *termWord = (FrequencyWord *)obj;
        
        return (termWord.name == name);
    }];
    word = [set anyObject];
    if (word) {
        return word;
    } else if (set.count <= 0) {
        // Create new FrequencyWord
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FrequencyWord" inManagedObjectContext:self.context];
        
        Word *parentWord = [Word fetchWordWithName:name inContext:self.context];
        
        word = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.context];
        word.name = name;
        word.frequency = @0;
        Term *term = self.managedTerm;
        word.term = term;
        
        word.parentWord = parentWord;
        [parentWord addFrequencyObjectObject:word];
        
        [self saveContext:self.context];
    } else if (set.count > 1) {
        NSLog(@"Objects retreived is greater than expected: %lu objects", (unsigned long)set.count);
    }
    
    return word;
}

- (BOOL)saveContext: (NSManagedObjectContext *)context {
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
        abort();
    } else if (!context) {
        NSLog(@"context nil");
    }
    return YES;
}
 
@end
