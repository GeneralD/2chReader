/*
 * Created by Yumenosuke Koukata on 2/10/14.
 * Copyright (c) 2014 ZYXW. All rights reserved.
 */

@import UIKit;

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Additional)

- (void)setImage:(UIImage *)image forKey:(NSString *)key;

+ (void)setImage:(UIImage *)image forKey:(NSString *)key;

- (UIImage *)imageForKey:(NSString *)key;

+ (UIImage *)imageForKey:(NSString *)key;

- (id)NSCodedForKey:(NSString *)key;

+ (id)NSCodedForKey:(NSString *)key;

- (void)setNSCoded:(id <NSCoding>)obj forKey:(NSString *)key;

+ (void)setNSCoded:(id <NSCoding>)obj forKey:(NSString *)key;

@end
