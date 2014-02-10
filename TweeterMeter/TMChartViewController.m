//
//  TMChartViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMChartViewController.h"

@interface TMChartViewController ()

@property (strong, nonatomic) IBOutlet UITextView *tweetTextView;

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
    _term = term;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.pieChart setDataSource:self];
    [self.pieChart setDelegate:self];
    [self.pieChart setStartPieAngle:M_2_PI];
    [self.pieChart setAnimationSpeed:1.0];
    [self.pieChart setLabelColor:[UIColor blackColor]];
    [self.pieChart setLabelFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [self.pieChart setLabelRadius:160];
    [self.pieChart setShowPercentage:YES];
    [self.pieChart setPieBackgroundColor:[UIColor clearColor]];
    [self.pieChart reloadData];
    
    [self.tweetTextView setText:[self.term description]];
}

- (void)updateView {
    [self.pieChart reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XYPieChartDataSource

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return 2;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    if (index == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    if (index == 0) {
        return [UIColor greenColor];
    } else {
        return [UIColor redColor];
    }
}

#pragma mark - XYPieChartDelegate

- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
    // When selected
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
    // When deselected
}

@end
