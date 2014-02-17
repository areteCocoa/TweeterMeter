//
//  Word.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/22/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TMInvalidStringLoader.h"
#import "Lexicontext.h"

@class FrequencyObject;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSNumber * isHashtag;
@property (nonatomic, retain) NSNumber * isUser;
@property (nonatomic, retain) NSNumber * isWord;
@property (nonatomic, retain) NSNumber * isValid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet * frequencyObject;

- (id)initWordWithName: (NSString *)name inContext: (NSManagedObjectContext *)context;

@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addFrequencyObjectObject:(FrequencyObject *)value;
- (void)removeFrequencyObjectObject:(FrequencyObject *)value;
- (void)addFrequencyObject:(NSSet *)values;
- (void)removeFrequencyObject:(NSSet *)values;

@end
