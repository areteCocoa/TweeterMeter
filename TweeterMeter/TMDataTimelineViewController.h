//
//  TMDataTimelineViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMTerm.h"

@interface TMDataTimelineViewController : UIViewController

@property (strong, nonatomic) TMTerm *term;

- (id)initWithTerm: (TMTerm *)term;
- (void)updateView;

@end
