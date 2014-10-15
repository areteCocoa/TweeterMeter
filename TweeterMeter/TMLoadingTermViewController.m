//
//  TMLoadingTermViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 3/13/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMLoadingTermViewController.h"

@interface TMLoadingTermViewController ()

@end

@implementation TMLoadingTermViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.activityView.layer.cornerRadius = 5.0;
    self.activityView.layer.masksToBounds = YES;
    
    [self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
