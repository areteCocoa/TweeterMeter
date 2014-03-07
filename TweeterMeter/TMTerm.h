//
//  TMTerm.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/23/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Term.h"
#import "FrequencyWord.h"
#import "FrequencyTag.h"
#import "FrequencyUser.h"
#import "Word.h"

@protocol TMTermDelegate <NSObject>

- (void)attemptingToConnectToTwitter;
- (void)didConnectToTwitter;
- (void)executedFetchRequest;
- (void)startedLoadingTweetsFromRequest: (int)amountOfTweets;
- (void)tweetsHaveLoadedPercent: (float)percent; // from 0 to 1 how many tweets have loaded
- (void)tweetsDidFinishParsing;
- (void)tweetsDidSave;

- (void)noResponseData;

@end

@interface TMTerm : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic, readonly) NSManagedObjectID *objectID;

@property (nonatomic) int topStackRefresh; // How long before the top section of the tweet stack should be updated, minutes

@property (strong, nonatomic) NSMutableDictionary *popularWords;
@property (strong, nonatomic) NSMutableDictionary *popularTags;
@property (strong, nonatomic) NSMutableDictionary *popularUsers;

@property (nonatomic) BOOL isFetchingTweets;
@property (nonatomic) BOOL shouldFetchTweets;

@property id <TMTermDelegate> delegate;

- (id)initTermWithManagedTerm: (Term *)managedTerm withContext:(NSManagedObjectContext *)context;

- (NSInteger)numberOfTweets;
- (NSInteger)numberOfTweetsWithConnotation: (NSString *)connotation;
- (NSArray *)tweetsWithConnotation: (NSString *)connotation;
- (NSArray *)tweetsWithNumber: (NSInteger)numberOfTweets containingString: (NSString *)string;
- (NSArray *)newestTweets: (NSInteger)count;

- (void)beginFetchingTweetsOnOperationQueue: (NSOperationQueue *)queue;

@end
