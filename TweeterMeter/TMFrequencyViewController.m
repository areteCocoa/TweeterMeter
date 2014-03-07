 //
//  TMFrequencyViewController.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/4/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMFrequencyViewController.h"

@interface TMFrequencyViewController ()

@property (strong, nonatomic) IBOutlet UITableView *wordsTableView;
@property (strong, nonatomic) IBOutlet UITableView *hashtagsTableView;
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;
@property (strong, nonatomic) IBOutlet UITableView *detailTableView;

@property (strong, nonatomic) NSArray *wordsData;
@property (strong, nonatomic) NSArray *hashtagsData;
@property (strong, nonatomic) NSArray *usersData;

@property (strong, nonatomic) NSString *selectedWord;
@property (strong, nonatomic) NSArray *detailData;

@property (nonatomic) NSInteger tableDisplayCount; // How much data do we show in the non-detail tables?
@property (nonatomic) NSInteger detailDisplayCount;

- (NSArray *)dataForTableView: (UITableView *)tableView;
- (NSArray *)getSortedArrayFromDictionary: (NSDictionary *)dictionary;

@end

NSString *kFrequencyCellIdentifier = @"frequencyCell";
NSString *kSelectionCellIdentifier = @"selectionCell";
NSString *kDetailCellIdentifier = @"tweetCell";

@implementation TMFrequencyViewController

@synthesize detailData = _detailData;

- (id)initWithTerm: (TMTerm *)term {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"frequency"];
    
    if (self) {
        _term = term;
        [self.wordsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFrequencyCellIdentifier];
        [self.hashtagsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFrequencyCellIdentifier];
        [self.usersTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFrequencyCellIdentifier];
    }
    
    self.tableDisplayCount = 50;
    self.detailDisplayCount = 50;
    
    return self;
}

- (void)setTerm:(TMTerm *)term {
    _term = term;
    [self updateView];
}

- (void)updateView {
    // update views
    if (self.term) {
        // Load data in the background
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.wordsData = [self getSortedArrayFromDictionary:self.term.popularWords];
            self.usersData = [self getSortedArrayFromDictionary:self.term.popularUsers];
            self.hashtagsData = [self getSortedArrayFromDictionary:self.term.popularTags];
            // Update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.wordsTableView reloadData];
                [self.hashtagsTableView reloadData];
                [self.usersTableView reloadData];
                
                if (self.selectedWord) {
                    [self updateDetailTable];
                }
            });
        });
    }
}

- (void)updateDetailTable {
    if (self.selectedWord) {
        self.detailData =[self.term tweetsWithNumber:self.detailDisplayCount containingString:self.selectedWord];
    }
    
    [self.detailTableView reloadData];
}

- (NSArray *)getSortedArrayFromDictionary: (NSDictionary *)dictionary {
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *key in [dictionary allKeys]) {
        NSDictionary *wordDictionary = [NSDictionary dictionaryWithObjects:@[key, [dictionary objectForKey:key]] forKeys:@[@"string", @"count"]];
        [array addObject:wordDictionary];
    }
    
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[NSDictionary class]] && [obj2 isKindOfClass:[NSDictionary class]]) {
            NSNumber *number1 = [obj1 objectForKey:@"count"];
            NSNumber *number2 = [obj2 objectForKey:@"count"];
            
            if ([number1 integerValue] > [number2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if ([number1 integerValue] < [number2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return array;
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

- (NSArray *)dataForTableView: (UITableView *)tableView {
    NSArray *data;
    if (tableView == self.wordsTableView) {
        data = self.wordsData;
    } else if (tableView == self.hashtagsTableView) {
        data = self.hashtagsData;
    } else if (tableView == self.usersTableView) {
        data = self.usersData;
    }
    
    return data;
}

- (BOOL)tableViewIsDetail: (UITableView *)tableView {
    return (tableView == self.detailTableView);
}

#pragma mark - UITableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    int index = [indexPath indexAtPosition:1];
    
    if (tableView == self.wordsTableView || tableView == self.hashtagsTableView || tableView == self.usersTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:kFrequencyCellIdentifier];
        
        NSArray *dataArray = [self dataForTableView:tableView];
        NSDictionary *data = [dataArray objectAtIndex:[indexPath indexAtPosition:1]];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"count"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"string"]];
        
        cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } else if (tableView == self.detailTableView) {
        TMTweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:kDetailCellIdentifier];
        Tweet *tweet = self.detailData[index];
        
        if (!tweetCell) {
            tweetCell = [[TMTweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDetailCellIdentifier];
        }
        
        [tweetCell loadViewsFromTweet:tweet];
        
        return tweetCell;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.wordsTableView || tableView == self.hashtagsTableView || tableView == self.usersTableView) {
        NSArray *data = [self dataForTableView:tableView];
        int size = data.count;
        
        if (size < self.tableDisplayCount && size > -1) {
            return size;
        }
        
        return self.tableDisplayCount;
    } else if (tableView == self.detailTableView) {
        int size = [self.detailData count];
        
        if (size < self.detailDisplayCount) {
            return size;
        }
        return self.detailDisplayCount;
    }
    
    return 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self tableViewIsDetail:tableView]) {
        // Load example tweets
        NSArray *data = [self dataForTableView:tableView];
        self.selectedWord = [[data objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:@"string"];
        [self updateDetailTable];
    }
    for (UITableView *view in @[self.wordsTableView, self.hashtagsTableView, self.usersTableView]) {
        if (tableView != view) {
            [view deselectRowAtIndexPath:[view indexPathForSelectedRow] animated:YES];
        }
    }
}

@end
