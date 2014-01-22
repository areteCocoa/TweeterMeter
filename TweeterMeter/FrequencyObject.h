//
//  FrequencyObject.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/22/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface FrequencyObject : NSManagedObject

@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Word *parentWord;

@end
