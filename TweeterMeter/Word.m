//
//  Word.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/22/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "Word.h"
#import "FrequencyObject.h"

@interface Word()

- (id)initWordWithName:(NSString *)name inContext:(NSManagedObjectContext *)context withType: (NSString *)type;
- (void)findType;
- (NSSet *)invalidStrings;

+ (NSURLSession *)urlSession;

@end

NSString *kBaseURLString = @"https://www.macmillandictionary.com/api/v1/dictionaries/american/search?q=";
NSString *kAccessKey = @"SivOG2y8WD2UhAhpjuUd2FtCHRGmYfsWdSdFNTdo27FtsWALaYdre7ngumxlwdgk";

@implementation Word

@dynamic isHashtag;
@dynamic isUser;
@dynamic isWord;
@dynamic isValid;
@dynamic name;
@dynamic type;
@dynamic frequencyObject;

- (id)initWordWithName: (NSString *)name inContext: (NSManagedObjectContext *)context {
    self = [self initWordWithName:name inContext:context withType:nil];
    
    // Find type
    [self findType];
    
    return self;
}
- (id)initWordWithName:(NSString *)name inContext:(NSManagedObjectContext *)context withType: (NSString *)type {
    self = [Word createWordWithName:name inContext:context];
    self.type = type;
    
    return self;
}

+ (id)createWordWithName: (NSString *)name inContext:(NSManagedObjectContext *)context {
    Word *word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
    word.name = name;
    
    for (NSString *invalid in [word invalidStrings]) {
        if ([word.name rangeOfString:invalid].location != NSNotFound) {
            word.isValid = @0;
        }
    }
    
    char firstChar = [word.name characterAtIndex:0];
    if (firstChar == '#') {
        word.isHashtag = @1;
    } else if (firstChar == '@') {
        word.isUser = @1;
    } else {
        word.isWord = @1;
    }
    
    return word;
}

+ (id)findWordWithName: (NSString *)name inContext: (NSManagedObjectContext *)context {
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
    return word;
}


- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.isValid = @1;
    self.isHashtag = @0;
    self.isUser = @0;
    self.isWord = @0;
}

- (void)findType {
    // Find type from dictionary API
    self.type = nil;
    
    // Using the online API
    /*
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kBaseURLString, self.name];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest addValue:kAccessKey forHTTPHeaderField:@"accessKey"];
    
    // Cache all this
    NSURLSession *session = [Word urlSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (data) {
                                          NSError *jsonError;
                                          NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                          NSArray *results = [dictionary objectForKey:@"results"];
                                          
                                          int enumerator = 0;
                                          while (self.type == nil || enumerator < results.count) {
                                              NSDictionary *object = [results objectAtIndex:enumerator];
                                              NSString *label = [object objectForKey:@"entryLabel"];
                                              NSLog(@"%@", [label substringFromIndex:self.name.length]);
                                          }
                                      }
    }];
    [task resume];
     */
    
    // Lexicon
    /*
    if ([self.name characterAtIndex:0] == 'a' || [self.name characterAtIndex:0] == 'A') {
        Lexicontext *dictionaryContext = [Lexicontext sharedDictionary];
        NSDictionary *word = [dictionaryContext definitionAsDictionaryFor:self.name];
        NSArray *types = [word allKeys];
        // NSLog(@"%@", types);
    }
     */
}

- (NSSet *)invalidStrings {
    static NSSet *invalidStrings = nil;
    
    if (!invalidStrings) {
        invalidStrings = [NSSet set];
        
        TMInvalidStringLoader *stringLoader = [[TMInvalidStringLoader alloc] initWithFileName:@"filter_words.xml"];
        while (stringLoader.isLoadingData);
        invalidStrings = stringLoader.data;
    }
    
    return invalidStrings;
}

+ (NSURLSession *)urlSession {
    static NSURLSession *session;
    
    if (!session) {
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    
    return session;
}

@end
