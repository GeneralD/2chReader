//
// Created by Yumenosuke Koukata on 12/24/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

@import Foundation;
@import UIKit;
@import WebKit;

#import "KINWebBrowserViewController.h"

@interface KINWebBrowserViewController (MyUtility) <WKUIDelegate>

- (UIView *)webView;

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (void)evaluateJavaScript:(NSString *)script completionHandler:(void (^)(id resultObj, NSError *error))handler;

- (void)setLazyWKUIDelegate;

@end
