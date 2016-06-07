//
//  UIImage+Resize.h
//  Pods
//
//  Created by Sergey Minakov on 14.06.15.
//
//

@import UIKit;


@interface UIImage (NHRecorderResize)

- (UIImage*)nhr_scaleImageByX:(CGFloat)x andY:(CGFloat)y;
- (UIImage*)nhr_rescaleToFit:(CGSize)size;
- (UIImage*)nhr_rescaleToFill:(CGSize)size;

@end