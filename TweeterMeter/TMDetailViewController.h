//
//  TMDetailViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/21/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "TMCurrentProcessViewController.h"
#import "TMChartViewController.h"
#import "TMFrequencyViewController.h"
#import "TMDataTimelineViewController.h"
#import "TMTermControlViewController.h"
#import "TMTerm.h"

@protocol TMDetailSubController <NSObject>

- (void)dataDidUpdate;

@end

@interface TMDetailViewController : UIViewController <UISplitViewControllerDelegate, UIPageViewControllerDataSource, TMTermDelegate>

@property (strong, nonatomic) TMTerm *term;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet UINavigationItem *detailNavigationItem;


@end
