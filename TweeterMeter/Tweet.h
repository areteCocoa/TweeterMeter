//
//  Tweet.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/25/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSManagedObject *term;

@end
