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
#import <objc/objc-sync.h>

@interface TMTerm()

@property (strong, nonatomic) Term *managedTerm;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSManagedObjectContext *userInterfaceContext; // Context that data on the interface is on
@property (strong, nonatomic) NSEntityDescription *entity;
@property (strong, nonatomic) NSPersistentStoreCoordinator *store;

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic, readonly) NSInvocationOperation *fetchTweetsOperation;

@property (strong, nonatomic) NSString *termState;
@property (nonatomic) BOOL hasReachedBottomOfTweets;
@property (nonatomic) NSInteger tweetCount;

@end

@implementation TMTerm

@synthesize context = _context, managedTerm = _managedTerm;

- (id)initTermWithManagedTerm: (Term *)managedTerm withContext:(NSManagedObjectContext *)context {    
    self.entity = managedTerm.entity;
    self.store = context.persistentStoreCoordinator;
    
    self.name = managedTerm.name;
    
    self.popularWords = [NSMutableDictionary dictionary];
    self.popularTags =  [NSMutableDictionary dictionary];
    self.popularUsers = [NSMutableDictionary dictionary];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.hasReachedBottomOfTweets = NO;
    self.isFetchingTweets = NO;
    self.shouldFetchTweets = NO;
    
    self.userInterfaceContext = [[NSManagedObjectContext alloc] init];
    [self.userInterfaceContext setPersistentStoreCoordinator:context.persistentStoreCoordinator];
    
    self.managedTerm = managedTerm;
    self.tweetCount = self.managedTerm.tweets.count;
    
    [self changeContext];
    
    // SETTINGS AND OPTIONS
    self.topStackRefresh = 360; // Time (minutes) that tweets should be retreived from top (opposed to bottom)
    DisplaySettings *settings = [NSEntityDescription insertNewObjectForEntityForName:@"DisplaySettings" inManagedObjectContext:self.context];
    
    self.managedTerm.displaySettings = settings;
    
    for (FrequencyWord* word in managedTerm.frequencyWords) {
        if ([self shouldCountWord:word.parentWord]) {
            [self.popularWords setObject:word.frequency forKey:word.name];
        }
    }
    
    for (FrequencyTag* tag in managedTerm.frequencyTags) {
        if ([self shouldCountWord:tag.parentWord]) {
            [self.popularTags setObject:tag.frequency forKey:tag.name];
        }
    }
    
    for (FrequencyUser* user in managedTerm.frequencyUsers) {
        if ([self shouldCountWord:user.parentWord]) {
            [self.popularUsers setObject:user.frequency forKey:user.name];
        }
    }
    
    NSLog(@"Tweets loaded: %lu", (unsigned long)self.managedTerm.tweets.count);
    
    return self;
}

- (NSArray *)newestTweets:(NSInteger)numberOfTweets {
    NSSet *tweetsCopy = [self.managedTerm.tweets mutableCopy];
    NSMutableSet *tweetsCorrectedContext = [NSMutableSet set];
    for (Tweet *tweet in tweetsCopy) {
        Tweet *correctContextTweet = (Tweet*)[self.userInterfaceContext objectWithID:tweet.objectID];
         [tweetsCorrectedContext addObject:correctContextTweet];
    }
    
    NSMutableArray *tweetsArray = [[self sortTweetsByDate:tweetsCorrectedContext] mutableCopy];
    while (tweetsArray.count > numberOfTweets) {
        [tweetsArray removeLastObject];
    }
    
    return tweetsArray;
}

- (NSInteger)numberOfTweets {
    return self.tweetCount;
}

- (NSInteger)numberOfTweetsWithConnotation:(NSString *)connotation {
    return [self tweetsWithConnotation:connotation].count;
}

// Returns a set of tweet objects in an unsorted set
- (NSArray *)tweetsWithConnotation:(NSString *)connotation {
    NSSet *tweetsCopy = [self.managedTerm.tweets mutableCopy];
    NSMutableSet *tweetsCorrectedContext = [NSMutableSet set];
    for (Tweet *tweet in tweetsCopy) {
        Tweet *correctContextTweet = (Tweet *)[self.userInterfaceContext objectWithID:tweet.objectID];
        [tweetsCorrectedContext addObject:correctContextTweet];
    }
    NSSet *set = [tweetsCorrectedContext objectsPassingTest:^BOOL(id obj, BOOL* test) {
        Tweet *tweet = (Tweet *)obj;
        return [tweet.connotation isEqualToString:connotation];
    }];
    
    NSArray *tweets = [self sortTweetsByDate:set];
    
    return tweets;
}

- (NSArray *)tweetsWithNumber: (NSInteger)numberOfTweets containingString: (NSString *)string {
    // Get tweets that only match the string
    NSSet *tweetsCopy = [self.managedTerm.tweets mutableCopy];
    NSMutableSet *tweetsCorrectedContext =[NSMutableSet set];
    for (Tweet *tweet in tweetsCopy) {
        Tweet *correctContextTweet = (Tweet*)[self.userInterfaceContext objectWithID:tweet.objectID];
        [tweetsCorrectedContext addObject:correctContextTweet];
    }
    
    NSSet *filteredTweets = [tweetsCorrectedContext objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        Tweet *tweet = (Tweet *)obj;
        BOOL tweetContainsString = ([[tweet.text lowercaseString] rangeOfString:string].location != NSNotFound);
        return tweetContainsString;
    }];
    
    // Sort by date
    NSMutableArray *array = [[self sortTweetsByDate:filteredTweets] mutableCopy];
    while (array.count > numberOfTweets) {
        [array removeLastObject];
    }
    
    return array;
}

- (NSArray *)sortTweetsByDate: (NSSet *)tweets {
    NSArray *tweetsArray = [[tweets allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Tweet *tweet1 = (Tweet *)obj1;
        Tweet *tweet2 = (Tweet *)obj2;
        if ([[tweet1.date laterDate:tweet2.date] isEqualToDate:tweet1.date]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return tweetsArray;
}

- (void)beginFetchingTweetsOnOperationQueue:(NSOperationQueue *)queue {
    self.shouldFetchTweets = YES;
    if (queue) {
        self.queue = queue;
    }
    queue.maxConcurrentOperationCount = 1;
    
# warning "Incomplete implementation"
    BOOL autoCollectTweets = NO;
    if (!autoCollectTweets) {
        [self stopFetchingTweets];
    }
    
    [self fetchMaxTweetsOnQueue];
}

- (NSInvocationOperation *)fetchTweetsOperation {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchMaxTweets) object:nil];
    
    return operation;
}

- (void)fetchMaxTweets {
    [self fetchNumberOfTweets:100];
}

- (void)countWord: (Word *)word {
    if ([self shouldCountWord:word]) {
        char firstCharacter = [word.name characterAtIndex:0];
        NSMutableDictionary *dictionary;
        if (firstCharacter == '#') {
            dictionary = self.popularTags;
        } else if (firstCharacter == '@') {
            dictionary = self.popularUsers;
        } else {
            dictionary = self.popularWords;
        }
        
        NSNumber *oldValue = [dictionary objectForKey:word.name];
        if (!oldValue) {
            [dictionary setObject:@1 forKey:word.name];
        } else {
            [dictionary setObject:@([oldValue intValue] + 1) forKey:word.name];
        }
    }
}

- (BOOL)shouldCountWord: (Word *)word {
    DisplaySettings *settings = self.managedTerm.displaySettings;
    
    // Reject strings less than length of minimumStringCount
    int minimumStringCount = [settings.minimumStringCount intValue];
    int wordLength = [word stringLength];
    if (minimumStringCount > wordLength) {
        return NO;
    }
    
    // Reject articles if toggled
    if ([settings.displayArticles isEqualToNumber:@0] && [word.type isEqualToString:@"Article"]) {
        return NO;
    }
    
    // Reject conjunctions if toggled
    if ([settings.displayConjunctions isEqualToNumber:@0] && [word.type isEqualToString:@"Conjunction"]) {
        return NO;
    }
    
    // Reject determiners if toggled
    if ([settings.displayDeterminers isEqualToNumber:@0] && [word.type isEqualToString:@"Determiner"]) {
        return NO;
    }
    
    // Reject invalid words if toggled
    if ([settings.displayInvalidWords isEqualToNumber:@0] && [word.isValid isEqualToNumber:@0]) {
        return NO;
    }
    
    // Reject prepositions if toggled
    if ([settings.displayPrepositions isEqualToNumber:@0] && [word.type isEqualToString:@"Preposition"]) {
        //
    }
    
    // Reject term words if toggled
    if ([settings.displayTerm isEqualToNumber:@0] && [self.managedTerm.name rangeOfString:word.name].location != NSNotFound) {
        return NO;
    }
    
    return YES;
}

#pragma mark Twitter Methods

- (void)fetchMaxTweetsOnQueue {
    // NSInvocationOperation *saveOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(saveContext:) object:self.context];
    [self.queue addOperations:@[self.fetchTweetsOperation] waitUntilFinished:NO];
}

- (void)fetchNumberOfTweets:(int)number {
    NSLog(@"Attempting to fetch %i tweets.", number);
    
    self.isFetchingTweets = YES;
    [self.delegate attemptingToConnectToTwitter];
    
    ACAccountStore *store = [[ACAccountStore alloc] init];
    
    if ([SLComposeViewController
         isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [store requestAccessToAccountsWithType:twitterAccountType options:NULL
                                    completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSLog(@"Access to Twitter granted.");
                 [self.delegate didConnectToTwitter];
                 // Create request with params
                 NSMutableDictionary *params = [@{@"q" : _name,
                                                 @"result_type" : @"recent",
                                                 @"count" : [NSString stringWithFormat:@"%i", number]} mutableCopy];
                 if (self.managedTerm.tweets.count > 0) {
                     NSDate *nextUpdate = [self.managedTerm.maxDate dateByAddingTimeInterval:60*self.topStackRefresh];
                     if ([nextUpdate earlierDate:[NSDate date]] == nextUpdate) {
                         [params setObject:[NSString stringWithFormat:@"%@", self.managedTerm.maxID] forKey:@"since_id"];
                     } else if (!self.hasReachedBottomOfTweets) {
                         [params setObject:[NSString stringWithFormat:@"%@", self.managedTerm.minID] forKey:@"max_id"];
                     } else {
                         [params setObject:[NSString stringWithFormat:@"%@", self.managedTerm.maxID] forKey:@"since_id"];
                     }

                 }
                 
                 NSLog(@"Fetching tweets with parameters: %@", params);
                 
                 NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                      [self.delegate executedFetchRequest];
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                              NSError *jsonError;
                              NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  // create tweets from data
                                  id statuses = [timelineData valueForKey:@"statuses"];
                                  NSLog(@"Attempted to fetch %@ tweets. %@ received.", [NSNumber numberWithInt:number], [NSNumber numberWithFloat:[statuses allObjects].count]);
                                  if ([statuses isKindOfClass:[NSArray class]]) {
                                      NSArray *statusesArray = (NSArray *)statuses;
                                      float count = 0.0;
                                      float total = statusesArray.count;
                                      [self.delegate startedLoadingTweetsFromRequest:total];
                                      
                                      [self changeContext];
                                      
                                      for (NSDictionary *dictionary in statuses) {
                                          [self addTweet:dictionary inContext:self.context];
                                          count++;
                                          [self.delegate tweetsHaveLoadedPercent:count/total];
                                      }
                                      [self.delegate tweetsDidFinishParsing];
                                      if ([self saveContext:self.context]) {
                                          [self.delegate tweetsDidSave];
                                      }
                                      
                                      BOOL verbosePrintTweets = NO;
                                      if (verbosePrintTweets) {
                                          NSLog(@"%@", statuses);
                                      }
                                      self.isFetchingTweets = NO;
                                      if (self.shouldFetchTweets) {
                                          [self fetchMaxTweetsOnQueue];
                                      }
                                  }
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          } else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %ld",
                                    (long)urlResponse.statusCode);
                          }
                      } else {
                          NSLog(@"No response data!");
                          self.isFetchingTweets = NO;
                          [self.delegate noResponseData];
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"Access not granted to twitter. Error: %@", [error localizedDescription]);
             }
         }];
    } else {
        NSLog(@"SLComposeViewController not available. Cannot connect to Twitter.");
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
        tweet.userName = [[rawTweet valueForKey:@"user"] valueForKey:@"name"];
        tweet.userScreenName = [[rawTweet valueForKey:@"user"] valueForKey:@"screen_name"];
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
        tweet.term = self.managedTerm;
        self.tweetCount++;
    }
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
    
    int good = 0, bad = 0;
    for (NSUInteger index = 0; index < words.count; index++) {
        
        // Trim word string
        wordString = [words[index] lowercaseString]; //lowercase
        if (wordString.length > 0) {
            wordString = [Word getCorrectWordFromString:wordString];
        }
        
        if (wordString.length > 0) {
            frequencyObject = [self getFrequencyObjectWithName:wordString];
            [frequencyObject addOneToFrequency];
            
            [self countWord:frequencyObject.parentWord];
            if (frequencyObject.parentWord.connotation != nil && ![frequencyObject.parentWord.connotation isEqualToString:@""] && [self.managedTerm.name rangeOfString:frequencyObject.parentWord.name].location == NSNotFound) {
                if ([frequencyObject.parentWord.connotation isEqualToString:@"good"]) {
                    good++;
                }else if ([frequencyObject.parentWord.connotation isEqualToString:@"bad"]) {
                    bad++;
                }
            }
        }
    }
    if (good > bad) {
        tweet.connotation = @"good";
    } else if (bad > good) {
        tweet.connotation = @"bad";
    } else if (good == 0 && bad == 0){
        tweet.connotation = @"none";
    } else {
        // default
        tweet.connotation = @"good";
    }
    
    // Set managed term tracking of our data's position relative to other data
    if (!self.managedTerm.maxDate || !self.managedTerm.minDate || [self.managedTerm.minID isEqualToNumber:@0]|| [self.managedTerm.maxID isEqualToNumber:@0]) {
        if (!self.managedTerm.maxDate) self.managedTerm.maxDate = tweet.date;
        if (!self.managedTerm.minDate) self.managedTerm.minDate = tweet.date;
        if ([self.managedTerm.minID isEqualToNumber:@0]) self.managedTerm.minID = tweet.tweetID;
        if ([self.managedTerm.maxID isEqualToNumber:@0]) self.managedTerm.maxID = tweet.tweetID;
    } else {
        if ([[self.managedTerm.maxDate laterDate:tweet.date] isEqualToDate:tweet.date]) {
            self.managedTerm.maxDate = tweet.date;
        } else if ([[self.managedTerm.minDate earlierDate:tweet.date] isEqualToDate:tweet.date]) {
            self.managedTerm.minDate = tweet.date;
        }
        if ([self.managedTerm.maxID compare:tweet.tweetID] == (NSComparisonResult)NSOrderedAscending) {
            self.managedTerm.maxID = tweet.tweetID;
        } else if ([self.managedTerm.minID compare:tweet.tweetID] == (NSComparisonResult)NSOrderedDescending) {
            self.managedTerm.minID = tweet.tweetID;
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
            
            // [self saveContext:self.context];
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
            
            // [self saveContext:self.context];
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
            
            // [self saveContext:self.context];
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

- (void)changeContext {
    self.context = [[NSManagedObjectContext alloc] init];
    [self.context setPersistentStoreCoordinator:self.store];
    self.managedTerm = (Term *)[self.context objectWithID:self.managedTerm.objectID];
}

#pragma mark - Controller Methods

- (void)startFetchingTweets {
    [self.queue setSuspended:NO];
}

- (void)stopFetchingTweets {
    [self.queue setSuspended:YES];
}

- (void)clearAllTweets {
    [self stopFetchingTweets];
#warning "Incomplete implementation"
}

@end
