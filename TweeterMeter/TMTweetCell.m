//
//  TMTweetCell.m
//  TweeterMeter
//
//  Created by Thomas Ring on 3/3/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMTweetCell.h"

@implementation TMTweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
    return self;
}

- (void)loadViewsFromTweet: (Tweet *)tweet {
    self.userNameLabel.text = tweet.userName;
    self.userScreenNameLabel.text = tweet.userScreenName;
    self.contentLabel.text = tweet.text;
    self.idLabel.text = [NSString stringWithFormat:@"%@", tweet.tweetID];
    self.dateLabel.text = [tweet.date description];
    self.connotationLabel.text = tweet.connotation;
    
    if ([tweet.connotation isEqualToString:@"good"]) {
        self.backgroundColor = [UIColor colorWithRed:0.1569 green:0.5255 blue:0.3255 alpha:.2];
    } else if ([tweet.connotation isEqualToString:@"bad"]) {
        self.backgroundColor = [UIColor colorWithRed:0.6431 green:0.1490 blue:0.0588 alpha:.2];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
