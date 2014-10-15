//
//  TMLoadingTermViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 3/13/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMLoadingTermViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *activityText;
@property (strong, nonatomic) IBOutlet UIView *activityView;

@end
