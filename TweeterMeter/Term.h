//
//  Term.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/26/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet;

@interface Term : NSManagedObject

@property (nonatomic, retain) NSDate * creationTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Tweet *tweets;
@property (nonatomic, retain) NSSet *words;

@end

@interface Term (CoreDataGeneratedAccessors)

- (void)addFrequencyWordObject:(NSManagedObject *)value;
- (void)removeFrequencyWordObject:(NSManagedObject *)value;
- (void)addFrequencyWord:(NSSet *)values;
- (void)removeFrequencyWord:(NSSet *)values;

@end