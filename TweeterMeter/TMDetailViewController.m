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
@property (strong, nonatomic) NSArray *viewControllers;

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
        
        self.chartViewController.term = term;
        self.frequencyViewController.term = term;
        self.dataViewController.term = term;
        
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (!self.chartViewController || !self.frequencyViewController || !self.dataViewController) {
        self.chartViewController = [[TMChartViewController alloc] initWithTerm: self.term];
        self.frequencyViewController = [[TMFrequencyViewController alloc] initWithTerm: self.term];
        self.dataViewController = [[TMDataTimelineViewController alloc] initWithTerm: self.term];
        self.viewControllers = @[self.chartViewController];
    }
    
    if (!self.pageViewController) {
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"page"];
        self.pageViewController.dataSource = self;
        [self.pageViewController setViewControllers:self.viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    if (self.term) {
        self.navigationItem.title = self.term.name;
    }
    
    [self updateSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Update modal with newer tweets
    
    [self.splitViewController.view setNeedsLayout];
    [self configureView];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.pageViewController.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSubviews {
    [self.chartViewController updateView];
    [self.frequencyViewController updateView];
    [self.dataViewController updateView];
}

#pragma mark - TMTermDelegate

- (void)tweetsDidUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Pass data to the VCs
        [self updateSubviews];
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
    NSUInteger index = [self indexOfViewController:viewController];
    
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:viewController];
    
    if (index == NSNotFound || index == 0) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex: (NSUInteger)index {
    if (index == 0) {
        return self.chartViewController;
    } else if (index == 1) {
        return self.frequencyViewController;
    } else if (index == 2) {
        return self.dataViewController;
    }
    return nil;
}

- (NSUInteger)indexOfViewController: (UIViewController *) viewController {
    if (viewController == self.chartViewController) {
        return 0;
    } else if (viewController == self.frequencyViewController) {
        return 1;
    } else if (viewController == self.dataViewController) {
        return 2;
    }
    return NSNotFound;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
