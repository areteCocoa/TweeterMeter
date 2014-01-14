//
//  FrequencyWord.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/14/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "FrequencyWord.h"
#import "Term.h"
#import "Word.h"


@implementation FrequencyWord

@dynamic name;
@dynamic frequency;
@dynamic term;
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
