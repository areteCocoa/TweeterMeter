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

@property (strong, nonatomic) IBOutlet UITableView *wordsTableView;
@property (strong, nonatomic) IBOutlet UITableView *hashtagsTableView;
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;
@property (strong, nonatomic) IBOutlet UITableView *detailTableView;

@property (strong, nonatomic) NSDictionary *wordsData;
@property (strong, nonatomic) NSDictionary *hashtagsData;
@property (strong, nonatomic) NSDictionary *usersData;

@property (strong, nonatomic) NSString *detailData;

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
    
    return self;
}

- (void)setTerm:(TMTerm *)term {
    _term = term;
    [self updateView];
}

- (void)updateView {
    // update views
    if (self.term) {
        self.wordsTextView.text = @"";
        self.hashtagsTextView.text = @"";
        self.usersTextView.text = @"";
        
        int count;
        
        self.wordsData = [self getSortedArrayFromDictionary:self.term.popularWords];
        NSArray *counts = [self.wordsData valueForKey:kFrequency];
        NSArray *words = [self.wordsData valueForKey:kWord];
        for (count = 0; count < counts.count; count ++) {
            self.wordsTextView.text = [self.wordsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [counts objectAtIndex:count], [words objectAtIndex:count]]];
        }
        
        self.usersData = [self getSortedArrayFromDictionary:self.term.popularUsers];
        counts = [self.usersData valueForKey:kFrequency];
        words = [self.usersData valueForKey:kWord];
        for (count = 0; count < counts.count; count ++) {
            self.usersTextView.text = [self.usersTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [counts objectAtIndex:count], [words objectAtIndex:count]]];
        }
        
        self.hashtagsData = [self getSortedArrayFromDictionary:self.term.popularTags];
        counts = [self.hashtagsData valueForKey:kFrequency];
        words = [self.hashtagsData valueForKey:kWord];
        for (count = 0; count < counts.count; count ++) {
            self.hashtagsTextView.text = [self.hashtagsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [counts objectAtIndex:count], [words objectAtIndex:count]]];
        }
        
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
        
        cell.textLabel.text = self.detailData;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.wordsTableView || tableView == self.hashtagsTableView || tableView == self.usersTableView) {
        NSDictionary *data = [self dataForTableView:tableView];
        int size = [[data objectForKey:kFrequency] count];
        
        if (size < 5 && size > -1) {
            return size;
        }
        
        return 5;
    } else if (tableView == self.detailTableView) {
        return 1;
    }
    
    return 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *words = [[self dataForTableView:tableView] objectForKey:kWord];
    self.detailData = [words objectAtIndex:[indexPath indexAtPosition:1]];
    
    [self.detailTableView reloadData];
}

@end
