//
//  FrequencyObject.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/22/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "FrequencyObject.h"
#import "Word.h"


@implementation FrequencyObject

@dynamic frequency;
@dynamic name;
@dynamic parentWord;

- (void)addOneToFrequency {
    float oldFrequency = [self.frequency floatValue];
    float newFrequency = oldFrequency + 1;
    self.frequency = [NSNumber numberWithFloat:newFrequency];
}

@end
