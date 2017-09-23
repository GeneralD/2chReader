//
// Created by Yumenosuke Koukata on 12/24/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

#import "KINWebBrowserViewController+MyUtility.h"
#import "YKFile+NSDirectories.h"

@implementation YKFile (InstantWrite)
- (void)setText:(NSString *)text {
	NSError *error = nil;
	[text writeToFile:self.fullPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}
@end

@implementation KINWebBrowserViewController (MyUtility)

#pragma mark - Inherited Methods

// This method (overriding) helps initializing from IB.
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		// Copied from initWithConfiguration:
		if ([WKWebView class]) self.wkWebView = [[WKWebView alloc] init];
		else self.uiWebView = [[UIWebView alloc] init];
		self.actionButtonHidden = NO;
		self.showsURLInNavigationBar = NO;
		self.showsPageTitleInNavigationBar = YES;
	}
	return self;
}

#pragma mark - Utility Methods

- (UIView *)webView {
	return self.uiWebView ?: self.wkWebView;
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	if (baseURL) [self.webView performSelector:NSSelectorFromString(@"loadHTMLString:baseURL:") withObject:string withObject:baseURL];
	else {
		YKFile *file = [YKFile temporaryDirectory];
		[file cd:@"FeedItemContent"];
		[file mkdirs];
		[file cd:@"content.html"];
		file.text = string;
		[self.webView performSelector:NSSelectorFromString(@"loadRequest:") withObject:[NSURLRequest requestWithURL:file.url]];
	}
}

- (void)evaluateJavaScript:(NSString *)script completionHandler:(void (^)(id resultObj, NSError *error))handler {
	UIView *webView = self.webView;
	if ([webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		[webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:script withObject:handler];
	} else if ([webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		NSString *result = [webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:script];
		if (handler) handler(result, nil);
	}
}

- (void)setLazyWKUIDelegate {
	self.wkWebView.UIDelegate = self;
}

#pragma mark - WKUIDelegate Methods

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
	if (!navigationAction.targetFrame.isMainFrame) [webView loadRequest:navigationAction.request];
	return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {completionHandler();}]];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {completionHandler(YES);}]];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {completionHandler(NO);}]];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:webView.URL.host preferredStyle:UIAlertControllerStyleAlert];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {textField.text = defaultText;}];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		NSString *input = ((UITextField *) alertController.textFields.firstObject).text;
		completionHandler(input);
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {completionHandler(nil);}]];
	[self presentViewController:alertController animated:YES completion:nil];
}

@end
