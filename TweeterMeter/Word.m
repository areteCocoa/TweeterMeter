//
//  Word.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/22/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "Word.h"
#import "FrequencyObject.h"


@implementation Word

@dynamic isHashtag;
@dynamic isUser;
@dynamic name;
@dynamic type;
@dynamic isWord;
@dynamic frequencyObject;

+ (Word *)fetchWordWithName:(NSString *)name inContext:(NSManagedObjectContext *)context{
    Word *word;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:context];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [fetch setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:fetch error:&error];
    if (error) {
        NSLog(@"Error");
    }
    
    word = [objects firstObject];
    
    // Create new word
    if (!word) {
        word = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        word.name = name;
        // find type of word
        
    }
    
    return word;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    // Retreive definition from API
}

@end
