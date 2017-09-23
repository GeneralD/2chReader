//
// Created by Yumenosuke Koukata on 1/7/15.
// Copyright (c) 2015 ZYXW. All rights reserved.
//

#import "NSMutableArray+MyUtility.h"

@implementation NSMutableArray (MyUtility)

- (void)removeWithBlock:(BOOL(^)(id obj))shouldRemoveBlock {
	NSMutableArray *discardedItems = [NSMutableArray array];
	for (id obj in self) {
		if (shouldRemoveBlock && shouldRemoveBlock(obj)) [discardedItems addObject:obj];
	}
	[self removeObjectsInArray:discardedItems];
}

@end
