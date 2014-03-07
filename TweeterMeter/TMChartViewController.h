//
//  TMChartViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Tweet.h"
#import "TMAppDelegate.h"
#import "TMTerm.h"
#import "XYPieChart.h"
#import "TMTweetCell.h"

@interface TMChartViewController : UIViewController <XYPieChartDataSource, XYPieChartDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *detailTableView;
@property (strong, nonatomic) IBOutlet XYPieChart *pieChart;
@property (strong, nonatomic) TMTerm *term;

- (id)initWithTerm: (TMTerm *)term;
- (void)updateView;

@end
