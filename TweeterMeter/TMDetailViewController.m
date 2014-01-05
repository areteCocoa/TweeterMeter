//
//  TMDetailViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 12/21/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import "TMDetailViewController.h"

@interface TMDetailViewController ()

@property (strong, nonatomic) TMChartViewController *chartViewController;
@property (strong, nonatomic) TMFrequencyViewController *frequencyViewController;
@property (strong, nonatomic) TMDataTimelineViewController *dataViewController;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;

@end

@implementation TMDetailViewController

@synthesize term = _term;

#pragma mark - Managing the detail item

- (void)setTerm:(TMTerm *)term {
    if (_term != term) {
        term.delegate = self;
        _term = term;
        
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    self.chartViewController = [[TMChartViewController alloc] initWithTerm: self.term];
    self.frequencyViewController = [[TMFrequencyViewController alloc] initWithTerm: self.term];
    self.dataViewController = [[TMDataTimelineViewController alloc] initWithTerm: self.term];
    
    if (self.term) {
        self.navigationItem.title = self.term.name;
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@", [self.term.tweets description]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Update modal with newer tweets
    
    [self.splitViewController.view setNeedsLayout];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TMTermDelegate

- (void)tweetsDidUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@", [self.term.tweets description]];
    });
}

- (void)tweetsDidSave {
    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Terms", @"Terms");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UIPageViewDatasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController == self.chartViewController) {
        return self.frequencyViewController;
    } else if (viewController == self.frequencyViewController) {
        return self.dataViewController;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController == self.frequencyViewController) {
        return self.chartViewController;
    } else if (viewController == self.dataViewController) {
        return self.frequencyViewController;
    }
    
    return nil;
}

@end
