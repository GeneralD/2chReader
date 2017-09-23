//
// Created by Yumenosuke Koukata on 1/6/15.
// Copyright (c) 2015 ZYXW. All rights reserved.
//

#import "NSURL+Networking.h"
#import "AFHTTPRequestOperation.h"
#import "AFXMLDictionaryResponseSerializer.h"
#import "YKFile.h"
#import "YKFile+NSDirectories.h"
#import "YKFile+ReadWrite.h"

@implementation NSURL (Networking)

- (NSOperation *)operationLoadPlainText:(void (^)(NSString *text, NSError *error))loadComped {
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:self]];
	operation.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/plain", @"text/html"]];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		if (loadComped) loadComped(text, nil);
	}                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (loadComped) loadComped(nil, error);
	}];
	return operation;
}

- (void)loadPlainText:(void (^)(NSString *text, NSError *error))loadComped {
	[[self operationLoadPlainText:loadComped] start];
}

- (NSOperation *)operationLoadFeed:(void (^)(NSDictionary *xmlRoot, NSError *error))loadComped {
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:self]];
	AFHTTPResponseSerializer <AFURLResponseSerialization> *serializer = [AFXMLDictionaryResponseSerializer serializer];
	NSMutableSet *contentTypes = serializer.acceptableContentTypes.mutableCopy;
	[contentTypes addObjectsFromArray:@[@"application/rss+xml", @"application/atom+xml"]];
	serializer.acceptableContentTypes = contentTypes;
	operation.responseSerializer = serializer;
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (loadComped) loadComped(responseObject, nil);
	}                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (loadComped) loadComped(nil, error);
	}];
	return operation;
}

- (void)loadFeed:(void (^)(NSString *xmlRoot, NSError *error))loadComped {
	[[self operationLoadPlainText:loadComped] start];
}

- (NSOperation *)operationLoadCSV:(void (^)(MMPCSV *csv, NSError *error))loadComped {
	AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)
			[self operationLoadPlainText:^(NSString *text, NSError *error) {
				YKFile *file = [YKFile temporaryDirectory];
				[file cd:self.lastPathComponent];
				file.text = text;
				if (loadComped) loadComped([MMPCSV readURL:file.url], error);
			}];
	operation.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/csv"]];
	return operation;
}

- (void)loadCSV:(void (^)(MMPCSV *csv, NSError *error))loadComped {
	[[self operationLoadCSV:loadComped] start];
}

@end
