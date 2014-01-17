//
//  Word.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/14/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "TMAppDelegate.h"

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *frequencyWord;

+ (Word *)fetchWordWithName: (NSString *)name inContext:(NSManagedObjectContext *)context;

@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addFrequencyWordObject:(NSManagedObject *)value;
- (void)removeFrequencyWordObject:(NSManagedObject *)value;
- (void)addFrequencyWord:(NSSet *)values;
- (void)removeFrequencyWord:(NSSet *)values;

@end
