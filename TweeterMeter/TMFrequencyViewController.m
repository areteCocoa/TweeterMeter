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
    _term = term;
    
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
        
        NSDictionary *sortedPopularWords = [self getSortedArrayFromDictionary:self.term.popularWords];
        NSArray *counts = [sortedPopularWords valueForKey:@"values"];
        NSArray *words = [sortedPopularWords valueForKey:@"keys"];
        for (count = 0; count < counts.count; count ++) {
            self.wordsTextView.text = [self.wordsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [counts objectAtIndex:count], [words objectAtIndex:count]]];
        }
        
        sortedPopularWords = [self getSortedArrayFromDictionary:self.term.popularUsers];
        counts = [sortedPopularWords valueForKey:@"values"];
        words = [sortedPopularWords valueForKey:@"keys"];
        for (count = 0; count < counts.count; count ++) {
            self.usersTextView.text = [self.usersTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [counts objectAtIndex:count], [words objectAtIndex:count]]];
        }
        
        sortedPopularWords = [self getSortedArrayFromDictionary:self.term.popularTags];
        counts = [sortedPopularWords valueForKey:@"values"];
        words = [sortedPopularWords valueForKey:@"keys"];
        for (count = 0; count < counts.count; count ++) {
            self.hashtagsTextView.text = [self.hashtagsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [counts objectAtIndex:count], [words objectAtIndex:count]]];
        }
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
    
    containerDictionary = [NSDictionary dictionaryWithObjects:@[matchedKeys, sortedValues] forKeys:@[@"keys", @"values"]];
    
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

@end
