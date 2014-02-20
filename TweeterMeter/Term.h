//
//  Term.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/16/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DisplaySettings.h"

@class FrequencyWord, Tweet;

@interface Term : NSManagedObject

@property (nonatomic, retain) NSDate * creationTime;
@property (nonatomic, retain) NSDate * maxDate;
@property (nonatomic, retain) NSNumber * maxID;
@property (nonatomic, retain) NSDate * minDate;
@property (nonatomic, retain) NSNumber * minID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *frequencyTags;
@property (nonatomic, retain) NSSet *frequencyUsers;
@property (nonatomic, retain) NSSet *frequencyWords;
@property (nonatomic, retain) NSSet *tweets;
@property (nonatomic, retain) DisplaySettings *displaySettings;
@end

@interface Term (CoreDataGeneratedAccessors)

- (void)addFrequencyTagsObject:(NSManagedObject *)value;
- (void)removeFrequencyTagsObject:(NSManagedObject *)value;
- (void)addFrequencyTags:(NSSet *)values;
- (void)removeFrequencyTags:(NSSet *)values;

- (void)addFrequencyUsersObject:(NSManagedObject *)value;
- (void)removeFrequencyUsersObject:(NSManagedObject *)value;
- (void)addFrequencyUsers:(NSSet *)values;
- (void)removeFrequencyUsers:(NSSet *)values;

- (void)addFrequencyWordsObject:(FrequencyWord *)value;
- (void)removeFrequencyWordsObject:(FrequencyWord *)value;
- (void)addFrequencyWords:(NSSet *)values;
- (void)removeFrequencyWords:(NSSet *)values;

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
