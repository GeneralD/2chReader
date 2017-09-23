//
// Created by Yumenosuke Koukata on 12/30/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

#import "KINWebBrowserViewController+AntennaSkipper.h"
#import "KINWebBrowserViewController+MyUtility.h"
#import "NSURL+QueryDictionary.h"
#import "NSObject+CJAAssociatedObject.h"

#define STRINGIZE(text) @#text

@implementation NSURL (AntennaSite)

- (BOOL)isAntennaSite {
	NSArray *antennaHosts = [self associatedValueForKey:@"antennaHosts"];
	if (antennaHosts == nil) {
		antennaHosts = @[
				@"giko-news.com",
				@"newpuru.doorblog.jp",
				@"2ch-c.net",
				@"get2ch.net",
				@"newmofu.doorblog.jp",
				@"matomeantena.com",
				@"besttrendnews.net",
				@"2blo.net",
				@"kita-kore.com",
				@"wk-tk.net",
				@"rotco.jp",
				@"www.antennash.com",
				@"uhouho2ch.com",
				@"2channeler.com",
				@"a.anipo.jp",
				@"blog-news.doorblog.jp",
				@"owata.chann.net",
				@"nullpoantenna.com",
				@"damage0.blomaga.jp",
				@"2chfinder.com",
				@"uhouho2ch.com"];
		[self setAssociatedValue:antennaHosts forKey:@"antennaHosts"];
	}

	NSString *host = self.host;
	for (NSString *antennaHost in antennaHosts) {
		if ([host isEqualToString:antennaHost]) return YES;
	}
	return NO;
}

@end

@implementation KINWebBrowserViewController (AntennaSkipper)

#pragma mark - KINWebBrowserDelegate Methods

- (void)enableSkippingAntennaSite {
	[self enableSkippingAntennaSite:nil];
}

- (void)enableSkippingAntennaSite:(id <KINWebBrowserDelegate>)inheritedDelegate {
	[self setAssociatedValue:inheritedDelegate forKey:@"delegate"];
	self.delegate = self;
}

- (void)disableSkippingAntennaSite {
	id <KINWebBrowserDelegate> inheritedDelegate = [self associatedValueForKey:@"delegate"];
	self.delegate = inheritedDelegate;
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didStartLoadingURL:(NSURL *)URL {
	id <KINWebBrowserDelegate> inheritedDelegate = [self associatedValueForKey:@"delegate"];
	[inheritedDelegate webBrowser:webBrowser didStartLoadingURL:URL];
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL {
	id <KINWebBrowserDelegate> inheritedDelegate = [self associatedValueForKey:@"delegate"];
	[inheritedDelegate webBrowser:webBrowser didFinishLoadingURL:URL];

	NSString *title = @"";
	id titleParamVal = URL.uq_queryDictionary[@"title"];
	if ([titleParamVal isKindOfClass:[NSString class]]) {
		title = titleParamVal;
		title = title.stringByRemovingPercentEncoding;
		if (title.length) DDLogDebug(@"searching string “%@” from a-tags", title);
	}
	int skipped = [URL.uq_queryDictionary[@"skipped"] intValue];
	if (skipped) DDLogDebug(@"already skipped antenna-site, avoiding loop");

	NSString *script = [NSString stringWithFormat:
			STRINGIZE(
			// logging function
					var appendedLogs = '';
					function log(text) {appendedLogs += text + '\n'};
					// main codes
					var TITLE_MIN_LENGTH = 8;
					var TITLE_FROM_URL = '%@';
					// fix tricks to all a-tags and search a-tag with text
					var aTags = document.getElementsByTagName('a');
					for (var i = 0; i < aTags.length; i++) {
						var aTag = aTags[i];
						// get text format value from a-tag
						for (var c = aTag.firstChild; c; c = c.nextSibling) {
							if (c.nodeName == '#text') {
								var aText = c.nodeValue;
								// @formatter:off
								aText = aText.replace(/\s+/g, ''); // remove whitespaces
								// @formatter:on
								if (aText.length >= TITLE_MIN_LENGTH) { // <- check has enough length
									// add get-parameter:'title' to href attribute
									var href = aTag.getAttribute('href');
									var symbol = (href.indexOf('?') == -1) ? '?' : '&'; // <- append 'title' param with this symbol
									href += symbol + 'title=' + encodeURI(aText); // <- 'title' param should be % encoded
									aTag.setAttribute('href', href);
									// if previous clicked a-tag's text is same as the aTag's text, jump to the linked site
									if (%d != 1 && TITLE_FROM_URL.length >= TITLE_MIN_LENGTH) { // <- check has enough length
										log('comparing “' + TITLE_FROM_URL + '” and “' + aText + '”.');
										if (aText.indexOf(TITLE_FROM_URL) != -1 || TITLE_FROM_URL.indexOf(aText) != -1) {
											log('found!!');
											window.location.href = aTag.getAttribute('href'); // skip
											aTag.setAttribute('href', href + '&skipped=1'); // add skipped flag
											break;
										}
									}
								}
							}
						}
					}
					appendedLogs;
			), title, skipped];

	[webBrowser evaluateJavaScript:script completionHandler:^(id resultObj, NSError *error) {
		if ([resultObj isKindOfClass:[NSString class]]) {
			NSString *log = resultObj;
			if (log.length) DDLogVerbose(log);
		}
		if (error) DDLogError(@"Error: %@", error);
	}];
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL error:(NSError *)error {
	id <KINWebBrowserDelegate> inheritedDelegate = [self associatedValueForKey:@"delegate"];
	[inheritedDelegate webBrowser:webBrowser didFailToLoadURL:URL error:error];
}

@end
