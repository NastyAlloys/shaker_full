//
//  UIColor+NHAppCore.h
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

extern UIColor *rgb(CGFloat red, CGFloat green, CGFloat blue);
extern UIColor *rgba(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
extern UIColor *hex(NSInteger hexColor);


@interface UIColor (NHExtension)

+ (instancetype)colorWithHex:(NSInteger)hexColor NS_SWIFT_NAME(init(hexColor:));

@end

NS_ASSUME_NONNULL_END