/*
 * Created by Yumenosuke Koukata on 8/20/14.
 * Copyright (c) 2014 ZYXW. All rights reserved.
 */

#import <objc/runtime.h>
#import "UIView+Constraint.h"

@implementation UIView (Constraint)

- (void)press {
	for (NSLayoutConstraint *constraint in self.constraints) {
		void const *key = "original constant value";
		objc_setAssociatedObject(constraint, key, @(constraint.constant), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		constraint.constant = .0f;
	}
	void const *key = "is pressed";
	objc_setAssociatedObject(self, key, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)inflate {
	for (NSLayoutConstraint *constraint in self.constraints) {
		void const *key = "original constant value";
		NSNumber *number = objc_getAssociatedObject(constraint, key);
		objc_setAssociatedObject(constraint, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		constraint.constant = number.floatValue;
	}
	void const *key = "is pressed";
	objc_setAssociatedObject(self, key, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isPressed {
	void const *key = "is pressed";
	NSNumber *number = objc_getAssociatedObject(self, key);
	return number.boolValue;
}

@end
