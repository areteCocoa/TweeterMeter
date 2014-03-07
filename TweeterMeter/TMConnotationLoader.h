//
//  TMDenotationLoader.h
//  TweeterMeter
//
//  Created by Thomas Ring on 3/1/14.
//  Copyright (c) 2014 Thomas Ring. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMConnotationLoader : NSObject <NSXMLParserDelegate>

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain, readonly) NSXMLParser *parser;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic) BOOL isLoadingData;

- (id)initWithFileName: (NSString *)name;

@end
