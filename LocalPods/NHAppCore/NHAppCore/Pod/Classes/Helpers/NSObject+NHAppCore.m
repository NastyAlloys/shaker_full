//
//  NSObject+NHAppCore.m
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

#import "NSObject+NHAppCore.h"

@implementation NSObject (NHExtension)

+ (nullable NSData *)jsonDataWithObject:(nullable id)object pretty:(BOOL)pretty {
    if (object
        && [NSJSONSerialization isValidJSONObject:object]) {
        return [NSJSONSerialization dataWithJSONObject:object
                                               options:pretty ? NSJSONWritingPrettyPrinted : 0
                                                 error:nil];
    }
    
    return nil;
}

+ (nullable NSData *)jsonDataWithObject:(nullable id)object {
    return [self jsonDataWithObject:object pretty:NO];
}

- (nullable NSData *)jsonData:(BOOL)pretty {
    return [[self class] jsonDataWithObject:self pretty:pretty];
}

- (nullable NSData *)jsonData {
    return [self jsonData:NO];
}

+ (nullable NSString *)jsonStringWithObject:(nullable id)object pretty:(BOOL)pretty {
    if (object) {
        NSData *jsonData = [self jsonDataWithObject:object pretty:pretty];
        
        if (jsonData) {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
    return nil;
}

+ (nullable NSString *)jsonStringWithObject:(nullable id)object {
    return [self jsonStringWithObject:object pretty:NO];
}

- (NSString *)jsonString:(BOOL)pretty {
    return [[self class] jsonStringWithObject:self pretty:pretty];
}

- (nullable NSString *)jsonString {
    return [self jsonString:NO];
}

@end