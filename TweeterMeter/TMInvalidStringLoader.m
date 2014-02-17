//
//  TMInvalidStringLoader.m
//  TweeterMeter
//
//  Created by Thomas Ring on 2/10/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMInvalidStringLoader.h"

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

