//
//  TMCreateTermViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 3/5/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Term.h"
#import "TMAppDelegate.h"

@protocol TMCreateTermViewControllerDelegate <NSObject>

- (void)createViewControllerWillDismiss;

@end

@interface TMCreateTermViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) BOOL isStillRunning;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic) id <TMCreateTermViewControllerDelegate> delegate;

- (id)initWithTerm: (Term *)term;

@end
