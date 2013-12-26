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

@end
