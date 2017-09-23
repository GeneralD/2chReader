//
// Created by Yumenosuke Koukata on 11/22/13.
// Copyright (c) 2013 ZYXW. All rights reserved.
//


#import <UIView+Helpers/UIView+Helpers.h>
#import "UIView+HierarchyUtility.h"

@implementation UIView (HierarchyUtility)

- (void)removeAllSubviews {
	NSArray *subViews = [self subviews];
	for (UIView *subView in subViews) {
		[subView removeFromSuperview];
	}
}

- (UIView *)rootView {
	UIView *result = nil;
	for (UIView *v = self; v; v = v.superview) result = v;
	return result;
}

- (void)removeSubviewsOfClass:(Class)klass {
	NSArray *subViews = [self subviewsOfClass:klass recursive:YES];
	for (UIView *subView in subViews) {
		[subView removeFromSuperview];
	}
}

- (UIView *)firstSubview {
	return [[self subviews] firstObject];
}

- (CGPoint)absPoint {
	CGPoint abs = CGPointMake(self.frameOriginX, self.frameOriginY);
	if ([self superview]) {
		CGPoint sup = [[self superview] absPoint];
		abs = CGPointMake(abs.x + sup.x, abs.y + sup.y);
	}
	return abs;
}

- (CGRect)absFrame {
	CGPoint p = [self absPoint];
	return CGRectOffset(self.bounds, p.x, p.y);
}

@end
