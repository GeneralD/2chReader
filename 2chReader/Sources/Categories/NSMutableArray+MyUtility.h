//
// Created by Yumenosuke Koukata on 1/7/15.
// Copyright (c) 2015 ZYXW. All rights reserved.
//

@import Foundation;

@interface NSMutableArray (MyUtility)
- (void)removeWithBlock:(BOOL(^)(id obj))shouldRemoveBlock;
@end
