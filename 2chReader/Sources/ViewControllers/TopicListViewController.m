//
//  Created by Yumenosuke Koukata on 12/21/14.
//  Copyright (c) 2014 ZYXW. All rights reserved.
//

#import "TopicListViewController.h"
#import "TopicCell.h"
#import "FeedItem.h"
#import "UIView+MHNibLoading.h"
#import "KINWebBrowserViewController.h"
#import "KINWebBrowserViewController+MyUtility.h"
#import "KINWebBrowserViewController+AdBlock.h"
#import "KINWebBrowserViewController+AntennaSkipper.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableHeaderView+Initializer.h"
#import "RACSignal+Operations.h"
#import "NSObject+RACSelectorSignal.h"
#import "RACTuple.h"
#import "NSThread+Blocks.h"
#import "NSDate+TimeAgo.h"
#import "NSUserDefaults+Additional.h"
#import "UIViewController+SHSegueBlocks.h"
#import "UITableView+EGORefreshTableHeaderViewHelper.h"
#import "NSURL+Networking.h"
#import "FeedSource.h"

@interface TopicListViewController () <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
@end

@implementation TopicListViewController {
	NSMutableArray *allTopics;
	NSOperationQueue *operationQueue;
	__weak IBOutlet UITableView *tableView;
}

#pragma mark - Inherited Methods

- (void)viewDidLoad {
	[super viewDidLoad];

	// init instance vars
	operationQueue = [NSOperationQueue new];
	operationQueue.maxConcurrentOperationCount = 3;

	[self initTopics];

	// init tableView
	[tableView registerNib:[TopicCell loadNib] forCellReuseIdentifier:@"topicCell"];
	tableView.delegate = self;
	tableView.dataSource = self;
	// init table header
	EGORefreshTableHeaderView *tableHeaderView = [[EGORefreshTableHeaderView alloc] initWithTableView:tableView];
	tableHeaderView.delegate = self;
	[tableHeaderView refreshLastUpdatedDate];
	[tableView addSubview:tableHeaderView];
	// chain
	[[tableView rac_signalForSelector:@selector(reloadData)] subscribeNext:^(RACTuple *args) {
		[NSThread performBlockOnMainThread:^{
			[tableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
		}];
	}];
}

#pragma mark - Private Methods

- (void)initTopics {
	if (allTopics == nil) allTopics = [NSUserDefaults NSCodedForKey:@"loadedTopics"] ?: [NSMutableArray array];
	if (allTopics.count == 0) [self reloadTopics];
}

- (void)reloadTopics {
	[self reloadTopicsCompleted:^(BOOL allFinished) {
		[tableView reloadData];
		if (allFinished) [NSUserDefaults setNSCoded:allTopics forKey:@"loadedTopics"];
	}];
}

- (void)reloadTopicsCompleted:(void (^)(BOOL allFinished))completion { // <--- thread-safe
	// check previous queue ended
	if (operationQueue.operationCount) {
		[tableView.refreshTableHeader egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
		DDLogWarn(@"previous tasks are still running...");
		return;
	}

	// get feed-urls from web
	[[NSURL URLWithString:@"https://www.dropbox.com/s/1r0ns0bzkti0wg4/feed_list.csv?dl=1"] loadCSV:^(MMPCSV *csv, NSError *error) {
		if (error) DDLogError(@"Error: %@", error.localizedDescription);

		// parse CSV
		[[[[[csv format:[MMPCSVFormat defaultFormat].useFirstLineAsKeys.sanitizeFields
		] error:^(NSError *error) {
			DDLogError(@"Error: ", error.localizedDescription);
		}] map:^FeedSource *(NSDictionary *record) {
			return [FeedSource newWithDictionary:record];
		}] filter:^BOOL(FeedSource *source) {
			return [source.url.scheme hasPrefix:@"http"];
		}] each:^(FeedSource *source, NSUInteger index) {
			DDLogVerbose(source.url.absoluteString);

			// wipe topics
			[allTopics removeAllObjects];

			// get contents from web
			[operationQueue addOperation:

					[source.url operationLoadFeed:^(NSDictionary *xmlRoot, NSError *error) {
						if (error) DDLogError(@"Error: %@", error.localizedDescription);

						for (NSDictionary *dictionary in xmlRoot[@"item"]) {
							FeedItem *item = [FeedItem newWithDictionary:dictionary source:source];
							[allTopics addObject:item];

							// sort with pubDate (later comes up)
							[allTopics sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(FeedItem *item1, FeedItem *item2) {
								return [item2.pubDate compare:item1.pubDate];
							}];
						}

						BOOL isFinalOperation = operationQueue.operationCount == 1;
						if (completion)[NSThread performBlockOnMainThread:^{completion(isFinalOperation);}];
					}]];
		}];
	}];
}

#pragma mark - UITableViewDataSource Methods

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return allTopics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topicCell"];
	FeedItem *item = (indexPath.row < allTopics.count) ? allTopics[indexPath.row] : nil;
	cell.titleLabel.text = item.title;
	cell.dateLabel.text = item.pubDate.dateTimeAgo;
	cell.authorLabel.text = item.author;

	static UIColor *originalTextColor;
	if (originalTextColor == nil) originalTextColor = cell.titleLabel.textColor;
	cell.titleLabel.textColor = originalTextColor;

	// change text-color of item marked as read
	NSArray *readList = [NSUserDefaults NSCodedForKey:@"readList"];
	if ([readList containsObject:item.title]) cell.titleLabel.textColor = [UIColor lightGrayColor];

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self SH_performSegueWithIdentifier:@"showWebView" andDestinationViewController:^(UIViewController *theDestinationViewController) {
		KINWebBrowserViewController *webBrowserViewController = theDestinationViewController;
		[webBrowserViewController setLazyWKUIDelegate];
		[webBrowserViewController enableSkippingAntennaSite];
		webBrowserViewController.blockAds = YES;

		// on viewDidLoad
		FeedItem *item = allTopics[indexPath.row];
		[webBrowserViewController loadHTMLString:item.htmlContent baseURL:nil];
		// add to read-list
		NSMutableArray *readList = [NSUserDefaults NSCodedForKey:@"readList"] ?: [NSMutableArray array];
		[readList addObject:item.title];
		[NSUserDefaults setNSCoded:readList forKey:@"readList"];
		// reload a cell on main thread to change its appearance
		[NSThread performBlockOnMainThread:^{
			[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
		}];
	}];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[tableView.refreshTableHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[tableView.refreshTableHeader egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self reloadTopics];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return operationQueue.operationCount != 0;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date];
}

@end
