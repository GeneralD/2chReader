//
// Created by Yumenosuke Koukata on 12/26/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

#import <EGOTableViewPullRefresh/EGORefreshTableHeaderView.h>
#import <UIView+Helpers/UIView+Helpers.h>
#import "UITableView+EGORefreshTableHeaderViewHelper.h"

@implementation UITableView (EGORefreshTableHeaderViewHelper)

- (EGORefreshTableHeaderView *)refreshTableHeader {
	return [self subviewsOfClass:[EGORefreshTableHeaderView class] recursive:YES].firstObject;
}
@end
