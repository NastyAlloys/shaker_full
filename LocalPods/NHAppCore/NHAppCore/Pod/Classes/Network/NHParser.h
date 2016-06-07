//
//  NHParser.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

@import Foundation;

@protocol NHModelObject;

NS_ASSUME_NONNULL_BEGIN

@interface NHParser : NSObject

+ (NSArray*)arrayFromJson:(nullable id)json forClass:(Class<NHModelObject>)objectClass;
+ (NSArray*)arrayFromJson:(nullable id)json forClass:(Class<NHModelObject>)objectClass sort:(BOOL)sort;

+ (NSOrderedSet*)orderedSetFromJson:(nullable id)json forClass:(Class<NHModelObject>)objectClass;
+ (NSOrderedSet*)orderedSetFromJson:(nullable id)json forClass:(Class<NHModelObject>)objectClass sort:(BOOL)sort;

@end

NS_ASSUME_NONNULL_END