//
//  TMTermControlViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 9/19/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMTermControlViewController.h"

@interface TMTermControlViewController ()

@end

@implementation TMTermControlViewController

- (id)initWithTerm:(TMTerm *)term {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"controller"];
    
    _term = term;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [((TMAppDelegate *)[[UIApplication sharedApplication] delegate]) backgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(UIButton *)sender {
    NSString *action = [sender.titleLabel.text lowercaseString];
    NSLog(@"Action %@ sent to term controller", action);
    
    if ([action isEqualToString:@"start"]) {
        [self startFetchingTweets];
    } else if ([action isEqualToString:@"stop"]) {
        [self stopFetchingTweets];
    } else {
        NSLog(@"Action unhandled (unknown): %@", action);
    }
}

- (void)clearTweets {
    [self.term clearAllTweets];
}

- (void)stopFetchingTweets {
    [self.term stopFetchingTweets];
}

- (void)startFetchingTweets {
    [self.term startFetchingTweets];
}

- (void)isFetchingTweets {
    [self.term isFetchingTweets];
}

@end
