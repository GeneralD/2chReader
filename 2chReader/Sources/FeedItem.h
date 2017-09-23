//
// Created by Yumenosuke Koukata on 12/22/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

@import Foundation;@class FeedSource;

@interface FeedItem : NSObject
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSString *contentDescription;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *author;
@property(nonatomic, strong) NSDate *pubDate;
@property(nonatomic, strong) NSURL *link;
@property(nonatomic, strong) FeedSource *source;

+ (instancetype)newWithDictionary:(NSDictionary *)dictionary source:(FeedSource *)source;

- (NSString *)htmlContent;

@end
