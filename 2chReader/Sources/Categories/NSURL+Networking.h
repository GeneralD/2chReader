//
// Created by Yumenosuke Koukata on 1/6/15.
// Copyright (c) 2015 ZYXW. All rights reserved.
//

@import Foundation;

#import "MMPCSVUtil.h"

@interface NSURL (Networking)

- (NSOperation *)operationLoadPlainText:(void (^)(NSString *text, NSError *error))loadComped;

- (void)loadPlainText:(void (^)(NSString *text, NSError *error))loadComped;

- (NSOperation *)operationLoadFeed:(void (^)(NSDictionary *xmlRoot, NSError *error))loadComped;

- (void)loadFeed:(void (^)(NSString *xmlRoot, NSError *error))loadComped;

- (NSOperation *)operationLoadCSV:(void (^)(MMPCSV *csv, NSError *error))loadComped;

- (void)loadCSV:(void (^)(MMPCSV *csv, NSError *error))loadComped;

@end
