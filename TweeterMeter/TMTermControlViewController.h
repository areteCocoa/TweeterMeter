//
//  TMTermControlViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 9/19/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMTerm.h"
#import "TMAppDelegate.h"

@interface TMTermControlViewController : UIViewController

- (id)initWithTerm: (TMTerm *)term;

@property (strong, nonatomic) TMTerm *term;

@end
