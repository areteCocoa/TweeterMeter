//
//  TMTweetCell.h
//  TweeterMeter
//
//  Created by Thomas Ring on 3/3/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface TMTweetCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UILabel *idLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *connotationLabel;

- (void)loadViewsFromTweet: (Tweet *)tweet;

@end
