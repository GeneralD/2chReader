//
// Created by Yumenosuke Koukata on 1/9/15.
// Copyright (c) 2015 ZYXW. All rights reserved.
//

#import "FeedSource.h"

@implementation FeedSource {}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [self init]) {
		_genre = dictionary[@"genre"];
		_name = dictionary[@"name"];
		_url = [NSURL URLWithString:dictionary[@"url"]];
	}
	return self;
}

+ (instancetype)newWithDictionary:(NSDictionary *)dictionary {
	return [[self alloc] initWithDictionary:dictionary];
}

@end
