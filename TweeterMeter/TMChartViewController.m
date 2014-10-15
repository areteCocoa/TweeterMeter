//
//  TMChartViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMChartViewController.h"

@interface TMChartViewController ()

@property (nonatomic, retain) NSMutableDictionary *connotationData;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, retain) NSArray *tweetData;

@property (nonatomic) NSInteger numberOfTweetsToDisplay;

@end

NSString *kDetailCellReuse = @"tweetCell";

@implementation TMChartViewController

- (id)initWithTerm: (TMTerm *)term {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"chart"];
    _term = term;
    
    self.connotationData = [NSMutableDictionary dictionary];
    [self.connotationData setObject:@0 forKey:@"good"];
    [self.connotationData setObject:@0 forKey:@"bad"];
    
    [self.detailTableView registerClass:[TMTweetCell class] forCellReuseIdentifier:kDetailCellReuse];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.pieChart setDataSource:self];
    [self.pieChart setDelegate:self];
    [self.pieChart setStartPieAngle:M_2_PI];
    [self.pieChart setAnimationSpeed:1.0];
    [self.pieChart setLabelColor:[UIColor whiteColor]];
    [self.pieChart setLabelFont:[UIFont fontWithName:@"Helvetica" size:24]];
    [self.pieChart setLabelRadius:160];
    [self.pieChart setShowPercentage:YES];
    [self.pieChart setPieBackgroundColor:[UIColor colorWithWhite:1 alpha:.5]];
    [self.pieChart reloadData];
    
    self.detailTableView.backgroundColor = [(TMAppDelegate *)[[UIApplication sharedApplication] delegate] tableBackgroundColor];
    
    // [self.tweetTextView setText:[self.term description]];
    self.numberOfTweetsToDisplay = 50;
    self.selectedIndex = -1;
}

- (void)updateView {
    if (self.term) {
        for (NSString *connotation in [self.connotationData allKeys]) {
            [self.connotationData setObject:[NSNumber numberWithInteger:[self.term numberOfTweetsWithConnotation:connotation]] forKey:connotation];
        }
        
        [self.pieChart reloadData];
        if (self.tweetData.count > 0) {
            [self.detailTableView reloadData];
        }
        
        if (self.selectedIndex != -1) {
            [self.pieChart setSliceSelectedAtIndex:self.selectedIndex];
        }else if (self.tweetData.count == 0) {
            self.tweetData = [self.term newestTweets:self.numberOfTweetsToDisplay];
            [self.detailTableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        
        NSString *selectedConnotation;
        if (_selectedIndex == 0) {
            selectedConnotation = @"good";
        } else if (_selectedIndex == 1) {
            selectedConnotation = @"bad";
        } else if (_selectedIndex == -1) {
            
        }
        
        if (_selectedIndex != -1) {
            self.tweetData = [self.term tweetsWithConnotation:selectedConnotation];
        } else {
            self.tweetData = [self.term newestTweets:self.numberOfTweetsToDisplay];
        }
        
        [self.detailTableView reloadData];
    }
}

#pragma mark - XYPieChartDataSource

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return 2;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    if (index == 0) {
        return [[self.connotationData objectForKey:@"good"] floatValue];
    } else {
        return [[self.connotationData objectForKey:@"bad"] floatValue];
    }
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    if (index == 0) {
        // Good
        return [UIColor colorWithRed:0.1569 green:0.5255 blue:0.3255 alpha:1];
    } else {
        // Bad
        return [UIColor colorWithRed:0.6431 green:0.1490 blue:0.0588 alpha:1];
    }
}

#pragma mark - XYPieChartDelegate

- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
    self.selectedIndex = index;
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
    if (index == self.selectedIndex) {
        self.selectedIndex = -1;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMTweetCell *tweetCell = [self.detailTableView dequeueReusableCellWithIdentifier:kDetailCellReuse];
    
    if (!tweetCell) {
        tweetCell = [[TMTweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDetailCellReuse];
    }
    
    Tweet *tweet = [self.tweetData objectAtIndex:[indexPath indexAtPosition:1]];
    
    [tweetCell loadViewsFromTweet:tweet];
    
    return tweetCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.detailTableView]) {
        int size = self.tweetData.count;
        if (size > self.numberOfTweetsToDisplay) {
            return self.numberOfTweetsToDisplay;
        }
        return size;
    }
    
    return 0;
}

@end
