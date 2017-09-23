//
// Created by Yumenosuke Koukata on 12/22/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

#import "FeedItem.h"
#import "FeedSource.h"

@implementation NSDate (RSSPubDate)

+ (instancetype)dateWithRssDateString:(NSString *)rssDateStr {
	return [[self alloc] initWithRssDateString:rssDateStr];
}

- (instancetype)initWithRssDateString:(NSString *)rssDateStr {
	NSString *dateStr = [rssDateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	dateStr = [dateStr substringWithRange:NSMakeRange(0, 19)];
	dateStr = [NSString stringWithFormat:@"%@ +0000", dateStr];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss zzz";
	return [dateFormatter dateFromString:dateStr];
}
@end

@implementation FeedItem {}

#define STRINGIZE(text) @#text

+ (instancetype)newWithDictionary:(NSDictionary *)dictionary source:(FeedSource *)source {
	FeedItem *instance = [self new];
	instance.title = dictionary[@"title"];
	instance.content = dictionary[@"content"] ?: dictionary[@"content:encoded"];
	instance.contentDescription = dictionary[@"description"];
	instance.subject = dictionary[@"dc:subject"];
	instance.author = dictionary[@"author"] ?: dictionary[@"dc:creator"];
	instance.pubDate = [NSDate dateWithRssDateString:dictionary[@"pubDate"] ?: dictionary[@"dc:date"]];
	instance.link = [NSURL URLWithString:dictionary[@"link"]];
	instance.source = source;
	return instance;
}

- (NSString *)htmlContent {
	return [NSString stringWithFormat:
			STRINGIZE(
					<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
					<html lang="ja">
					<head>
					<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
					<title>%@</title>
					</head>
					<body>%@</body>
					</html>
			), _title, _content ?: _contentDescription];
}

#undef STRINGIZE

@end
