//
//  TMFrequencyViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMFrequencyViewController.h"

@interface TMFrequencyViewController ()

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

- (void)setTerm:(TMTerm *)term {
    _term = term;
    [self updateView];
}

- (void)updateView {
    // update views
    self.wordsTextView.text = [self.term.popularWords description];
    self.hashtagsTextView.text = [self.term.popularTags description];
    self.usersTextView.text = [self.term.popularUsers description];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
