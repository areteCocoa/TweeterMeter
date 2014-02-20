//
//  DisplaySettings.h
//  TweeterMeter
//
//  Created by Thomas Ring on 2/19/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Term;

@interface DisplaySettings : NSManagedObject

@property (nonatomic, retain) NSNumber * displayArticles;
@property (nonatomic, retain) NSNumber * displayConjunctions;
@property (nonatomic, retain) NSNumber * displayInvalidWords;
@property (nonatomic, retain) NSNumber * displayPrepositions;
@property (nonatomic, retain) NSNumber * displayTerm;
@property (nonatomic, retain) NSNumber * minimumStringCount;
@property (nonatomic, retain) NSNumber * proportionOfInvalidAllowed;
@property (nonatomic, retain) Term *term;

@end
