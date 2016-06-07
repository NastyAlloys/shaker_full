//
//  UIImage+NHAppCore.h
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//
//  Blur based on: https://developer.apple.com/library/ios/samplecode/UIImageEffects/

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (NHExtension)

+ (nullable UIImage *)rescaledImage:(nullable UIImage *)image x:(CGFloat)x y:(CGFloat)y;
- (nullable UIImage *)rescaledX:(CGFloat)x y:(CGFloat)y;

+ (nullable UIImage *)resizedImage:(nullable UIImage *)image toFillSize:(CGSize)size;
- (nullable UIImage *)resizedToFillSize:(CGSize)size;

+ (nullable UIImage *)resizedImage:(nullable UIImage *)image toFitSize:(CGSize)size;
- (nullable UIImage *)resizedToFitSize:(CGSize)size;

+ (nullable UIImage *)resizedImage:(nullable UIImage *)image toSize:(CGSize)size;
- (nullable UIImage *)resizedToSize:(CGSize)size;

+ (nullable UIImage *)recoloredImage:(nullable UIImage *)image color:(UIColor *)color blendMode:(CGBlendMode)blendMode;
- (nullable UIImage *)recoloredWithColor:(UIColor *)color blendMode:(CGBlendMode)blendMode;
- (nullable UIImage *)recoloredWithColor:(UIColor *)color;


+ (nullable UIImage *)roundedImage:(nullable UIImage *)image radius:(CGFloat)radius;
- (nullable UIImage *)roundedImage:(CGFloat)radius;

+ (nullable UIImage *)roundedImage:(nullable UIImage *)image corners:(UIRectCorner)corners radius:(CGSize)radius;
- (nullable UIImage *)roundedImage:(UIRectCorner)corners raduis:(CGSize)radius;

@end

@interface UIImage (AppleBlurNHExtension)

+ (nullable UIImage *)imageByApplyingLightEffectToImage:(nullable UIImage *)inputImage;
+ (nullable UIImage *)imageByApplyingExtraLightEffectToImage:(nullable UIImage *)inputImage;
+ (nullable UIImage *)imageByApplyingDarkEffectToImage:(nullable UIImage *)inputImage;
+ (nullable UIImage *)imageByApplyingTintEffectWithColor:(UIColor *)tintColor toImage:(nullable UIImage *)inputImage;

//| ----------------------------------------------------------------------------
//! Applies a blur, tint color, and saturation adjustment to @a inputImage,
//! optionally within the area specified by @a maskImage.
//!
//! @param  inputImage
//!         The source image.  A modified copy of this image will be returned.
//! @param  blurRadius
//!         The radius of the blur in points.
//! @param  tintColor
//!         An optional UIColor object that is uniformly blended with the
//!         result of the blur and saturation operations.  The alpha channel
//!         of this color determines how strong the tint is.
//! @param  saturationDeltaFactor
//!         A value of 1.0 produces no change in the resulting image.  Values
//!         less than 1.0 will desaturation the resulting image while values
//!         greater than 1.0 will have the opposite effect.
//! @param  maskImage
//!         If specified, @a inputImage is only modified in the area(s) defined
//!         by this mask.  This must be an image mask or it must meet the
//!         requirements of the mask parameter of CGContextClipToMask.
+ (nullable UIImage *)imageByApplyingBlurToImage:(nullable UIImage *)inputImage withRadius:(CGFloat)blurRadius tintColor:(nullable UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(nullable UIImage *)maskImage;


- (nullable UIImage *)lightEffectImage;
- (nullable UIImage *)extraLightEffectImage;
- (nullable UIImage *)darkEffectImage;
- (nullable UIImage *)tintEffectImageWithColor:(UIColor *)color;
- (nullable UIImage *)imageWithBlurRadius:(CGFloat)blurRadius tintColor:(nullable UIColor *)tintColor saturation:(CGFloat)saturation mask:(nullable UIImage *)maskImage;
@end

NS_ASSUME_NONNULL_END