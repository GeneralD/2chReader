/*
 * Created by Yumenosuke Koukata on 2/14/14.
 * Copyright (c) 2014 ZYXW. All rights reserved.
 */

#import <UIView+Helpers/UIView+Helpers.h>
#import "UIViewController+MyUtility.h"

@implementation UIViewController (MyUtility)

- (UIView *)containerView {
	return self.view.superview;
}

+ (UIViewController *)topViewController {
	UIViewController *result;
	for (UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController; vc; vc = vc.presentedViewController) result = vc;
	return result;
}

- (UIViewController *)rootViewController {
	UIViewController *result = nil;
	for (UIViewController *vc = self; vc; vc = vc.parentViewController) result = vc;
	return result;
}

- (void)closeSoftwareKeyboard {
	NSArray *subViews = [self.view subviewsOfClass:[UIResponder class] recursive:YES];
	for (UIView *subView in subViews) {
		[subView resignFirstResponder];
	}
}

- (NSArray *)childViewControllersOfClass:(Class)aClass recursive:(BOOL)recursive {
	NSMutableArray *array = [NSMutableArray array];

	for (UIViewController *childViewController in [self childViewControllers]) {
		if ([childViewController isKindOfClass:aClass]) [array addObject:childViewController];
		if (recursive) [array addObjectsFromArray:[childViewController childViewControllersOfClass:aClass recursive:recursive]];
	}
	return array;
}

#pragma mark - IBActions

- (IBAction)backButtonTouchedUp:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
