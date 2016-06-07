//
//  NHKeychain.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN
@interface NHKeychain : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *accessGroup;
@property (nonatomic, copy, readonly, nullable) NSString *service;

- (instancetype)init;
- (instancetype)initWithAccessGroup:(nullable NSString*)accessGroup
                         andService:(nullable NSString*)service;

- (BOOL)removeStringForKey:(NSString *)key error:(NSError **)error;

- (nullable NSString*)stringForKey:(NSString *)key error:(NSError **)error;

- (BOOL)setString:(NSString *)value forKey:(NSString*)key error:(NSError **)error;

- (nullable NSString *)objectForKeyedSubscript:(NSString*)key;
- (void)setObject:(nullable NSString *)obj forKeyedSubscript:(NSString*)key;

@end
NS_ASSUME_NONNULL_END