/*
 * Created by Yumenosuke Koukata on 2/10/14.
 * Copyright (c) 2014 ZYXW. All rights reserved.
 */

#import "NSUserDefaults+Additional.h"

@implementation NSUserDefaults (Additional)

#pragma mark - UIImage

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
	NSData *data = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
	[self setObject:data forKey:key];
}

+ (void)setImage:(UIImage *)image forKey:(NSString *)key {
	NSData *data = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
	[[self standardUserDefaults] setObject:data forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key {
	NSData *data = [self objectForKey:key];
	return [UIImage imageWithData:data];
}

+ (UIImage *)imageForKey:(NSString *)key {
	return [[self standardUserDefaults] imageForKey:key];
}

#pragma mark - NSCoding

- (id)NSCodedForKey:(NSString *)key {
	NSData *data = [self dataForKey:key];
	if (!data) return nil;
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (id)NSCodedForKey:(NSString *)key {
	return [[self standardUserDefaults] NSCodedForKey:key];
}

- (void)setNSCoded:(id <NSCoding>)obj forKey:(NSString *)key {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
	[self setObject:data forKey:key];
}

+ (void)setNSCoded:(id <NSCoding>)obj forKey:(NSString *)key {
	[[self standardUserDefaults] setNSCoded:obj forKey:key];
}
@end
