//
//  TMCreateTermViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 3/5/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMCreateTermViewController.h"

@interface TMCreateTermViewController ()

@property (nonatomic, retain) Term *term;

@end

@implementation TMCreateTermViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTerm: (Term *)term {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"create"];
    self.term = term;
    
    self.isStillRunning = YES;
    
    self.view.backgroundColor = [(TMAppDelegate *)[[UIApplication sharedApplication] delegate] backgroundColor];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.nameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTouchButton:(id)sender {
    [self goAway];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self shouldGoAway]) {
        [self.nameTextField resignFirstResponder];
    }
    
    [self goAway];
    
    return YES;
}

- (void)goAway {
    if ([self shouldGoAway]) {
        self.term.name = self.nameTextField.text;
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate createViewControllerWillDismiss];
    }
}

- (BOOL)shouldGoAway {
    return ![self.nameTextField.text isEqualToString:@""];
}

@end
