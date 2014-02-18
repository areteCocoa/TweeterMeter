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

@property (strong, nonatomic) NSDictionary *wordsData;
@property (strong, nonatomic) NSDictionary *hashtagsData;
@property (strong, nonatomic) NSDictionary *usersData;

@property (strong, nonatomic) NSString *selectedWord;
@property (strong, nonatomic) NSString *detailData;

@property (nonatomic) NSInteger tableDisplayCount; // How much data do we show in the tables?

- (NSDictionary *)dataForTableView: (UITableView *)tableView;
- (NSDictionary *)getSortedArrayFromDictionary: (NSDictionary *)dictionary;

@end

NSString *kFrequencyCellIdentifier = @"frequencyCell";
NSString *kSelectionCellIdentifier = @"selectionCell";
NSString *kDetailCellIdentifier = @"detailCell";

NSString *kFrequency = @"key";
NSString *kWord = @"value";

@implementation TMFrequencyViewController

- (id)initWithTerm: (TMTerm *)term {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"frequency"];
    
    if (self) {
        _term = term;
        [self.wordsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFrequencyCellIdentifier];
        [self.hashtagsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFrequencyCellIdentifier];
        [self.usersTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFrequencyCellIdentifier];
    }
    
    self.tableDisplayCount = 20;
    
    return self;
}

- (void)setTerm:(TMTerm *)term {
    _term = term;
    [self updateView];
}

- (void)updateView {
    // update views
    if (self.term) {
        self.wordsData = [self getSortedArrayFromDictionary:self.term.popularWords];
        self.usersData = [self getSortedArrayFromDictionary:self.term.popularUsers];
        self.hashtagsData = [self getSortedArrayFromDictionary:self.term.popularTags];
        
        [self.wordsTableView reloadData];
        [self.hashtagsTableView reloadData];
        [self.usersTableView reloadData];
    }
}

- (NSDictionary *)getSortedArrayFromDictionary: (NSDictionary *)dictionary {
    NSDictionary *containerDictionary;
    
    NSMutableArray *unsortedKeys = [[dictionary allKeys] mutableCopy];
    NSArray *sortedValues = [[dictionary allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSMutableArray *matchedKeys = [NSMutableArray array];
    for (int enumerator = 0; enumerator <= [[sortedValues firstObject] intValue]; enumerator ++) {
        NSSet *set = [[dictionary copy] keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
            if ([obj intValue] == enumerator) {
                return YES;
            }
            return NO;
        }];
        for (NSString *string in set) {
            if ([unsortedKeys containsObject:string]) {
                [matchedKeys insertObject:string atIndex:0];
                [unsortedKeys removeObject:string];
            }
        }
    }
    
    containerDictionary = [NSDictionary dictionaryWithObjects:@[matchedKeys, sortedValues] forKeys:@[kWord, kFrequency]];
    
    return containerDictionary;
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

- (NSDictionary *)dataForTableView: (UITableView *)tableView {
    NSDictionary *data;
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
    
    if (tableView == self.wordsTableView || tableView == self.hashtagsTableView || tableView == self.usersTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:kFrequencyCellIdentifier];
        
        int index = [indexPath indexAtPosition:1];
        
        NSDictionary *data = [self dataForTableView:tableView];
        
        NSArray *frequencies = [data objectForKey:kFrequency];
        NSArray *words = [data objectForKey:kWord];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [frequencies objectAtIndex:index]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [words objectAtIndex:index]];
    } else if (tableView == self.detailTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:kDetailCellIdentifier];
        
        cell.textLabel.text = self.selectedWord;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.wordsTableView || tableView == self.hashtagsTableView || tableView == self.usersTableView) {
        NSDictionary *data = [self dataForTableView:tableView];
        int size = [[data objectForKey:kFrequency] count];
        
        if (size < self.tableDisplayCount && size > -1) {
            return size;
        }
        
        return self.tableDisplayCount;
    } else if (tableView == self.detailTableView) {
        return 1;
    }
    
    return 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self tableViewIsDetail:tableView]) {
        // Load example tweets
        NSArray *words = [[self dataForTableView:tableView] objectForKey:kWord];
        self.selectedWord = [words objectAtIndex:[indexPath indexAtPosition:1]];
        
        [self.detailTableView reloadData];
    }
}

@end
