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
    
    // SETTINGS AND OPTIONS
    self.displayInvalidWords = NO;
    self.topStackRefresh = 60;
    
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
    
    for (FrequencyWord* word in managedTerm.frequencyWords) {
        if (!self.displayInvalidWords) {
            if (![word.parentWord.isValid isEqualToNumber:@0]) {
                [self.popularWords setObject:word.frequency forKey:word.name];
            }
        } else {
            [self.popularWords setObject:word.frequency forKey:word.name];
        }
    }
    
    for (FrequencyTag* tag in managedTerm.frequencyTags) {
        if (!self.displayInvalidWords) {
            if (![tag.parentWord.isValid isEqualToNumber:@0]) {
                [self.popularTags setObject:tag.frequency forKey:tag.name];
            }
        } else {
            [self.popularTags setObject:tag.frequency forKey:tag.name];
        }
    }
    
    for (FrequencyUser* user in managedTerm.frequencyUsers) {
        if (!self.displayInvalidWords) {
            if (![user.parentWord.isValid isEqualToNumber:@0]) {
                [self.popularUsers setObject:user.frequency forKey:user.name];
            }
        } else {
            [self.popularUsers setObject:user.frequency forKey:user.name];
        }
    }
    
    NSLog(@"Tweets loaded: %lu", (unsigned long)self.managedTerm.tweets.count);
    
    [self fetchNumberOfTweets:100 withContext:self.context];
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(fetchMaxTweets) userInfo:nil repeats:YES];
    
    return self;
}

- (void)countString: (NSString *)word {
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

- (void)fetchMaxTweets {
    [self fetchNumberOfTweets:100 withContext:self.context];
}

- (void)fetchNumberOfTweets:(int)number withContext:(NSManagedObjectContext *)context {
    ACAccountStore *store = [[ACAccountStore alloc] init];
    if ([SLComposeViewController
         isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [store requestAccessToAccountsWithType:twitterAccountType options:NULL
                                    completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 // Create a request
                 // See what range of tweets we should be getting
                 NSMutableDictionary *params = [@{@"q" : _name,
                                                 @"result_type" : @"recent",
                                                 @"count" : [NSString stringWithFormat:@"%i", number]} mutableCopy];
                 if (abs([self.managedTerm.maxDate timeIntervalSinceNow]) > 60*60) {
                     [params setObject:[NSString stringWithFormat:@"%@", self.managedTerm.maxID] forKey:@"since_id"];
                 }
                 
                 
                 NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
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
                                      NSLog(@"Attempted to fetch %@ tweets. %@ received.", [NSNumber numberWithInt:number], [NSNumber numberWithFloat:[statuses allObjects].count]);
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
            tweet = object;
        }
    } else {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        tweet.user = [[rawTweet valueForKey:@"user"] valueForKey:@"name"];
        tweet.text = [rawTweet valueForKey:@"text"];
        tweet.tweetID = [rawTweet valueForKey:@"id"];
        
        // Convert twitter date string to NSDate
        NSString *creationDate = [[rawTweet valueForKey:@"created_at"] substringFromIndex:4];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM dd HH:mm:ss '+0000' yyyy"];
        NSDate *date = [formatter dateFromString:creationDate];
        tweet.date = date;
    }
    
    // Analyze Tweet
    if (![self.managedTerm.tweets containsObject:tweet]) {
        [self analyzeTweet:tweet];
    }
    
    if (self.managedTerm.tweets.count == 0) {
        self.managedTerm.maxDate = tweet.date;
        self.managedTerm.minDate = tweet.date;
        self.managedTerm.maxID = tweet.tweetID;
        self.managedTerm.minID = tweet.tweetID;
    } else {
        // Check ID range...
        if (tweet.tweetID > self.managedTerm.maxID) {
            self.managedTerm.maxID = tweet.tweetID;
        } else if (tweet.tweetID < self.managedTerm.minID) {
            self.managedTerm.minID = tweet.tweetID;
        }
        // And date range...
        if ([tweet.date earlierDate:self.managedTerm.minDate] == tweet.date) {
            self.managedTerm.minDate = tweet.date;
        } else if ([tweet.date laterDate:self.managedTerm.maxDate] == tweet.date) {
            self.managedTerm.maxDate = tweet.date;
        }
    }
    
    tweet.term = self.managedTerm;
    // [self.delegate tweetsDidUpdate];
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
    FrequencyObject *frequencyObject;
    
    for (NSUInteger index = 0; index < words.count; index++) {
        wordString = [words[index] lowercaseString];
        if (wordString.length != 0) {
            frequencyObject = [self getFrequencyObjectWithName:wordString];
            [frequencyObject addOneToFrequency];
            
            if (self.displayInvalidWords || [frequencyObject.parentWord.isValid isEqualToNumber:@1]) {
                [self countString:frequencyObject.name];
            }
        }
    }
    
    // Log resulting frequency sets
    // NSLog(@"Words: %@, Users: %@, Hashtags: %@", self.popularWords, self.popularUsers, self.popularTags);
}

- (FrequencyObject *)getFrequencyObjectWithName: (NSString *)name {
    FrequencyObject *object;
    
    if ([name characterAtIndex:0] == '#') {
        FrequencyTag *tag;
        object = [self getFrequencyObjectFromSet:self.managedTerm.frequencyTags withName:name];
        if ([object isKindOfClass:[FrequencyTag class]]) {
            tag = (FrequencyTag *)object;
        }
        
        if (!tag) {
            Word *parentWord = [[Word alloc] initWordWithName:name inContext:self.context];
            
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"FrequencyTag" inManagedObjectContext:self.context];
            tag.name = name;
            tag.frequency = @0;
            Term *term = self.managedTerm;
            tag.term = term;
            
            tag.parentWord = parentWord;
            
            [self saveContext:self.context];
        }
        
        return tag;
    } else if ([name characterAtIndex:0] == '@') {
        FrequencyUser *user;
        object = [self getFrequencyObjectFromSet:self.managedTerm.frequencyUsers withName:name];
        if ([object isKindOfClass:[FrequencyUser class]]) {
            user = (FrequencyUser *)object;
        }
        
        if (!user) {
            Word *parentWord = [[Word alloc] initWordWithName:name inContext:self.context];
            
            user = [NSEntityDescription insertNewObjectForEntityForName:@"FrequencyUser" inManagedObjectContext:self.context];
            user.name = name;
            user.frequency = @0;
            Term *term = self.managedTerm;
            user.term = term;
            
            user.parentWord = parentWord;
            
            [self saveContext:self.context];
        }
        
        return user;
    } else {
        FrequencyWord *word;
        object = [self getFrequencyObjectFromSet:self.managedTerm.frequencyWords withName:name];
        if ([object isKindOfClass:[FrequencyWord class]]) {
            word = (FrequencyWord *)object;
        }
        
        if (!word) {
            Word *parentWord = [[Word alloc] initWordWithName:name inContext:self.context];
            
            word = [NSEntityDescription insertNewObjectForEntityForName:@"FrequencyWord" inManagedObjectContext:self.context];
            word.name = name;
            word.frequency = @0;
            Term *term = self.managedTerm;
            word.term = term;
            word.parentWord = parentWord;
            
            [self saveContext:self.context];
        }
        
        return word;
    }
}

- (FrequencyObject *)getFrequencyObjectFromSet: (NSSet *)set withName: (NSString *)name {
    NSSet *objects = [set objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        FrequencyObject *nextObject = (FrequencyObject *)obj;
        return ([nextObject.name isEqualToString:name]);
    }];
    
    FrequencyObject *object = [objects anyObject];
    return object;
}

- (BOOL)saveContext: (NSManagedObjectContext *)context {
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
        // abort();
    } else if (!context) {
        NSLog(@"context nil");
    }
    return YES;
}
 
@end
