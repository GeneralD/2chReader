/*
 * Created by Yumenosuke Koukata on 2/14/14.
 * Copyright (c) 2014 ZYXW. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface UIViewController (MyUtility)

- (UIView *)containerView;

+ (UIViewController *)topViewController;

- (UIViewController *)rootViewController;

- (void)closeSoftwareKeyboard;

- (NSArray *)childViewControllersOfClass:(Class)aClass recursive:(BOOL)recursive;

@end
