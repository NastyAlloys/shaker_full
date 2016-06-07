//
//  UIImage+NHAppCore.m
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

@import Accelerate;
#import "UIImage+NHAppCore.h"

#pragma mark - Resize extension

@implementation UIImage (NHExtension)

+ (nullable UIImage *)rescaledImage:(nullable UIImage *)image x:(CGFloat)x y:(CGFloat)y {
    @autoreleasepool {
        
    if (image
        && x
        && y) {
        CGFloat width = MAX(1, round(image.size.width * x));
        CGFloat height = MAX(1, round(image.size.height * y));
        UIImage *resultImage;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, image.scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (context) {
            CGContextTranslateCTM(context,
                                  0.5 * width,
                                  0.5 * height);
            
            CGAffineTransform transform = CGAffineTransformMakeScale(x, y);
            
            CGContextConcatCTM(context, transform);
            
            [image drawInRect:CGRectMake(-0.5 * image.size.width,
                                         -0.5 * image.size.height,
                                         image.size.width,
                                         image.size.height)];
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return image;
    }
}

- (nullable UIImage *)rescaledX:(CGFloat)x y:(CGFloat)y {
    return [[self class] rescaledImage:self x:x y:y];
}

+ (nullable UIImage *)resizedImage:(nullable UIImage *)image toFillSize:(CGSize)size {
    @autoreleasepool {
        CGFloat dX = size.width / image.size.width;
        CGFloat dY = size.height / image.size.height;
        CGFloat scaleValue = MAX(dX, dY);
        UIImage *rescaledImage = [self rescaledImage:image x:scaleValue y:scaleValue];
        UIImage *resultImage;
        
        if (rescaledImage) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, image.scale);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (context) {
                CGFloat width = rescaledImage.size.width;
                CGFloat height = rescaledImage.size.height;
                
                [image drawInRect:CGRectMake(-0.5 * (width - size.width),
                                             -0.5 * (height - size.height),
                                             width,
                                             height)];
                
                resultImage = UIGraphicsGetImageFromCurrentImageContext();
            }
            UIGraphicsEndImageContext();
        }
        
        return resultImage ?: rescaledImage ?: image;
    }
}
- (nullable UIImage *)resizedToFillSize:(CGSize)size {
    return [[self class] resizedImage:self toFillSize:size];
}

+ (UIImage *)resizedImage:(UIImage *)image toFitSize:(CGSize)size {
    CGFloat dX = size.width / image.size.width;
    CGFloat dY = size.height / image.size.height;
    CGFloat scaleValue = MIN(dX, dY);
    return [self rescaledImage:image x:scaleValue y:scaleValue];
}
- (UIImage *)resizedToFitSize:(CGSize)size {
    return [[self class] resizedImage:self toFitSize:size];
}

+ (nullable UIImage *)resizedImage:(nullable UIImage *)image toSize:(CGSize)size {
    @autoreleasepool {
        
    if (image
        && size.width
        && size.height) {
        UIImage *resultImage;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, image.scale);
        
        if (UIGraphicsGetCurrentContext()) {
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return image;
    }
}

- (nullable UIImage *)resizedToSize:(CGSize)size {
    return [[self class] resizedImage:self toSize:size];
}

+ (nullable UIImage *)recoloredImage:(nullable UIImage *)image color:(UIColor *)color  blendMode:(CGBlendMode)blendMode {
    if (image) {
        UIImage *resultImage;
        CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, image.scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (context) {
            CGContextSetFillColorWithColor(context, color.CGColor);
            CGContextTranslateCTM(context, 0, image.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            CGContextSetBlendMode(context, blendMode);
            
            CGContextDrawImage(context, imageRect, image.CGImage);
            
            CGContextClipToMask(context, imageRect, image.CGImage);
            CGContextAddRect(context, imageRect);
            CGContextDrawPath(context, kCGPathFill);
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}

- (nullable UIImage *)recoloredWithColor:(UIColor *)color blendMode:(CGBlendMode)blendMode {
    return [[self class] recoloredImage:self color:color blendMode:blendMode];
}

- (nullable UIImage *)recoloredWithColor:(UIColor *)color {
    return [self recoloredWithColor:color blendMode:kCGBlendModeColor];
}

+ (nullable UIImage *)roundedImage:(nullable UIImage *)image radius:(CGFloat)radius {
    if (image) {
        UIImage *resultImage;
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        
        if (UIGraphicsGetCurrentContext()) {
            [[UIBezierPath bezierPathWithRoundedRect:(CGRect){ .size = image.size }
                                        cornerRadius:radius]
             addClip];
            
            [image drawAtPoint:CGPointZero];
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}

- (nullable UIImage *)roundedImage:(CGFloat)radius {
    return [[self class] roundedImage:self radius:radius];
}

+ (nullable UIImage *)roundedImage:(nullable UIImage *)image corners:(UIRectCorner)corners radius:(CGSize)radius {
    if (image) {
        UIImage *resultImage;
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        
        if (UIGraphicsGetCurrentContext()) {
            [[UIBezierPath bezierPathWithRoundedRect:(CGRect){ .size = image.size }
                                   byRoundingCorners:corners
                                         cornerRadii:radius]
             addClip];
            
            [image drawAtPoint:CGPointZero];
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}

- (nullable UIImage *)roundedImage:(UIRectCorner)corners raduis:(CGSize)radius {
    return [[self class] roundedImage:self corners:corners radius:radius];
}

@end

#pragma mark - Apple blur extension

@implementation UIImage (AppleBlurNHExtension)

#pragma mark - Apple extension

+ (UIImage *)imageByApplyingLightEffectToImage:(UIImage*)inputImage
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self imageByApplyingBlurToImage:inputImage withRadius:60 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


//| ----------------------------------------------------------------------------
+ (UIImage *)imageByApplyingExtraLightEffectToImage:(UIImage*)inputImage
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self imageByApplyingBlurToImage:inputImage withRadius:40 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


//| ----------------------------------------------------------------------------
+ (UIImage *)imageByApplyingDarkEffectToImage:(UIImage*)inputImage
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self imageByApplyingBlurToImage:inputImage withRadius:40 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


//| ----------------------------------------------------------------------------
+ (UIImage *)imageByApplyingTintEffectWithColor:(UIColor *)tintColor toImage:(UIImage*)inputImage
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self imageByApplyingBlurToImage:inputImage withRadius:20 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}

//| ----------------------------------------------------------------------------
+ (UIImage*)imageByApplyingBlurToImage:(UIImage*)inputImage withRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
#define ENABLE_BLUR                     1
#define ENABLE_SATURATION_ADJUSTMENT    1
#define ENABLE_TINT                     1
    
    // Check pre-conditions.
    if (inputImage.size.width < 1 || inputImage.size.height < 1)
    {
        NSLog(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", inputImage.size.width, inputImage.size.height, inputImage);
        return nil;
    }
    if (!inputImage.CGImage)
    {
        NSLog(@"*** error: inputImage must be backed by a CGImage: %@", inputImage);
        return nil;
    }
    if (maskImage && !maskImage.CGImage)
    {
        NSLog(@"*** error: effectMaskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    
    CGImageRef inputCGImage = inputImage.CGImage;
    CGFloat inputImageScale = inputImage.scale;
    CGBitmapInfo inputImageBitmapInfo = CGImageGetBitmapInfo(inputCGImage);
    CGImageAlphaInfo inputImageAlphaInfo = (inputImageBitmapInfo & kCGBitmapAlphaInfoMask);
    
    CGSize outputImageSizeInPoints = inputImage.size;
    CGRect outputImageRectInPoints = { CGPointZero, outputImageSizeInPoints };
    
    // Set up output context.
    BOOL useOpaqueContext;
    if (inputImageAlphaInfo == kCGImageAlphaNone || inputImageAlphaInfo == kCGImageAlphaNoneSkipLast || inputImageAlphaInfo == kCGImageAlphaNoneSkipFirst)
        useOpaqueContext = YES;
    else
        useOpaqueContext = NO;
    UIGraphicsBeginImageContextWithOptions(outputImageRectInPoints.size, useOpaqueContext, inputImageScale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -outputImageRectInPoints.size.height);
    
    if (hasBlur || hasSaturationChange)
    {
        vImage_Buffer effectInBuffer;
        vImage_Buffer scratchBuffer1;
        
        vImage_Buffer *inputBuffer;
        vImage_Buffer *outputBuffer;
        
        vImage_CGImageFormat format = {
            .bitsPerComponent = 8,
            .bitsPerPixel = 32,
            .colorSpace = NULL,
            // (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
            // requests a BGRA buffer.
            .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little,
            .version = 0,
            .decode = NULL,
            .renderingIntent = kCGRenderingIntentDefault
        };
        
        vImage_Error e = vImageBuffer_InitWithCGImage(&effectInBuffer, &format, NULL, inputImage.CGImage, kvImagePrintDiagnosticsToConsole);
        if (e != kvImageNoError)
        {
            NSLog(@"*** error: vImageBuffer_InitWithCGImage returned error code %zi for inputImage: %@", e, inputImage);
            UIGraphicsEndImageContext();
            return nil;
        }
        
        vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, kvImageNoFlags);
        inputBuffer = &effectInBuffer;
        outputBuffer = &scratchBuffer1;
        
#if ENABLE_BLUR
        if (hasBlur)
        {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * inputImageScale;
            if (inputRadius - 2. < __FLT_EPSILON__)
                inputRadius = 2.;
            uint32_t radius = floor((inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);
            
            radius |= 1; // force radius to be odd so that the three box-blur methodology works.
            
            NSInteger tempBufferSize = vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, NULL, 0, 0, radius, radius, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
            void *tempBuffer = malloc(tempBufferSize);
            
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
            
            free(tempBuffer);
            
            vImage_Buffer *temp = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = temp;
        }
#endif
        
#if ENABLE_SATURATION_ADJUSTMENT
        if (hasSaturationChange)
        {
            CGFloat s = saturationDeltaFactor;
            // These values appear in the W3C Filter Effects spec:
            // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/index.html#grayscaleEquivalent
            //
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,                    1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            vImageMatrixMultiply_ARGB8888(inputBuffer, outputBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            
            vImage_Buffer *temp = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = temp;
        }
#endif
        
        CGImageRef effectCGImage;
        if ( (effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, &cleanupBuffer, NULL, kvImageNoAllocate, NULL)) == NULL ) {
            effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, NULL, NULL, kvImageNoFlags, NULL);
            free(inputBuffer->data);
        }
        if (maskImage) {
            // Only need to draw the base image if the effect image will be masked.
            CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
        }
        
        // draw effect image
        CGContextSaveGState(outputContext);
        if (maskImage)
            CGContextClipToMask(outputContext, outputImageRectInPoints, maskImage.CGImage);
        CGContextDrawImage(outputContext, outputImageRectInPoints, effectCGImage);
        CGContextRestoreGState(outputContext);
        
        // Cleanup
        CGImageRelease(effectCGImage);
        free(outputBuffer->data);
    }
    else
    {
        // draw base image
        CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
    }
    
#if ENABLE_TINT
    // Add in color tint.
    if (tintColor)
    {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, outputImageRectInPoints);
        CGContextRestoreGState(outputContext);
    }
#endif
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
#undef ENABLE_BLUR
#undef ENABLE_SATURATION_ADJUSTMENT
#undef ENABLE_TINT
}


//| ----------------------------------------------------------------------------
//  Helper function to handle deferred cleanup of a buffer.
//
void cleanupBuffer(void *userData, void *buf_data)
{ free(buf_data); }


#pragma mark - Instance extension

- (nullable UIImage *)lightEffectImage {
    return [[self class] imageByApplyingLightEffectToImage:self];
}

- (nullable UIImage *)extraLightEffectImage {
    return [[self class] imageByApplyingExtraLightEffectToImage:self];
}

- (nullable UIImage *)darkEffectImage {
    return [[self class] imageByApplyingDarkEffectToImage:self];
}

- (nullable UIImage *)tintEffectImageWithColor:(UIColor *)color {
    return [[self class] imageByApplyingTintEffectWithColor:color toImage:self];
}

- (nullable UIImage *)imageWithBlurRadius:(CGFloat)blurRadius tintColor:(nullable UIColor *)tintColor saturation:(CGFloat)saturation mask:(nullable UIImage *)maskImage {
    return [[self class] imageByApplyingBlurToImage:self withRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturation maskImage:maskImage];
}

@end
