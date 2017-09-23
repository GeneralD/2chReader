//
// Created by Yumenosuke Koukata on 12/11/14.
// Copyright (c) 2014 ZYXW. All rights reserved.
//

#import "YKFile+ReadWrite.h"

@implementation YKFile (ReadWrite)

- (NSData *)data {
	return [NSData dataWithContentsOfURL:self.url];
}

- (void)setData:(NSData *)data {
	[data writeToURL:self.url atomically:YES];
}

- (UIImage *)image {
	return [UIImage imageWithData:self.data];
}

- (void)setImage:(UIImage *)image {
	self.data = UIImagePNGRepresentation(image);
}

- (NSString *)text {
	return [NSString stringWithContentsOfFile:self.fullPath encoding:NSUTF8StringEncoding error:NULL];
}

- (void)setText:(NSString *)text {
	[text writeToFile:self.fullPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

@end
