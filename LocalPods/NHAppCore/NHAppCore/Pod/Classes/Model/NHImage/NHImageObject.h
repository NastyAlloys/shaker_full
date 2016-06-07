//
//  NHImageObject.h
//  Pods
//
//  Created by Sergey Minakov on 18.09.15.
//
//

@import UIKit;
#import <AFNetworking/AFNetworking.h>
#import "NHModelObject.h"

@protocol NHImageCache;

typedef NS_ENUM(NSUInteger, NHImageObjectResizeMode) {
    NHImageObjectResizeModeScale,
    NHImageObjectResizeModeFit,
    NHImageObjectResizeModeFill,
    NHImageObjectResizeModeNone,
};

typedef void (^NHImageBlock)(BOOL cached, UIImage * _Nullable image);

NS_ASSUME_NONNULL_BEGIN

@interface NHImageObject : NHModelObject

@property (nonatomic, copy, readonly, nullable) NSString *url;
@property (nonatomic, assign) NHImageObjectResizeMode resizeMode;

+ (id<NHImageCache>)cache;

- (instancetype)initWithObject:(id)object;
+ (nullable NSString *)storageKeyForURL:(NSString *)url;
+ (nullable NSString *)storageKeyForURL:(NSString *)url size:(CGSize)size resizeMode:(NHImageObjectResizeMode)resizeMode;

- (nullable AFHTTPRequestOperation *)loadWithBlock:(NHImageBlock)block;
- (nullable AFHTTPRequestOperation *)loadWithSize:(CGSize)size block:(NHImageBlock)block;

+ (nullable AFHTTPRequestOperation *)loadWithURL:(nullable NSString*)url
                                           block:(NHImageBlock)block;
+ (nullable AFHTTPRequestOperation *)loadWithURL:(nullable  NSString*)url
                                            size:(CGSize)size
                                      resizeMode:(NHImageObjectResizeMode)resizeMode
                                           block:(NHImageBlock)block;

+ (nullable AFHTTPRequestOperation *)loadWithURL:(nullable  NSString*)url
                                           size:(CGSize)size
                                     resizeMode:(NHImageObjectResizeMode)resizeMode
                                       inMemory:(BOOL)inMemory
                                          block:(NHImageBlock)block;

@end

NS_ASSUME_NONNULL_END

//+ (UIImage *)sd_imageWithData:(NSData *)data {
//    if (!data) {
//        return nil;
//    }
//    
//    UIImage *image;
//    NSString *imageContentType = [NSData sd_contentTypeForImageData:data];
//    if ([imageContentType isEqualToString:@"image/gif"]) {
//        image = [UIImage sd_animatedGIFWithData:data];
//    }
//    else {
//        image = [[UIImage alloc] initWithData:data];
//        UIImageOrientation orientation = [self sd_imageOrientationFromImageData:data];
//        if (orientation != UIImageOrientationUp) {
//            image = [UIImage imageWithCGImage:image.CGImage
//                                        scale:image.scale
//                                  orientation:orientation];
//        }
//    }
//    
//    
//    return image;
//}

//+ (UIImage *)sd_animatedGIFWithData:(NSData *)data {
//    if (!data) {
//        return nil;
//    }
//    
//    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
//    
//    size_t count = CGImageSourceGetCount(source);
//    
//    UIImage *animatedImage;
//    
//    if (count <= 1) {
//        animatedImage = [[UIImage alloc] initWithData:data];
//    }
//    else {
//        NSMutableArray *images = [NSMutableArray array];
//        
//        NSTimeInterval duration = 0.0f;
//        
//        for (size_t i = 0; i < count; i++) {
//            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
//            
//            duration += [self sd_frameDurationAtIndex:i source:source];
//            
//            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
//            
//            CGImageRelease(image);
//        }
//        
//        if (!duration) {
//            duration = (1.0f / 10.0f) * count;
//        }
//        
//        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
//    }
//    
//    CFRelease(source);
//    
//    return animatedImage;
//}
