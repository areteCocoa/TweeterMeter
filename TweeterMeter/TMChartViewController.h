//
//  TMChartViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMAppDelegate.h"
#import "TMTerm.h"
#import "XYPieChart.h"

@interface TMChartViewController : UIViewController <XYPieChartDataSource, XYPieChartDelegate>

@property (strong, nonatomic) IBOutlet XYPieChart *pieChart;
- (id)initWithTerm: (TMTerm *)term;
- (void)updateView;

@end
