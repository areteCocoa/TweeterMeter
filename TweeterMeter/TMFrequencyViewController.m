//
//  TMFrequencyViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMFrequencyViewController.h"

@interface TMFrequencyViewController ()

@property (strong, nonatomic) TMTerm *term;

@property (strong, nonatomic) IBOutlet UITextView *wordsTextView;
@property (strong, nonatomic) IBOutlet UITextView *hashtagsTextView;
@property (strong, nonatomic) IBOutlet UITextView *usersTextView;

@end

@implementation TMFrequencyViewController

- (id)initWithTerm: (TMTerm *)term {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"frequency"];
    self.term = term;
    
    return self;
}

- (void)updateView {
    // update views
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
