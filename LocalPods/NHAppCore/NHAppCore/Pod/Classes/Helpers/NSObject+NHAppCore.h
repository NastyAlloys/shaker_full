//
//  NSObject+NHAppCore.h
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

@import Foundation;

#define clamp(x, low, high) (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

#define is(instance, Type) \
[instance isKindOfClass:[Type class]]

#define as(instance, Type) \
((Type*)([instance isKindOfClass:[Type class]] ? instance : nil))

#define isNSNull(x) \
([x isKindOfClass:[NSNull class]])

#define ifNSNull(x, y) \
([x isKindOfClass:[NSNull class]]) ? y : (x ?: y)

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (NHExtension)

+ (nullable NSData *)jsonDataWithObject:(nullable id)object pretty:(BOOL)pretty;
+ (nullable NSData *)jsonDataWithObject:(nullable id)object;
- (nullable NSData *)jsonData:(BOOL)pretty;
- (nullable NSData *)jsonData;

+ (nullable NSString *)jsonStringWithObject:(nullable id)object pretty:(BOOL)pretty;
+ (nullable NSString *)jsonStringWithObject:(nullable id)object;
- (nullable NSString *)jsonString:(BOOL)pretty;
- (nullable NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END