//
//  FrequencyTag.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/22/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FrequencyObject.h"

@class Term, Word;

@interface FrequencyTag : FrequencyObject

@property (nonatomic, retain) Word *parentWord;
@property (nonatomic, retain) Term *term;

@end
