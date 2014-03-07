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

@property (nonatomic, retain) NSOperationQueue *synonymQueue;

- (NSSet *)invalidStrings;
- (NSDictionary *)baseConnotations;

@end

// Access info for macmillandictionary API (UNUSED)
NSString *kBaseURLString = @"https://www.macmillandictionary.com/api/v1/dictionaries/american/search?q=";
NSString *kAccessKey = @"SivOG2y8WD2UhAhpjuUd2FtCHRGmYfsWdSdFNTdo27FtsWALaYdre7ngumxlwdgk";

@implementation Word

@dynamic connotation;
@dynamic definition;
@dynamic isHashtag;
@dynamic isUser;
@dynamic isWord;
@dynamic isValid;
@dynamic name;
@dynamic type;
@dynamic frequencyObject;
@dynamic synonyms;

@synthesize stringLength = _stringLength;
@synthesize isFindingSynonyms;
@synthesize synonymQueue;

- (id)initWordWithName: (NSString *)name inContext: (NSManagedObjectContext *)context {
    self = [self initWordWithName:name inContext:context withConnotation:nil];
    
    return self;
}

// Default initializer -- all other instance initializers point to this
- (id)initWordWithName:(NSString *)name inContext:(NSManagedObjectContext *)context withConnotation: (NSString *)connotation {
    self = [Word createWordWithName:name inContext:context];
    [self fetchDictionaryData];
    
    if (self.isFindingSynonyms && self.synonymQueue) {
        while ([self.synonymQueue operations].count > 0);
    }
    
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
    
    // Filter out non-English words
    /*
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[NSLinguisticTagSchemeLanguage] options:NSLinguisticTaggerOmitOther];
    [tagger setString:word.name];
    NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:nil sentenceRange:nil];
    if ([language isEqualToString:@"en"] && [language isEqualToString:@"und"]) {
        NSLog(@"Non english language: %@", language);
    }
     */
    
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

- (void)awakeFromFetch {
    [super awakeFromFetch];
    
    self.stringLength = self.name.length;
}

- (NSInteger)stringLength {
    if (_stringLength == 0 && self.name.length != 0) {
        _stringLength = self.name.length;
    }
    return _stringLength;
}

- (void)fetchDictionaryData {
    // Find type from dictionary API
    self.type = nil;
    
    // Look up definition, invalidates invalid words
    Lexicontext *dictionaryContext = [Lexicontext sharedDictionary];
    
    
    NSUInteger location = [self.name rangeOfString:@"http"].location;
    if ((self.name.length > 15 && !(location != NSNotFound)) && [self.isWord isEqual:@1]) {
        // this is way too long
        //  NSLog(@"String too long detected: %@", self.name);
    } else if ([dictionaryContext definitionAsDictionaryFor:self.name]) {
        NSDictionary *word = [dictionaryContext definitionAsDictionaryFor:self.name];
        if (word) {
            NSArray *types = [word allKeys];
            if (types.count == 1) {
                self.type = [types firstObject];
            } else if ((!types || types.count == 0) && [self.isWord isEqualToNumber:@1]) {
                self.isValid = @0;
            } else {
                for (NSString *type in types) {
                    if ([type isEqualToString:@"Adjective"]) {
                        // If can be an adjective, default to adjective
                        self.type = type;
                    }
                }
            }
        } else if ([self.isWord isEqualToNumber:@1]) {
            self.isValid = @0;
        }
        
        // Set definition
        self.definition = [[word objectForKey:[[word allKeys] firstObject]] firstObject];
        
        // Find synonyms
        // Only fetch adjective synonyms - this prevents nouns and verbs from "leaking" unwanted connotations over each other
        NSArray *synonymStrings = [[NSSet setWithArray:[[dictionaryContext thesaurusFor:self.name] objectForKey:@"Adjective"]] anyObject];
        for (NSString *synonymString in synonymStrings) {
            Word *synonym = [Word findWordWithName:synonymString inContext:self.managedObjectContext];
            if (!synonym) {
                synonym = [Word createWordWithName:synonymString inContext:self.managedObjectContext];
            }
            [self addSynonymsObject:synonym];
        }
        
        // Find denotation from set of base denotation objects
        NSDictionary *connotations = [self baseConnotations];
        for (NSString *string in [connotations allKeys]) {
            if ([string isEqualToString:self.name]) {
                self.connotation = [connotations objectForKey:string];
            }
        }
        if (self.connotation) {
            // Fetch words with connotations
            NSMutableSet *wordsWithConnotations = [NSMutableSet set];
            
            NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:self.entity.name];
            fetch.predicate = [NSPredicate predicateWithFormat:@"connotation != nil"];
            NSError *error;
            NSArray *results = [self.managedObjectContext executeFetchRequest:fetch error:&error];
            for (Word* word in results) {
                [wordsWithConnotations addObject:word];
            }
            
            self.synonymQueue = [[NSOperationQueue alloc] init];
            self.synonymQueue.maxConcurrentOperationCount = 1;
            
            self.isFindingSynonyms = YES;
            [self setConnotationsOfSynonymsWithSetOfAlreadySet:wordsWithConnotations onOperationQueue:self.synonymQueue];
        }
    }
    
    BOOL printConnotationsNeeded = YES;
    if (printConnotationsNeeded) {
        if (!self.connotation && [self.type isEqualToString:@"Adjective"]) {
            NSLog(@"Word needs connotation: %@", self.name);
        }
    }
}

// Recursive function to find synonyms of similar words
// alreadySet is a set of Words that already have been called by this function
// The set is created before the function is called by sorting words who already have connotations
// in the database. Works on NSOperationQueue so all the branch recursion doesn't create an infinite
// amount of threads.
- (void)setConnotationsOfSynonymsWithSetOfAlreadySet: (NSMutableSet *)alreadySet onOperationQueue: (NSOperationQueue *)queue {
    self.isFindingSynonyms = YES;
    // Initialize our block operation, must wait until finished (no concurrency!)
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^ {
        
        // Filter out all words already having a connotation
        NSSet *synonymsNeedingConnotation = [self.synonyms objectsPassingTest:^BOOL(id obj, BOOL *stop) { // Set of Word objects
            if ([obj isMemberOfClass:[Word class]]) {
                Word *word = (Word *)obj;
                // Don't do anything if we already have a connotation or it has already been set
                if (word.connotation) {
                    return ([word.connotation isEqualToString:@"good"] || [word.connotation isEqualToString:@"bad"]);
                }
                return (word.connotation == nil);
            }
            return NO;
        }];
        synonymsNeedingConnotation = [synonymsNeedingConnotation objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            Word *wordObject = (Word *)obj;
            for (Word *word in alreadySet) {
                if ([word.name isEqualToString:wordObject.name]) {
                    return NO;
                }
            }
            
            return YES;
        }];
        
        
        [alreadySet addObjectsFromArray:[synonymsNeedingConnotation allObjects]];
        
        // If anything is left, do stuff with it
        if (synonymsNeedingConnotation.count > 0) {
            for (Word *word in synonymsNeedingConnotation) {
                word.connotation = self.connotation;
                
                [word setConnotationsOfSynonymsWithSetOfAlreadySet:alreadySet onOperationQueue:queue];
            }
        } else {
            // We're done here
            
        }
        self.isFindingSynonyms = NO;
    }];
    [queue addOperations:@[operation] waitUntilFinished:NO];
}

// Use before creating a word to reduce duplicates and bad punctuated word entries
+ (NSString *)getCorrectWordFromString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    NSString *correctString;
    char firstCharacter = [string characterAtIndex:0];
    if (firstCharacter == '#' || firstCharacter == '@') {
        return string;
    } else {
        // Remove punctuation
        correctString = [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
    }
    
    return correctString;
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

- (NSDictionary *)baseConnotations {
    static NSDictionary *dictionary = nil;
    
    // Data is stored as
    /*  {
            denotation(value): word(key)
     */
    if (!dictionary) {
        dictionary = [NSMutableDictionary dictionary];
        
        TMConnotationLoader *loader = [[TMConnotationLoader alloc] initWithFileName:@"denotations.xml"];
        while (loader.isLoadingData);
        dictionary = loader.data;
    }
    
    return dictionary;
}

@end
