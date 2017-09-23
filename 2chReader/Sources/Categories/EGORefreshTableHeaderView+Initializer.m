//
// Created by Yumenosuke Koukata on 12/26/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

#import "EGORefreshTableHeaderView+Initializer.h"

@implementation EGORefreshTableHeaderView (Initializer)

- (id)initWithTableView:(UITableView *)tableView {
	CGSize s = tableView.bounds.size;
	return [self initWithFrame:CGRectMake(.0f, .0f - s.height, s.width, s.height)];
}

@end
