//
//  TMDenotationLoader.m
//  TweeterMeter
//
//  Created by Thomas Ring on 3/1/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import "TMConnotationLoader.h"

@interface TMConnotationLoader()

@property (nonatomic, retain) NSMutableDictionary *loadingData;
@property (nonatomic, retain) NSString *currentDenotationHeader;

@end

@implementation TMConnotationLoader

- (id)initWithFileName:(NSString *)name {
    self = [super init];
    
    self.fileName = name;
    self.isLoadingData = YES;
    self.loadingData = [NSMutableDictionary dictionary];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"connotations" withExtension:@"xml"];
    _parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    if(![self.parser parse]) {
        NSLog(@"%@", [self.parser parserError]);
    }
    
    self.isLoadingData = NO;
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"dict"]) {
        self.currentDenotationHeader = [attributeDict objectForKey:@"connotation"];
    } else if ([elementName isEqualToString:@"word"]) {
        [self.loadingData setObject:self.currentDenotationHeader forKey:[attributeDict valueForKey:@"string"]];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.data = [NSDictionary dictionaryWithDictionary:self.loadingData];
    self.isLoadingData = NO;
}

@end
