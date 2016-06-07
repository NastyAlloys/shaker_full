//
//  NHModelObject.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

@import Foundation;

@class NHModelObject;

NS_ASSUME_NONNULL_BEGIN

@protocol NHModelObject <NSObject>

+ (nullable instancetype)convertFromObject:(nullable id)object NS_SWIFT_NAME(convert(object:));
+ (NSSortDescriptor*)sortDescriptor;

@end

@interface NHModelObject : NSObject<NHModelObject>

@end

NS_ASSUME_NONNULL_END