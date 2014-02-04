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
@property (strong, nonatomic, readonly) NSManagedObjectContext *context;

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
    self.managedTerm = managedTerm;
    
    self.name = managedTerm.name;
    
    self.tweets = [NSMutableSet set];
    self.tweets = [managedTerm.tweets mutableCopy];
    
    self.popularWords = [NSMutableDictionary dictionary];
    self.popularTags =  [NSMutableDictionary dictionary];
    self.popularUsers = [NSMutableDictionary dictionary];
    
    self.frequencyWords = [NSMutableDictionary dictionary];
    for (FrequencyWord* word in managedTerm.frequencyWords) {
        [self.frequencyWords setObject:word forKey:word.name];
        
        [self countString:word.name];
    }
    
    self.frequencyTags = [NSMutableDictionary dictionary];
    for (FrequencyTag* tag in managedTerm.frequencyTags) {
        [self.frequencyTags setObject:tag forKey:tag.name];
        
        [self countString:tag.name];
    }
    
    self.frequencyUsers = [NSMutableDictionary dictionary];
    for (FrequencyUser* user in managedTerm.frequencyUsers) {
        [self.frequencyUsers setObject:user forKey:user.name];
        
        [self countString:user.name];
    }
    
    NSLog(@"Tweets loaded: %lu", (unsigned long)self.managedTerm.tweets.count);
    
    // [self startAutoFetchingTweets];
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
    [newContext setPersistentStoreCoordinator:self.store];
    [self fetchNumberOfTweets:100 withContext:newContext];
    
    return self;
}

/*
- (void)startAutoFetchingTweets {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(addFetchOperation) userInfo:nil repeats:YES];
}

- (void)addFetchOperation {
    if (!self.queue) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchNumberOfTweets:withContext:) object:@[];
    [self.queue addOperation:operation];
}

- (void)stopAutoFetchingTweets {
    [self.timer invalidate];
}
 */

- (NSManagedObjectContext *)context {
    // Create new context
    if (!_context) {
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:self.store];
    }
    
    return _context;
}

- (Term *)managedTerm {
    return _managedTerm;
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
    
    Tweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    tweet.user = [[rawTweet valueForKey:@"user"] valueForKey:@"name"];
    tweet.text = [rawTweet valueForKey:@"text"];
    tweet.term = [self getTerm:self.managedTerm inManagedObjectContext:context];
    
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
            
            [self countString:frequencyWord.name];
        }
    }
    
    NSLog(@"Words: %@, Users: %@, Hashtags: %@", self.popularWords, self.popularUsers, self.popularTags);
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
        Term *term = [self getTerm:self.managedTerm inManagedObjectContext:self.context];
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

- (Term *)getTerm: (Term *)term inManagedObjectContext: (NSManagedObjectContext *)context {
    NSString *name = term.name;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [fetch setPredicate:predicate];
    [fetch setEntity:term.entity];
    
    NSError *error;
    
    Term *newTerm;
    NSArray *array = [context executeFetchRequest:fetch error:&error];
    if (!error) {
        if ([[array firstObject] isKindOfClass:[Term class]]) {
            newTerm = [array firstObject];
        }
    } else {
        NSLog(@"Error: %@", error);
    }
    
    return newTerm;
}
 
@end
