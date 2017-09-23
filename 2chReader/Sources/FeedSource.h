//
// Created by Yumenosuke Koukata on 1/9/15.
// Copyright (c) 2015 ZYXW. All rights reserved.
//

@import Foundation;

@interface FeedSource : NSObject
@property(nonatomic, strong) NSString *genre;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSURL *url;

+ (instancetype)newWithDictionary:(NSDictionary *)dictionary;
@end
