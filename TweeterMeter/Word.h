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
#import "TMConnotationLoader.h"
#import "Lexicontext.h"

@class FrequencyObject;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * connotation;
@property (nonatomic, retain) NSString * definition;
@property (nonatomic, retain) NSNumber * isHashtag;
@property (nonatomic, retain) NSNumber * isUser;
@property (nonatomic, retain) NSNumber * isWord;
@property (nonatomic, retain) NSNumber * isValid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet * synonyms;
@property (nonatomic, retain) NSSet * frequencyObject;

@property (nonatomic) NSInteger stringLength;
@property (nonatomic) BOOL isFindingSynonyms;

- (id)initWordWithName: (NSString *)name inContext: (NSManagedObjectContext *)context;

+ (NSString *)getCorrectWordFromString: (NSString *)string;

@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addFrequencyObjectObject:(FrequencyObject *)value;
- (void)removeFrequencyObjectObject:(FrequencyObject *)value;
- (void)addFrequencyObject:(NSSet *)values;
- (void)removeFrequencyObject:(NSSet *)values;

- (void)addSynonymsObject:(Word *)value;
- (void)removeSynonymsObject:(FrequencyObject *)value;
- (void)addSynonyms:(NSSet *)values;
- (void)removeSynonyms:(NSSet *)values;

@end
