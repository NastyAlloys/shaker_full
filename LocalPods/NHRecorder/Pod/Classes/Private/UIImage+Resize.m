//
//  UIImage+Resize.m
//  Pods
//
//  Created by Sergey Minakov on 14.06.15.
//
//

#import "UIImage+Resize.h"

@implementation UIImage (NHRecorderResize)

- (UIImage*)nhr_scaleImageByX:(CGFloat)x andY:(CGFloat)y {
    
    if (self) {
        CGFloat width = MAX(1, round(self.size.width * x));
        CGFloat height = MAX(1, round(self.size.height * y));
        UIImage *resultImage;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (context) {
            CGContextTranslateCTM(context,
                                  0.5 * width,
                                  0.5 * height);
            
            CGAffineTransform transform = CGAffineTransformMakeScale(x, y);
            
            CGContextConcatCTM(context, transform);
            
            [self drawInRect:CGRectMake(-0.5 * self.size.width,
                                        -0.5 * self.size.height,
                                        self.size.width,
                                        self.size.height)];
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}
- (UIImage*)nhr_rescaleToFit:(CGSize)size {
    CGFloat dX = size.width / self.size.width;
    CGFloat dY = size.height / self.size.height;
    CGFloat scaleValue = MIN(dX, dY);
    return [self nhr_scaleImageByX:scaleValue andY:scaleValue];
}
- (UIImage*)nhr_rescaleToFill:(CGSize)size {
    CGFloat dX = size.width / self.size.width;
    CGFloat dY = size.height / self.size.height;
    CGFloat scaleValue = MAX(dX, dY);
    return [self nhr_scaleImageByX:scaleValue andY:scaleValue];
}

@end