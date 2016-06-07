//
//  NHKeychain.m
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import "NHKeychain.h"

#import <UICKeychainStore/UICKeychainStore.h>

@interface NHKeychain ()

@property (nonatomic, copy, nullable) NSString *accessGroup;
@property (nonatomic, copy, nullable) NSString *service;

@end

@implementation NHKeychain

- (instancetype)init {
    return [self initWithAccessGroup:nil andService:nil];
}

- (instancetype)initWithAccessGroup:(nullable NSString*)accessGroup
                         andService:(nullable NSString*)service {
    self = [super init];
    
    if (self) {
        _accessGroup = accessGroup;
        _service = service;
    }
    
    return self;
}

- (BOOL)removeStringForKey:(NSString *)key error:(NSError **)error {
    return [UICKeyChainStore removeItemForKey:key service:[self service] accessGroup:[self accessGroup] error:error];
}

- (nullable NSString*)stringForKey:(NSString *)key error:(NSError **)error {
    return [UICKeyChainStore stringForKey:key service:[self service] accessGroup:[self accessGroup] error:error];
}

- (BOOL)setString:(NSString *)value forKey:(NSString*)key error:(NSError **)error {
    return [UICKeyChainStore setString:value forKey:key service:[self service] accessGroup:[self accessGroup] error:error];
}

- (nullable NSString *)objectForKeyedSubscript:(NSString*)key {
    return [self stringForKey:key error:nil];
}

- (void)setObject:(nullable NSString *)obj forKeyedSubscript:(NSString*)key {
    if (!obj) {
        [self removeStringForKey:key error:nil];
    }
    else {
        [self setString:obj forKey:key error:nil];
    }
}

@end
