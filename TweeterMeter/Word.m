//
//  Word.m
//  TweeterMeter
//
//  Created by Thomas Ring on 1/22/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "Word.h"
#import "FrequencyObject.h"

@interface TMInvalidStringLoader : NSObject <NSXMLParserDelegate>

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain, readonly) NSXMLParser *parser;
@property (nonatomic, retain) NSSet *data;
@property (nonatomic, retain) NSMutableSet *loadingData;
@property (nonatomic, retain) NSMutableDictionary *currentDictionary;
@property (nonatomic) BOOL isLoadingData;

- (id)initWithFileName: (NSString *)name;

@end

@implementation TMInvalidStringLoader

@synthesize parser = _parser;

- (id)initWithFileName:(NSString *)name {
    self = [super init];
    self.fileName = name;
    self.isLoadingData = YES;
    self.loadingData = [NSMutableSet set];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"filter_strings" withExtension:@"xml"];
    _parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    if(![self.parser parse]) {
        NSLog(@"%@", [self.parser parserError]);
    }
    self.isLoadingData = NO;
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"string"]) {
        [self.loadingData addObject:[attributeDict valueForKey:@"text"]];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.data = [NSSet setWithSet:self.loadingData];
    self.isLoadingData = NO;
}

@end


@interface Word()

- (NSSet *)invalidStrings;
- (BOOL)stringIsValid;

@end

@implementation Word

@dynamic isHashtag;
@dynamic isUser;
@dynamic isWord;
@dynamic isValid;
@dynamic name;
@dynamic type;
@dynamic frequencyObject;

- (id)initWordWithName: (NSString *)name inContext: (NSManagedObjectContext *)context {
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
    
    self = [objects firstObject];
    
    // Create new word
    if (!self) {
        self = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        self.name = name;
        
        self.isValid = @1;
        self.isHashtag = @0;
        self.isUser = @0;
        self.isWord = @0;
        
        for (NSString *invalid in [self invalidStrings]) {
            if ([self.name rangeOfString:invalid].location != NSNotFound) {
                self.isValid = @0;
            }
        }
        
        char firstChar = [name characterAtIndex:0];
        if (firstChar == '#') {
            self.isHashtag = @1;
        } else if (firstChar == '@') {
            self.isUser = @1;
        } else {
            self.isWord = @1;
        }
    }
    
    return self;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    // Retreive definition from API
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

- (BOOL)stringIsValid {
    return YES;
}

+ (void)loadInvalidStrings {
    
}

#pragma mark - NSXMLParserDelegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"Document started!");
}

@end
