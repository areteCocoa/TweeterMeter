//
//  TMCurrentProcessViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 3/6/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMCurrentProcessViewController : UIViewController

- (void)setBeforeValue: (int)beforeValue withAfterValue: (int)afterValue;
- (void)showProgressView;
- (void)showProgressViewWithBeforeValue: (int)beforeValue withAfterValue: (int)afterValue;
- (void)setProgressBarProgress: (float)progress;
- (void)showLabelViewWithText: (NSString *)text;

@end
