//
//  TMTerm.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/23/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Term.h"
#import "FrequencyWord.h"
#import "Word.h"

@protocol TMTermDelegate <NSObject>

- (void)tweetsDidUpdate;
- (void)tweetsDidSave;

@end

@interface TMTerm : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableSet *tweets;

@property (strong, nonatomic) NSMutableDictionary *frequencyWords;
@property (strong, nonatomic) NSMutableDictionary *frequencyTags;
@property (strong, nonatomic) NSMutableDictionary *frequencyUsers;

@property (strong, nonatomic) NSMutableDictionary *popularWords;
@property (strong, nonatomic) NSMutableDictionary *popularTags;
@property (strong, nonatomic) NSMutableDictionary *popularUsers;

@property id <TMTermDelegate> delegate;

- (id)initTermWithManagedTerm: (Term *)managedTerm withContext:(NSManagedObjectContext *)context;

@end
