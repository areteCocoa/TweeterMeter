//
//  TMCurrentProcessViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 3/6/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMCurrentProcessViewController.h"

@interface TMCurrentProcessViewController ()

@property (nonatomic, retain) IBOutlet UIView *textView;
@property (nonatomic, retain) IBOutlet UIView *progressView;

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UILabel *beforeLabel;
@property (strong, nonatomic) IBOutlet UILabel *afterLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBarView;

- (void)showLabelView;

@end

@implementation TMCurrentProcessViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"current"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:.5];
    
    self.beforeLabel.text = @"";
    self.afterLabel.text = @"";
    self.label.text = @"";
    self.progressBarView.progress = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showProgressViewWithBeforeValue:(int)beforeValue withAfterValue:(int)afterValue {
    [self setBeforeValue:beforeValue withAfterValue:afterValue];
    self.progressBarView.progress = 0;
    
    [self showProgressView];
}

- (void)setBeforeValue:(int)beforeValue withAfterValue:(int)afterValue {
    self.beforeLabel.text = [NSString stringWithFormat:@"%i", beforeValue];
    self.afterLabel.text = [NSString stringWithFormat:@"%i", afterValue];
}

- (void)setProgressBarProgress:(float)progress {
    self.progressBarView.progress = progress;
}

- (void)showLabelViewWithText: (NSString *)text {
    if (self.textView.isHidden) {
        [self.textView setHidden:NO];
    }
    if (!self.progressView.isHidden) {
        [self.progressView setHidden:YES];
    }
    self.label.text = text;
}

- (void)showLabelView {
    [self.textView setHidden:NO];
    [self.progressView setHidden:YES];
}

- (void)showProgressView {
    [self.textView setHidden:YES];
    [self.progressView setHidden:NO];
}

@end
