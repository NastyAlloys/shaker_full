//
//  NHVideoView.m
//  Pods
//
//  Created by Sergey Minakov on 28.07.15.
//
//

#import "NHVideoView.h"

@interface NHVideoView ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) GPUImageView *contentView;

@property (nonatomic, strong) AVURLAsset *videoAsset;

@property (nonatomic, strong) GPUImageMovie *videoFile;
@property (nonatomic, strong) GPUImageFilter *rotationFilter;
@property (nonatomic, strong) GPUImageFilter *customFilter;

@property (nonatomic, strong) NHCameraCropView *cropView;

@property (nonatomic, assign) NHFilterType filterType;

//saving
@property (nonatomic, strong) GPUImageMovie *saveFile;
@property (nonatomic, strong) GPUImageFilter *saveFilter;
@property (nonatomic, strong) GPUImageCropFilter *saveCrop;
@property (nonatomic, strong) GPUImageMovieWriter *saveWriter;
@property (nonatomic, assign) GPUImageRotationMode rotation;
@property (nonatomic, strong) GPUImageFilter *saveRotation;
@end

@implementation NHVideoView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithURL:(NSURL*)url {
    self = [super init];
    
    if (self) {
        _videoURL = url;
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
    self.maximumZoomScale = 1;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    self.backgroundColor = [UIColor blackColor];
    
    self.contentView = [[GPUImageView alloc] init];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.contentView];
    
    
    self.videoAsset = [AVURLAsset assetWithURL:self.videoURL];
    self.videoFile = [[GPUImageMovie alloc] initWithURL:self.videoURL];
    self.videoFile.playAtActualSpeed = YES;
    self.videoFile.shouldRepeat = YES;
    
    self.customFilter = [[GPUImageFilter alloc] init];
    self.rotationFilter = [[GPUImageFilter alloc] init];
    
    GPUImageRotationMode newRotation = kGPUImageNoRotation;
    
    
    switch ([self orientationForTrack:self.videoAsset]) {
        case UIInterfaceOrientationLandscapeLeft:
            break;
        case UIInterfaceOrientationLandscapeRight:
            newRotation = kGPUImageRotate180;
            break;
        case UIInterfaceOrientationPortrait:
            newRotation = kGPUImageRotateRight;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            newRotation = kGPUImageRotateLeft;
            break;
        default:
            break;
    }
    
    self.rotation = newRotation;
    [self.rotationFilter setInputRotation:newRotation atIndex:0];
    
    [self.videoFile addTarget:self.rotationFilter];
    [self.rotationFilter addTarget:self.customFilter];
    [self.customFilter addTarget:self.contentView];
    
    [self sizeContent];
    
    self.cropView = [[NHCameraCropView alloc] init];
    self.cropView.showBorder = NO;
    self.cropView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cropView.userInteractionEnabled = NO;
    self.cropView.backgroundColor = [UIColor clearColor];
    self.cropView.cropBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

//http://stackoverflow.com/questions/4627940/how-to-detect-iphone-sdk-if-a-video-file-was-recorded-in-portrait-orientation
- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
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

- (void)setDisplayFilter:(GPUImageFilter*)filter {
    [self.customFilter removeAllTargets];
    [self.rotationFilter removeAllTargets];
    [self.customFilter removeOutputFramebuffer];
    
    self.customFilter = filter;

    [self.rotationFilter addTarget:self.customFilter];
    [self.customFilter addTarget:self.contentView];
}

- (void)setSavingFilterType:(NHFilterType)filterType {
    self.filterType = filterType;
}

- (CGSize)videoSize {
    AVAssetTrack *videoAssetTrack = [self.videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    CGSize videoSize = videoAssetTrack.naturalSize;
    
    switch (self.rotation) {
        case kGPUImageRotateLeft:
        case kGPUImageRotateRight: {
            CGFloat width = videoSize.width;
            videoSize.width = videoSize.height;
            videoSize.height = width;
        } break;
        default:
            break;
    }
    
    return videoSize;
}

- (void)sizeContent {
    
    CGSize videoSize = [self videoSize];
    CGRect bounds = !CGSizeEqualToSize(videoSize, CGSizeZero)
    ? (CGRect) { .size = videoSize }
    : self.contentView.frame;

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
}

- (void)resetCropAnimated:(BOOL)animated {
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
    self.maximumZoomScale = newValue;
    [self setZoomScale:newValue animated:animated];
    [self scrollViewDidZoom:self];
}

- (void)processVideoToPath:(NSString*)path withBlock:(void(^)(NSURL *videoURL))block; {
    
    if (self.saveWriter) {
        block(nil);
    }
    
    CGRect cropRegion = [self.cropView cropRegionForView:self.contentView];
    
    NSString *pathToMovie = path;
    unlink([pathToMovie UTF8String]);
    NSURL *fileURL = [NSURL fileURLWithPath:pathToMovie];

    [self.saveFile endProcessing];
    [self.saveWriter finishRecording];
    [self.saveCrop removeAllTargets];
    [self.saveFilter removeAllTargets];
    [self.saveRotation removeAllTargets];
    [self.saveFilter removeOutputFramebuffer];
    [self.saveFile removeAllTargets];
    self.saveFile = nil;
    self.saveWriter = nil;
    self.saveCrop = nil;
    self.saveFilter = nil;
    self.saveRotation = nil;
    
    self.saveFile = [[GPUImageMovie alloc] initWithURL:self.videoURL];
    self.saveFile.playAtActualSpeed = YES;
    
    self.saveFilter = [NHFilterCollectionView filterForType:self.filterType];
    
    
    
    CGSize videoSize = [self videoSize];
    videoSize.width = ((int)ceil( videoSize.width * cropRegion.size.width / 4.0)) * 4;
    videoSize.height = ((int)ceil( videoSize.height * cropRegion.size.height / 4.0)) * 4;

    self.saveWriter = [[GPUImageMovieWriter alloc]
                                             initWithMovieURL:fileURL
                                             size:videoSize];
    
    self.saveWriter.shouldPassthroughAudio = YES;
    if ([self.videoAsset tracksWithMediaType:AVMediaTypeAudio].count) {
        self.saveFile.audioEncodingTarget = self.saveWriter;
    } else {//no audio
        self.saveFile.audioEncodingTarget = nil;
    }
    

    [self.saveFile enableSynchronizedEncodingUsingMovieWriter:self.saveWriter];
    
    self.saveRotation = [[GPUImageFilter alloc] init];
    [self.saveRotation setInputRotation:self.rotation atIndex:0];
    
    self.saveCrop = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];
    self.saveCrop.cropRegion = cropRegion;
    
    [self.saveFile addTarget:self.saveRotation];
    [self.saveRotation addTarget:self.saveFilter];
    [self.saveFilter addTarget:self.saveCrop];
    [self.saveCrop addTarget:self.saveWriter];

    __weak __typeof(self) weakSelf = self;
    [self.saveWriter setCompletionBlock:^{
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf.saveWriter finishRecordingWithCompletionHandler:^{
            block(fileURL);
        }];
        
        strongSelf.saveWriter = nil; 
    }];
    
    [self.saveWriter startRecording];
    [self.saveFile startProcessing];
}

- (void)startVideo {
    [self.videoFile endProcessing];
    [self.videoFile startProcessing];
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
    [self.customFilter removeAllTargets];
    [self.rotationFilter removeAllTargets];
    [self.videoFile endProcessing];
    [self.videoFile removeAllTargets];
    
    [self.saveFile endProcessing];
    [self.saveWriter finishRecording];
    [self.saveCrop removeAllTargets];
    [self.saveFilter removeAllTargets];
    [self.saveRotation removeAllTargets];
    [self.saveFile removeAllTargets];
    self.saveFile = nil;
    self.saveWriter = nil;
    self.saveFilter = nil;
    self.saveCrop = nil;
    self.saveRotation = nil;
    
    self.rotationFilter = nil;
    self.customFilter = nil;
    self.videoFile = nil;
    self.videoAsset = nil;
    self.delegate = nil;
    
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
}

@end
