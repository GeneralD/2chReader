//
// Created by Yumenosuke Koukata on 12/27/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

@import WebKit;

#import "KINWebBrowserViewController+AdBlock.h"
#import "RegexKitLite.h"
#import "NSObject+CJAAssociatedObject.h"

@implementation NSString (KINWebBrowserViewController_ADBlock)
- (instancetype)shorten {
	static const NSUInteger TOO_LONG = 80;
	if (self.length > TOO_LONG) {
		return [NSString stringWithFormat:@"%@...", [self substringWithRange:NSMakeRange(0, TOO_LONG)]];
	}
	return self;
}
@end

@implementation KINWebBrowserViewController (AdBlock)

- (BOOL)blockAds {
	return [self associatedBoolValueForKey:@selector(blockAds)];
}

- (void)setBlockAds:(BOOL)blockAds {
	[self setAssociatedBoolValue:blockAds forKey:@selector(blockAds)];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
	if (!self.blockAds) {
		decisionHandler(WKNavigationResponsePolicyAllow);
		return;
	}
	// blacklist from ini file
	static NSArray *adUrlRegexs;
	if (adUrlRegexs == nil) adUrlRegexs = self.adUrlRegexs;

	NSHTTPURLResponse *response = (NSHTTPURLResponse *) navigationResponse.response;
	NSString *urlStr = response.URL.absoluteString;
	WKNavigationResponsePolicy policy = WKNavigationResponsePolicyAllow;
	for (NSString *regex in adUrlRegexs) {
		if ([urlStr isMatchedByRegex:regex] || [[urlStr stringByReplacingOccurrencesOfString:@"https" withString:@"http"] isMatchedByRegex:regex]) {
			policy = WKNavigationResponsePolicyCancel;
			DDLogInfo(@"[%@] ignored with regex: %@", urlStr.shorten, regex);
			break;
		}
	}
	if (policy == WKNavigationResponsePolicyAllow) DDLogVerbose(@"[%@] allowed", urlStr.shorten);
	decisionHandler(policy);
}

#pragma mark - Private Methods

- (NSArray *)adUrlRegexs {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"urlfilter" ofType:@"txt"];
	NSString *contText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
	NSArray *lines = [contText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableArray *ret = [NSMutableArray array];
	for (NSString *line in lines) {
		if ([line length] == 0) continue; // empty line
		if ([line hasPrefix:@"#"]) continue; // line is comment line
		// fix regex style
		NSString *regex = [line stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
		regex = [regex stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
		[ret addObject:regex];
	}
	return ret;
}

@end
