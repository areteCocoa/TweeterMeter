//
//  TMTerm.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/23/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMTerm : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSSet *tweets;
@property (strong, nonatomic) NSNumber *maxID;
@property (strong, nonatomic) NSNumber *minID;

+ (TMTerm *)termFromManagedObject: (NSManagedObject *) managedObject withContext:context;

- (void)fetchNumberOfTweets:(int)number;

@end
