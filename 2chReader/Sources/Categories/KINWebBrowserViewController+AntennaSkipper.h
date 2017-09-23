//
// Created by Yumenosuke Koukata on 12/30/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

@import Foundation;

#import "KINWebBrowserViewController.h"

@interface KINWebBrowserViewController (AntennaSkipper) <KINWebBrowserDelegate>

- (void)enableSkippingAntennaSite;

- (void)enableSkippingAntennaSite:(id <KINWebBrowserDelegate>)inheritedDelegate;

- (void)disableSkippingAntennaSite;

@end
