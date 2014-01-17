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

+ (TMTerm *) termFromManagedTerm:(Term *)managedTerm withContext:(NSManagedObjectContext *)context {
    TMTerm *term = [[TMTerm alloc] init];
    term.managedTerm = managedTerm;
    term.context = context;
    
    term.name = managedTerm.name;
    
    term.tweets = [NSMutableSet set];
    term.tweets = [managedTerm.tweets mutableCopy];
    
    term.frequencyWords = [managedTerm.frequencyWords mutableCopy];
    
    if (!term.tweets || term.tweets.count < 10) {
        [term fetchNumberOfTweets:10];
    }
    
    NSLog(@"Tweets loaded: %lu", (unsigned long)term.tweets.count);
    term.popularWords = [NSMutableDictionary dictionary];
    term.popularTags =  [NSMutableDictionary dictionary];
    term.popularUsers = [NSMutableDictionary dictionary];
    
    return term;
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
                                      [self addTweets:[NSSet setWithArray:statuses]];
                                  }
                                  
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      // Do something on the main thread
                                  });
                                   
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

- (void)addTweets:(NSSet *)objects {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:_context];
    for (id object in objects) {
        Tweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:_context];
        tweet.user = [[object valueForKey:@"user"] valueForKey:@"name"];
        tweet.text = [object valueForKey:@"text"];
        tweet.term = self.managedTerm;
        
        // Analyze Tweet
        [self analyzeTweet:tweet];
        
        [self.tweets addObject:tweet];
    }
    
    [self.delegate tweetsDidUpdate];
    if ([self save]) {
        [self.delegate tweetsDidSave];
    }
}

// Goes through tweet looking for certain words
- (void)analyzeTweet: (Tweet *)tweet {
    NSString *text = tweet.text;
    NSMutableArray *words = (NSMutableArray *)[text componentsSeparatedByString:@" "];
    if ([words containsObject:@""]) {
        [words removeObjectIdenticalTo:@""];
    }
    NSNumber *old;
    NSString *wordString;
    
    for (NSUInteger index = 0; index < words.count; index++) {
        wordString = words[index];
        if (wordString.length != 0) {
            NSLog(@"%@", [self getFrequencyWordWithName:wordString]);
            
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
        }
    }
    
    NSLog(@"Words: %@, Users: %@, Hashtags: %@", self.popularWords, self.popularUsers, self.popularTags);
}

- (FrequencyWord *)getFrequencyWordWithName: (NSString *)name {
    FrequencyWord *word;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FrequencyWord" inManagedObjectContext:self.context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error retreiving objects: %@", error);
    } else if (objects.count == 0) {
        // Create new FrequencyWord
        Word *parentWord = [Word fetchWordWithName:name inContext:self.context];
        
        word = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.context];
        word.name = name;
        word.frequency = @1;
        word.term = self.managedTerm;
        
        word.parentWord = parentWord;
        [parentWord addFrequencyWordObject:word];
        
    } else if (objects.count != 1) {
        NSLog(@"Objects retreived is greater than expected: %lu objects", (unsigned long)objects.count);
    } else {
        word = [objects firstObject];
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
