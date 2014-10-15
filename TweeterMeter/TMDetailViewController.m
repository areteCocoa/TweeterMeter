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
@property (strong, nonatomic) TMTermControlViewController *controlController;

@property (strong, nonatomic) TMCurrentProcessViewController *currentProcessViewController;
@property (strong, nonatomic) NSArray *viewControllers;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (strong, nonatomic) UIView *overlayView; // Displayed when no term is selected

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
    self.view.backgroundColor = [(TMAppDelegate *)[[UIApplication sharedApplication] delegate] backgroundColor];
    
    // Update the user interface for the detail item.
    if (!self.chartViewController || !self.frequencyViewController || !self.dataViewController) {
        self.chartViewController = [[TMChartViewController alloc] initWithTerm: self.term];
        self.frequencyViewController = [[TMFrequencyViewController alloc] initWithTerm: self.term];
        self.dataViewController = [[TMDataTimelineViewController alloc] initWithTerm: self.term];
        self.controlController = [[TMTermControlViewController alloc] initWithTerm: self.term];
        self.viewControllers = @[self.chartViewController];
    }
    
    if (!self.pageViewController) {
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"page"];
        self.pageViewController.dataSource = self;
        [self.pageViewController setViewControllers:self.viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    if (self.term) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@", self.term.name, [NSNumber numberWithInteger:[self.term numberOfTweets]]];
        [self.overlayView setHidden:YES];
    } else {
        self.navigationItem.title = @"TweeterMeter";
    }
    
    [self updateSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Update modal with newer tweets
    
    //[self.splitViewController.view setNeedsLayout];
    [self configureView];
    
    // Progress View Controller
    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat height = 50;
    self.currentProcessViewController = [[TMCurrentProcessViewController alloc] init];
    self.currentProcessViewController.view.frame = CGRectMake(0, navigationHeight + 20, self.view.frame.size.width, height);
    self.currentProcessViewController.view.backgroundColor = [UIColor colorWithWhite:1 alpha:.5];
    [self addChildViewController: self.currentProcessViewController];
    [self.view addSubview: self.currentProcessViewController.view];
    [self.currentProcessViewController didMoveToParentViewController:self];
    
    [self.currentProcessViewController.view setNeedsDisplay];
    
    self.pageViewController.view.frame = CGRectMake(0, self.currentProcessViewController.view.frame.size.height+self.currentProcessViewController.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height-height);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.pageViewController.view setNeedsDisplay];
    
    if (!self.term) {
        if (!self.overlayView) {
            self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
            self.overlayView.backgroundColor = self.view.backgroundColor;
            [self.view addSubview:self.overlayView];
            [self.view bringSubviewToFront:self.overlayView];
        }
        [self.overlayView setHidden:NO];
    }
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
    
    if (self.term) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@", self.term.name, [NSNumber numberWithInteger:[self.term numberOfTweets]]];
    }
}

#pragma mark - TMTermDelegate

- (void)attemptingToConnectToTwitter {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.currentProcessViewController showLabelViewWithText:@"Attempting to connect to Twitter..."] ;
    });
}

- (void)didConnectToTwitter {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.currentProcessViewController showLabelViewWithText:@"Successfully Connected to Twitter!"];
    });
}

- (void)executedFetchRequest {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.currentProcessViewController showLabelViewWithText:@"Executing fetch request..."];
    });
}

- (void)startedLoadingTweetsFromRequest:(int)amountOfTweets {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.currentProcessViewController showLabelViewWithText:[NSString stringWithFormat:@"Loading %i Tweets from fetch request...", amountOfTweets]];
        [self.currentProcessViewController setBeforeValue:[self.term numberOfTweets] withAfterValue:[self.term numberOfTweets] + amountOfTweets];
    });
}

- (void)tweetsHaveLoadedPercent: (float)percent {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.currentProcessViewController setProgressBarProgress:percent];
        [self.currentProcessViewController showProgressView];
    });
}

- (void)tweetsDidFinishParsing {
    [self pushCurrentProcessMessage:@"Tweets finished being analyzed..." withCompletiton:nil];
}

- (void)tweetsDidSave {
    [self pushCurrentProcessMessage:@"Tweets successfully saved to database." withCompletiton:^void() {[self updateSubviews];} ];
}

- (void)noResponseData {
    [self pushCurrentProcessMessage:@"No response data from twitter! (No internet connection)" withCompletiton:nil];
}

- (void)pushCurrentProcessMessage: (NSString *)message withCompletiton:(void (^)())completion {
    NSLog(@"%@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        // Pass data to the VCs
        [self.currentProcessViewController showLabelViewWithText:message];
        if (completion) {
            completion();
        }
    });
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
        // return self.dataViewController;
        return self.controlController;
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
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
