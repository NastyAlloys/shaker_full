//
//  NHCameraImageCropView.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHPhotoView.h"

#import <GPUImage/GPUImage.h>

@interface NHPhotoView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) GPUImageView *contentView;
@property (nonatomic, strong) GPUImagePicture *picture;

@property (nonatomic, strong) GPUImageFilter *rotationFilter;
@property (nonatomic, strong) GPUImageFilter *customFilter;
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;

@property (nonatomic, strong) NHCameraCropView *cropView;

@end

@implementation NHPhotoView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage*)image {
    return [self initWithFrame:CGRectZero image:image];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame image:nil];
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image {
    self = [super initWithFrame:frame];
    
    if (self) {
        _image = image;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.scrollsToTop = NO;
    self.delegate = self;
    self.bounces = YES;
    self.alwaysBounceVertical = NO;
    self.alwaysBounceHorizontal = NO;
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 5;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView = [[GPUImageView alloc] init];
    [self addSubview:self.contentView];
    
    self.picture = [[GPUImagePicture alloc] initWithImage:self.image smoothlyScaleOutput:NO];
    self.rotationFilter = [[GPUImageFilter alloc] init];
    self.customFilter = [[GPUImageFilter alloc] init];
    self.cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];
    
    GPUImageRotationMode newRotation = kGPUImageNoRotation;
    
    switch (self.image.imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            newRotation = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            newRotation = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            newRotation = kGPUImageRotate180;
            break;
        default:
            break;
    }
    [self.rotationFilter setInputRotation:newRotation atIndex:0];
    
    [self.picture addTarget:self.rotationFilter];
    [self.rotationFilter addTarget:self.customFilter];
    [self.customFilter addTarget:self.cropFilter];
    
    [self.customFilter addTarget:self.contentView];
    
    [self sizeContent];
    if (self.window) {
        [self.picture processImage];
    }
    
    self.cropView = [[NHCameraCropView alloc] init];
    self.cropView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cropView.userInteractionEnabled = NO;
    self.cropView.backgroundColor = [UIColor clearColor];
    self.cropView.showBorder = YES;
    self.cropView.cropBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

//MARK: setup

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self.cropView removeFromSuperview];
}

- (void)didMoveToSuperview {
        [self.superview addSubview:self.cropView];
        [self setupCropViewConstraints];

}
- (void)setupCropViewConstraints {
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0 constant:0]];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0 constant:0]];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:0]];
}

- (void)setCropType:(NHPhotoCropType)type {
    [self.cropView setCropType:type];
    
    [self resetCropAnimated:YES];
    [self scrollViewDidZoom:self];
}

- (void)setFilter:(GPUImageFilter*)filter {
    [self.customFilter removeAllTargets];
    [self.customFilter removeOutputFramebuffer];
    
    [self.rotationFilter removeTarget:self.customFilter];
    self.customFilter = filter;
    
    [self.customFilter removeAllTargets];
    [self.customFilter removeOutputFramebuffer];
    
    [self.rotationFilter addTarget:self.customFilter];
    [self.customFilter addTarget:self.cropFilter];
    
    [self.customFilter addTarget:self.contentView];
    
    if (self.window) {
        [self.customFilter useNextFrameForImageCapture];
        [self.picture processImage];
    }
}

- (void)sizeContent {
    CGRect bounds = self.image ? (CGRect) { .size = self.image.size } : self.contentView.frame;
    
    if (bounds.size.height) {
        CGFloat ratio = bounds.size.width / bounds.size.height;
        
        if (ratio) {
            
            if (ratio > 1.05) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.height = bounds.size.width / ratio;
                    
                }
                else {
                    bounds.size.width = MAX(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.height = bounds.size.width / ratio;
                    
                }
            }
            else if (ratio < 0.95) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.height = MAX(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.width = bounds.size.height * ratio;
                }
                else {
                    bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.width = bounds.size.height * ratio;
                }
            }
            else {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.height = bounds.size.width / ratio;
                }
                else {
                    bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.width = bounds.size.height * ratio;
                }
            }
        }
    }
    
    if (!CGRectEqualToRect(self.contentView.bounds, bounds)) {
        
        [self.customFilter removeTarget:self.contentView];
        self.contentView.frame = bounds;
        [self.customFilter addTarget:self.contentView];
        
        self.contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        self.contentSize = CGSizeZero;
        
        [self resetCropAnimated:NO];
        
        [self scrollViewDidZoom:self];
    }
    
    if (self.window) {
        [self.picture processImage];
    }
}

- (void)resetCropAnimated:(BOOL)animated {

    self.cropView.maxCropSize = CGSizeMake(MIN(self.bounds.size.width, self.bounds.size.height) - 30,
                                           self.bounds.size.height - 30);
    
    [self.cropView resetCrop];

    CGFloat newValue = 1;
    
    if (self.cropView.cropType != NHPhotoCropTypeNone) {
        if (self.cropView.cropRect.size.width > 0
            && self.cropView.cropRect.size.height > 0) {
            CGFloat widthZoom = self.cropView.cropRect.size.width / self.contentView.bounds.size.width;
            CGFloat heightZoom = self.cropView.cropRect.size.height / self.contentView.bounds.size.height;
            
            if (self.cropView.cropRect.size.height > self.contentView.bounds.size.height) {
                newValue = heightZoom;
            }
            else if (self.cropView.cropRect.size.width > self.contentView.bounds.size.width) {
                newValue = widthZoom;
            }
            else {
                newValue = MAX(widthZoom, heightZoom);
            }
        }
    }

    self.minimumZoomScale = newValue;
    [self setZoomScale:newValue animated:animated];
    [self scrollViewDidZoom:self];
}

- (void)processImageWithBlock:(void(^)(UIImage *image))block {
    self.cropFilter.cropRegion = [self.cropView cropRegionForView:self.contentView];

    [self.picture processImageUpToFilter:self.cropFilter
                   withCompletionHandler:^(UIImage *processedImage) {
                       if (block) {
                           block(processedImage);
                       }
                   }];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    
    CGSize zoomedSize = self.contentView.bounds.size;
    zoomedSize.width *= self.zoomScale;
    zoomedSize.height *= self.zoomScale;
    
    CGFloat verticalOffset = 0;
    CGFloat horizontalOffset = 0;
    
    if (zoomedSize.height < self.bounds.size.height) {
        verticalOffset = (self.bounds.size.height - zoomedSize.height) / 2.0;
    }
    
    if (zoomedSize.width < self.bounds.size.width) {
        horizontalOffset = (self.bounds.size.width - zoomedSize.width) / 2.0;
    }
    
    CGFloat cropVerticalOffset = 0;
    CGFloat cropHorizontalOffset = 0;

    if (self.cropView.cropType != NHPhotoCropTypeNone
        && self.cropView.cropRect.size.width > 0
        && self.cropView.cropRect.size.height > 0) {
        cropVerticalOffset = (self.bounds.size.height - self.cropView.cropRect.size.height) / 2 - verticalOffset;
        cropHorizontalOffset = (self.bounds.size.width - self.cropView.cropRect.size.width) / 2 - horizontalOffset;
    }
    
    self.contentSize = self.contentView.frame.size;
    
    self.contentInset = UIEdgeInsetsMake(verticalOffset - self.contentView.frame.origin.y + cropVerticalOffset,
                                         horizontalOffset - self.contentView.frame.origin.x + cropHorizontalOffset,
                                         verticalOffset + self.contentView.frame.origin.y + cropVerticalOffset,
                                         horizontalOffset + self.contentView.frame.origin.x + cropHorizontalOffset);
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)dealloc {
    [self.cropFilter removeAllTargets];
    [self.customFilter removeAllTargets];
    [self.rotationFilter removeAllTargets];
    [self.picture removeAllTargets];
    
    self.cropFilter = nil;
    self.customFilter = nil;
    self.rotationFilter = nil;
    self.picture = nil;
    self.image = nil;
    self.delegate = nil;
    
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
}

@end

