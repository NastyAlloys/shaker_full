//
//  NHParser.m
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import "NHParser.h"
#import "NHRequest.h"
#import "NHModelObject.h"

@implementation NHParser

+ (NSArray*)arrayFromJson:(id)json forClass:(Class<NHModelObject>)objectClass {
    return [self arrayFromJson:json forClass:objectClass sort:NO];
}
+ (NSArray*)arrayFromJson:(id)json forClass:(Class<NHModelObject>)objectClass sort:(BOOL)sort {
    if ([json isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [NSMutableArray new];
        
        [((NSArray*)json) enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                                       NSUInteger idx,
                                                       BOOL * _Nonnull stop) {
            NHModelObject *item = [objectClass convertFromObject:obj];
            
            if (item) {
                [result addObject:item];
            }
        }];
        
        if (sort) {
            [result sortUsingDescriptors:@[[objectClass sortDescriptor]]];
        }
        
        return result;
    }
    
    return @[];
}

+ (NSOrderedSet*)orderedSetFromJson:(id)json forClass:(Class<NHModelObject>)objectClass {
    return [self orderedSetFromJson:json forClass:objectClass sort:NO];
}

+ (NSOrderedSet*)orderedSetFromJson:(id)json forClass:(Class<NHModelObject>)objectClass sort:(BOOL)sort {
    
    if ([json isKindOfClass:[NSArray class]]) {
        NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithArray:[self arrayFromJson:json forClass:objectClass]];
        
        if (sort) {
            [result sortUsingDescriptors:@[[objectClass sortDescriptor]]];
        }
        
        return result;
    }
    
    return [NSOrderedSet new];
}

@end
