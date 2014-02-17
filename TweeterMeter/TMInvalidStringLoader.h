//
//  TMInvalidStringLoader.h
//  TweeterMeter
//
//  Created by Thomas Ring on 2/10/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMInvalidStringLoader : NSObject <NSXMLParserDelegate>

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain, readonly) NSXMLParser *parser;
@property (nonatomic, retain) NSSet *data;
@property (nonatomic, retain) NSMutableSet *loadingData;
@property (nonatomic, retain) NSMutableDictionary *currentDictionary;
@property (nonatomic) BOOL isLoadingData;

- (id)initWithFileName: (NSString *)name;

@end