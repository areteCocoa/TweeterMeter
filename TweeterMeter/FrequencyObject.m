//
//  FrequencyObject.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/22/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "FrequencyObject.h"
#import "Word.h"


@implementation FrequencyObject

@dynamic frequency;
@dynamic name;
@dynamic parentWord;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    if (!self.parentWord) {
        // Initialize a new word
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:[self managedObjectContext]];
        Word *word = [[Word alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
        word.name = self.name;
    }
}

@end
