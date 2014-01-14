//
//  FrequencyWord.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/14/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Term, Word;

@interface FrequencyWord : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) Term *term;
@property (nonatomic, retain) Word *parentWord;

@end
