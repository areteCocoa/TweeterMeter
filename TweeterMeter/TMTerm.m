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

@end

@implementation TMTerm

- (id)initTermWithManagedTerm: (Term *)managedTerm withContext:(NSManagedObjectContext *)context {
    self.managedTerm = managedTerm;
    self.context = [[NSManagedObjectContext alloc] init];
    [self.context setPersistentStoreCoordinator:[context persistentStoreCoordinator]];
    
    if (self.managedTerm.managedObjectContext != self.context) {
        NSEntityDescription *entity = managedTerm.entity;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", managedTerm.name];
        request.predicate = predicate;
        
        NSError *error;
        NSArray *results = [self.context executeFetchRequest:request error:&error];
        if (!error && results && results.count == 1 && [[results firstObject] isKindOfClass:[Term class]]) {
            self.managedTerm = [results firstObject];
        } else{
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
    
    self.name = managedTerm.name;
    
    self.tweets = [NSMutableSet set];
    self.tweets = [managedTerm.tweets mutableCopy];
    
    [self fetchNumberOfTweets:100];
    
    self.popularWords = [NSMutableDictionary dictionary];
    self.popularTags =  [NSMutableDictionary dictionary];
    self.popularUsers = [NSMutableDictionary dictionary];
    
    NSNumber *oldValue;
    
    self.frequencyWords = [NSMutableDictionary dictionary];
    for (FrequencyWord* word in managedTerm.frequencyWords) {
        [self.frequencyWords setObject:word forKey:word.name];
        
        oldValue = [self.popularWords objectForKey:word.name];
        if (!oldValue) {
            [self.popularWords setObject:@1 forKey:word.name];
        } else {
            [self.popularWords setObject:@([oldValue intValue] + 1) forKey:word.name];
        }
    }
    
    self.frequencyTags = [NSMutableDictionary dictionary];
    for (FrequencyWord* tag in managedTerm.frequencyTags) {
        [self.frequencyTags setObject:tag forKey:tag.name];
        
        oldValue = [self.popularWords objectForKey:tag.name];
        if (!oldValue) {
            [self.popularWords setObject:@1 forKey:tag.name];
        } else {
            [self.popularWords setObject:@([oldValue intValue] + 1) forKey:tag.name];
        }
    }
    
    self.frequencyUsers = [NSMutableDictionary dictionary];
    for (FrequencyWord* user in managedTerm.frequencyUsers) {
        [self.frequencyUsers setObject:user forKey:user.name];
        
        oldValue = [self.popularWords objectForKey:user.name];
        if (!oldValue) {
            [self.popularWords setObject:@1 forKey:user.name];
        } else {
            [self.popularWords setObject:@([oldValue intValue] + 1) forKey:user.name];
        }
    }
    
    // NSLog(@"Tweets loaded: %lu", (unsigned long)term.tweets.count);
    
    return self;
}

/*
+ (TMTerm *) termFromManagedTerm:(Term *)managedTerm withContext:(NSManagedObjectContext *)context {
    TMTerm *term = [[TMTerm alloc] init];
    term.managedTerm = managedTerm;
    term.context = [[NSManagedObjectContext alloc] init];
    [term.context setPersistentStoreCoordinator:[context persistentStoreCoordinator]];
    
    if (term.managedTerm.managedObjectContext != term.context) {
        NSEntityDescription *entity = managedTerm.entity;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = entity;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", managedTerm.name];
        request.predicate = predicate;
        
        NSError *error;
        NSArray *results = [term.context executeFetchRequest:request error:&error];
        if (!error && results && results.count == 1 && [[results firstObject] isKindOfClass:[Term class]]) {
            term.managedTerm = [results firstObject];
        } else{
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
    
    term.name = managedTerm.name;
    
    term.tweets = [NSMutableSet set];
    term.tweets = [managedTerm.tweets mutableCopy];
    
    [term fetchNumberOfTweets:100];
    
    term.popularWords = [NSMutableDictionary dictionary];
    term.popularTags =  [NSMutableDictionary dictionary];
    term.popularUsers = [NSMutableDictionary dictionary];
    
    NSNumber *oldValue;
    
    term.frequencyWords = [NSMutableDictionary dictionary];
    for (FrequencyWord* word in managedTerm.frequencyWords) {
        [term.frequencyWords setObject:word forKey:word.name];
        
        oldValue = [term.popularWords objectForKey:word.name];
        if (!oldValue) {
            [term.popularWords setObject:@1 forKey:word.name];
        } else {
            [term.popularWords setObject:@([oldValue intValue] + 1) forKey:word.name];
        }
    }
    
    term.frequencyTags = [NSMutableDictionary dictionary];
    for (FrequencyWord* tag in managedTerm.frequencyTags) {
        [term.frequencyTags setObject:tag forKey:tag.name];
        
        oldValue = [term.popularWords objectForKey:tag.name];
        if (!oldValue) {
            [term.popularWords setObject:@1 forKey:tag.name];
        } else {
            [term.popularWords setObject:@([oldValue intValue] + 1) forKey:tag.name];
        }
    }
    
    term.frequencyUsers = [NSMutableDictionary dictionary];
    for (FrequencyWord* user in managedTerm.frequencyUsers) {
        [term.frequencyUsers setObject:user forKey:user.name];
        
        oldValue = [term.popularWords objectForKey:user.name];
        if (!oldValue) {
            [term.popularWords setObject:@1 forKey:user.name];
        } else {
            [term.popularWords setObject:@([oldValue intValue] + 1) forKey:user.name];
        }
    }
    
    // NSLog(@"Tweets loaded: %lu", (unsigned long)term.tweets.count);
    
    return term;
}
 */

- (void)countDictionary: (NSMutableDictionary *)dictionary {
    // NSNumber *oldValue;
    for (FrequencyWord *word in dictionary) {
        //
    }
}

#pragma mark Twitter Methods

- (void)fetchNumberOfTweets:(int)number {
    
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
                                          [self addTweet:dictionary];
                                      }
                                      [self.delegate tweetsDidUpdate];
                                      if ([self save]) {
                                          [self.delegate tweetsDidSave];
                                      }
                                  }
                                  
                                  /*
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      // Do something on the main thread
                                  });
                                   */
                                   
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
    
    [self save];
}

- (void)setName:(NSString *)name {
    _name = name;
    _managedTerm.name = name;
}

- (void)addTweet: (NSDictionary *)rawTweet {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:_context];
    
    Tweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:_context];
    tweet.user = [[rawTweet valueForKey:@"user"] valueForKey:@"name"];
    tweet.text = [rawTweet valueForKey:@"text"];
    tweet.term = self.managedTerm;
    
    // Analyze Tweet
    [self analyzeTweet:tweet];
    
    [self.tweets addObject:tweet];
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
            
            /*
            if ([wordString characterAtIndex:0] == '#') {
                old = [self.popularTags objectForKey:wordString];
                if (old) {
                    [self.popularTags setObject:@([old intValue]+1) forKey:wordString];
                } else {
                    [self.popularTags setObject:@1 forKey:wordString];
                }
            } else if ([wordString characterAtIndex:0] == '@') {
                old = [self.popularUsers objectForKey:wordString];
                if (old) {
                    [self.popularUsers setObject:@([old intValue]+1) forKey:wordString];
                } else {
                    [self.popularUsers setObject:@1 forKey:wordString];
                }
            } else {
                old = [self.popularWords objectForKey:wordString];
                if (old) {
                    [self.popularWords setObject:@([old intValue]+1) forKey:wordString];
                } else {
                    [self.popularWords setObject:@1 forKey:wordString];
                }
            }
             */
        }
    }
    
    // NSLog(@"Words: %@, Users: %@, Hashtags: %@", self.popularWords, self.popularUsers, self.popularTags);
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
        word.term = self.managedTerm;
        
        word.parentWord = parentWord;
        [parentWord addFrequencyObjectObject:word];
        
    } else if (set.count > 1) {
        NSLog(@"Objects retreived is greater than expected: %lu objects", (unsigned long)set.count);
    }
    
    return word;
}

- (BOOL)save {
    // Save the context.
    NSError *error = nil;
    if (![_context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
        abort();
    }
    return YES;
}

@end
