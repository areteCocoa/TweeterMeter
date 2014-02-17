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
#import "FrequencyTag.h"
#import "FrequencyUser.h"
#import "Word.h"

@protocol TMTermDelegate <NSObject>

- (void)tweetsDidUpdate;
- (void)tweetsDidSave;

@end

@interface TMTerm : NSObject

@property (strong, nonatomic) NSString *name;

@property (nonatomic) BOOL displayInvalidWords;
@property (nonatomic) int topStackRefresh; // How long before the top section of the tweet stack should be updated, minutes

@property (strong, nonatomic) NSMutableDictionary *popularWords;
@property (strong, nonatomic) NSMutableDictionary *popularTags;
@property (strong, nonatomic) NSMutableDictionary *popularUsers;

@property id <TMTermDelegate> delegate;

- (id)initTermWithManagedTerm: (Term *)managedTerm withContext:(NSManagedObjectContext *)context;

@end
