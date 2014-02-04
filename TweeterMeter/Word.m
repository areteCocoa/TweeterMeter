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
@dynamic isWord;
@dynamic isValid;
@dynamic name;
@dynamic type;
@dynamic frequencyObject;

+ (Word *)fetchWordWithName:(NSString *)name inContext:(NSManagedObjectContext *)context{
    Word *word;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:context];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [fetch setPredicate:predicate];
    
    NSError *error;
    NSArray *objects;
    @try {
        objects = [context executeFetchRequest:fetch error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    
    if (error) {
        NSLog(@"Error");
    }
    
    word = [objects firstObject];
    
    // Create new word
    if (!word) {
        word = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        word.name = name;
        
        word.isValid = @1;
        word.isHashtag = @0;
        word.isUser = @0;
        word.isWord = @0;
        
        char firstChar = [name characterAtIndex:0];
        if ( firstChar == '\\' ) {
            word.isValid = @0;
        } else if (firstChar == '#') {
            word.isHashtag = @1;
        } else if (firstChar == '@') {
            word.isUser = @1;
        } else {
            word.isWord = @1;
        }
        // find type of word
        
    }
    
    if ([name characterAtIndex:0] == '@') {
        word.isUser = @1;
    } else if ([name characterAtIndex:0] == '#') {
        word.isHashtag = @1;
    }
    
    return word;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    // Retreive definition from API
}

@end
