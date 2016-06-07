//
//  UIColor+NHAppCore.m
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

#import "UIColor+NHAppCore.h"

extern UIColor *rgb(CGFloat red, CGFloat green, CGFloat blue) {
    return rgba(red, green, blue, 1);
}

extern UIColor *rgba(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

extern UIColor *hex(NSInteger hexColor) {
    return [UIColor colorWithHex:hexColor];
}

@implementation UIColor (NHExtension)

+ (instancetype)colorWithHex:(NSInteger)hexColor {
    CGFloat red = ((hexColor & 0xff0000) >> 16) / 255.0;
    CGFloat green = ((hexColor & 0xff00) >> 8) / 255.0;
    CGFloat blue = (hexColor & 0xff) / 255.0;
    CGFloat alpha = 1;
    
    if (hexColor > 0xffffff) {
        alpha = ((hexColor & 0xff000000) >> 24) / 255.0;
        alpha = roundf(alpha * 100) / 100;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end