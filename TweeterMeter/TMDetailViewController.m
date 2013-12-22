//
//  TMDetailViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 12/21/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import "TMDetailViewController.h"

@interface TMDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation TMDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.navigationItem.title = [[self.detailItem valueForKey:@"term"] description];
        
        __block NSString *detailString;
        
        ACAccountStore *store = [[ACAccountStore alloc] init];
        if ([SLComposeViewController
             isAvailableForServiceType:SLServiceTypeTwitter]) {
            
            //  Step 1:  Obtain access to the user's Twitter accounts
            ACAccountType *twitterAccountType =
            [store accountTypeWithAccountTypeIdentifier:
             ACAccountTypeIdentifierTwitter];
            
            [store
             requestAccessToAccountsWithType:twitterAccountType
             options:NULL
             completion:^(BOOL granted, NSError *error) {
                 if (granted) {
                     //  Step 2:  Create a request
                     NSArray *twitterAccounts =
                     [store accountsWithAccountType:twitterAccountType];
                     NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                                   @"/1.1/statuses/user_timeline.json"];
                     NSDictionary *params = @{@"screen_name" : @"thomasjring",
                                              @"include_rts" : @"0",
                                              @"trim_user" : @"1",
                                              @"count" : @"1"};
                     SLRequest *request =
                     [SLRequest requestForServiceType:SLServiceTypeTwitter
                                        requestMethod:SLRequestMethodGET
                                                  URL:url
                                           parameters:params];
                     
                     //  Attach an account to the request
                     [request setAccount:[twitterAccounts lastObject]];
                     
                     //  Step 3:  Execute the request
                     [request performRequestWithHandler:
                      ^(NSData *responseData,
                        NSHTTPURLResponse *urlResponse,
                        NSError *error) {
                          
                          if (responseData) {
                              if (urlResponse.statusCode >= 200 &&
                                  urlResponse.statusCode < 300) {
                                  
                                  NSError *jsonError;
                                  NSDictionary *timelineData =
                                  [NSJSONSerialization
                                   JSONObjectWithData:responseData
                                   options:NSJSONReadingAllowFragments error:&jsonError];
                                  if (timelineData) {
                                      detailString = [[NSString stringWithFormat:@"%@", timelineData] description];
                                      NSLog(@"Timeline Response: %@\n", detailString);
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.detailDescriptionLabel.text = detailString;
                                      });
                                  }
                                  else {
                                      // Our JSON deserialization went awry
                                      NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                                  }
                              }
                              else {
                                  // The server did not respond ... were we rate-limited?
                                  NSLog(@"The response status code is %d",
                                        urlResponse.statusCode);
                              }
                          }
                      }];
                 }
                 else {
                     // Access was not granted, or an error occurred
                     NSLog(@"%@", [error localizedDescription]);
                 }
             }];
        }
        
        self.detailDescriptionLabel.text = detailString;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Update modal with newer tweets
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
