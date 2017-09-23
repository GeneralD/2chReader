//
// Created by Yumenosuke Koukata on 11/22/13.
// Copyright (c) 2013 ZYXW. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface UIView (HierarchyUtility)

- (void)removeAllSubviews;

- (UIView *)rootView;

- (void)removeSubviewsOfClass:(Class)klass;

- (UIView *)firstSubview;

- (CGPoint)absPoint;

- (CGRect)absFrame;

@end
