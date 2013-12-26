//
//  TMDetailViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/21/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TMTerm.h"

@interface TMDetailViewController : UIViewController <UISplitViewControllerDelegate, TMTermDelegate>

@property (strong, nonatomic) TMTerm *term;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *detailNavigationItem;

@end
