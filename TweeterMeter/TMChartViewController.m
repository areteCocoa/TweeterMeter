//
//  TMChartViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMChartViewController.h"

@interface TMChartViewController ()

@end

@implementation TMChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTerm: (TMTerm *)term {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"chart"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
