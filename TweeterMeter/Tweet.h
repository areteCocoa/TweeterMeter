//
//  Tweet.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/25/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Term.h"

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * connotation;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userScreenName;
@property (nonatomic, retain) Term * term;
@property (nonatomic, retain) NSNumber * tweetID;
@property (nonatomic, retain) NSDate * date;

@end
