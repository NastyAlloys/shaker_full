//
//  NHImageScrollView.m
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import "NHImageScrollView.h"
#import <MACircleProgressIndicator/MACircleProgressIndicator.h>
#import <AFNetworking/AFNetworking.h>

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHImageScrollView class]]\
pathForResource:name ofType:@"png"]]

typedef void(^NHSuccessBlock)(id);
typedef void(^NHFailBlock)(void);
typedef void(^NHDownloadBlock)(float);

@interface NHImageOperationItem : NSObject

@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) NHSuccessBlock successBlock;
@property (nonatomic, strong) NHFailBlock failBlock;
@property (nonatomic, strong) NHDownloadBlock downloadBlock;

@end

@implementation NHImageOperationItem

- (instancetype)initWithOperation:(AFHTTPRequestOperation*)operation
                    succeessBlock:(NHSuccessBlock)successBlock
                        failBlock:(NHFailBlock)failBlock
                    downloadBlock:(NHDownloadBlock)downloadBlock {
    self = [super init];

    if (self) {
        _operation = operation;
        _successBlock = successBlock;
        _failBlock = failBlock;
        _downloadBlock = downloadBlock;
    }

    return self;
}

@end

@interface NHImageScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) FLAnimatedImageView *contentView;
@property (nonatomic, strong) MACircleProgressIndicator *progressIndicator;
@property (nonatomic, assign) BOOL loadingImage;
@end

@implementation NHImageScrollView

+ (NSMutableDictionary*)operationStorage {
    static dispatch_once_t token;
    __strong static NSMutableDictionary* instance = nil;
    dispatch_once(&token, ^{
        instance = [[NSMutableDictionary alloc] init];
    });

    return instance;
}

+ (NSCache*)imageControllerCache {
    static dispatch_once_t token;
    __strong static NSCache* instance = nil;
    dispatch_once(&token, ^{
        instance = [[NSCache alloc] init];
    });

    return instance;
}
//
//- (instancetype)init {
//    self = [super init];
//
//    if (self) {
//        [self commonInit];
//    }
//
//    return self;
//}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame image:nil andPath:nil];
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image {
    return [self initWithFrame:frame image:image andPath:nil];
}

- (instancetype)initWithFrame:(CGRect)frame andPath:(NSString*)path {
    return [self initWithFrame:frame image:nil andPath:path];
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image andPath:(NSString*)path {
    self = [super initWithFrame:frame];

    if (self) {
        _image = image;
        _imagePath = path;
        [self commonInit];
    }

    return self;
}

- (void)commonInit {

    self.delegate = self;
    self.bounces = YES;
    self.alwaysBounceVertical = NO;
    self.alwaysBounceHorizontal = NO;
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 5;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];

    self.contentView = [[FLAnimatedImageView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];

    self.progressIndicator = [[MACircleProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.progressIndicator.backgroundColor = [UIColor clearColor];
    self.progressIndicator.strokeWidth = 2;
    self.progressIndicator.color = [UIColor whiteColor];
    self.progressIndicator.center = CGPointMake(self.contentView.bounds.size.width / 2, self.contentView.bounds.size.height / 2);

    [self.contentView addSubview:self.progressIndicator];

    [self sizeContent];
    [self loadImage];
}

- (void)zoomToPoint:(CGPoint)point andScale:(CGFloat)scale {
    CGRect zoomRect = CGRectZero;

    zoomRect.size.width = self.bounds.size.width / scale;
    zoomRect.size.height = self.bounds.size.height / scale;

    zoomRect.origin.x = point.x - (zoomRect.size.width / 2);
    zoomRect.origin.y = point.y - (zoomRect.size.height / 2);

    [self zoomToRect:zoomRect animated:YES];

    [self setZoomScale:scale animated:YES];
}

- (void)sizeContent {
    [self.contentView sizeToFit];

    CGRect bounds = self.contentView.animatedImage ? (CGRect) { .size = self.contentView.animatedImage.size } : self.contentView.frame;

    if (bounds.size.height) {
        CGFloat ratio = bounds.size.width / bounds.size.height;

        if (ratio) {

            if (ratio > 1.5) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.height = bounds.size.width / ratio;
                }
                else {
                    bounds.size.width = MAX(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.height = bounds.size.width / ratio;
                }
            }
            else if (ratio < 0.5) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.height = MAX(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.width = bounds.size.height * ratio;
                }
                else {
                    bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.width = bounds.size.height * ratio;
                }
            }
            else {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.height = bounds.size.width / ratio;
                }
                else {
                    bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.width = bounds.size.height * ratio;
                }
            }
        }
    }

    self.contentView.frame = bounds;
    self.contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.contentSize = CGSizeZero;

    self.progressIndicator.center = CGPointMake(self.contentView.bounds.size.width / 2, self.contentView.bounds.size.height / 2);

    [self scrollViewDidZoom:self];
}

- (BOOL)saveImage {
    if (self.image) {
        UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        return YES;
    }
    else if (self.animatedImage) {
        UIImageWriteToSavedPhotosAlbum(self.animatedImage.posterImage, nil, nil, nil);
        return YES;
    }

    return NO;
}

- (void)loadImage {
    self.contentView.image = nil;
    self.loadingImage = NO;

    if (self.image) {
        [self showImage:self.image];
    }
    else if (self.animatedImage) {
        [self showAnimatedImage:self.animatedImage];
    }
    else if (self.imagePath
             && [self.imagePath length]) {

        id resultImage = [[[self class] imageControllerCache] objectForKey:self.imagePath];

        if (resultImage
            && [resultImage isKindOfClass:[UIImage class]]) {
            [self showImage:resultImage];
        }
        else if (resultImage
                 && [resultImage isKindOfClass:[FLAnimatedImage class]]) {
            [self showAnimatedImage:resultImage];
        }
        else {
            self.progressIndicator.value = 0;
            self.progressIndicator.hidden = NO;
            self.loadingImage = YES;

            NHImageOperationItem *operationData = [[[self class] operationStorage] objectForKey:self.imagePath];

            AFHTTPRequestOperation *operation = nil;
            NHSuccessBlock previousSuccessBlock = nil;
            NHFailBlock previousFailBlock = nil;
            NHDownloadBlock previousDownloadBlock = nil;

            if (operationData) {
                operation = operationData.operation;
                previousSuccessBlock = operationData.successBlock;
                previousFailBlock = operationData.failBlock;
                previousDownloadBlock = operationData.downloadBlock;
            }

            __weak __typeof(self) weakSelf = self;
            NHSuccessBlock successBlock = ^(id responseObject){
                __strong __typeof(weakSelf) strongSelf = weakSelf;

                if (previousSuccessBlock) {
                    previousSuccessBlock(responseObject);
                }
                [strongSelf processResponse:responseObject];
            };
            NHFailBlock failBlock = ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;

                if (previousFailBlock) {
                    previousFailBlock();
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf showFailedImage];
                });
            };
            NHDownloadBlock downloadBlock = ^(float value){
                __strong __typeof(weakSelf) strongSelf = weakSelf;

                if (previousDownloadBlock) {
                    previousDownloadBlock(value);
                }
                strongSelf.progressIndicator.value = value;
            };

            if (!operation
                || operation.isFinished) {
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                operation = [manager
                             GET:self.imagePath
                             parameters:nil
                             success:^(AFHTTPRequestOperation *operation,
                                       id responseObject) {
                                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                                 [[[strongSelf class] operationStorage] removeObjectForKey:strongSelf.imagePath];
                                 successBlock(responseObject);
                             } failure:^(AFHTTPRequestOperation *operation,
                                         NSError *error) {
                                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                                 [[[strongSelf class] operationStorage] removeObjectForKey:strongSelf.imagePath];
                                 failBlock();
                             }];
            }
            else {
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                                           id responseObject) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    [[[strongSelf class] operationStorage] removeObjectForKey:strongSelf.imagePath];
                    successBlock(responseObject);
                } failure:^(AFHTTPRequestOperation *operation,
                            NSError *error) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    [[[strongSelf class] operationStorage] removeObjectForKey:strongSelf.imagePath];
                    failBlock();
                }];
            }

            [operation setDownloadProgressBlock:^(NSUInteger bytesRead,
                                                  long long totalBytesRead,
                                                  long long totalBytesExpectedToRead) {
                CGFloat value = 0;

                if (totalBytesExpectedToRead) {
                    value = (double)totalBytesRead / (double)totalBytesExpectedToRead;
                }

                downloadBlock(value);
            }];

            [[[self class] operationStorage]
             setObject:[[NHImageOperationItem alloc] initWithOperation:operation
                                                          succeessBlock:successBlock
                                                              failBlock:failBlock
                                                          downloadBlock:downloadBlock]
             forKey:self.imagePath];
        }
    }
    else {
        [self showFailedImage];
    }
}

- (void)processResponse:(id)responseObject {
    __weak __typeof(self) weakSelf = self;

    if ([responseObject isKindOfClass:[NSData class]]) {

        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:responseObject];

        if (animatedImage) {

            [[[self class] imageControllerCache] setObject:animatedImage forKey:self.imagePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf showAnimatedImage:animatedImage];
            });
        }
        else {
            UIImage *image = [UIImage imageWithData:responseObject];

            if (image) {
                [[[self class] imageControllerCache] setObject:image forKey:self.imagePath];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf showImage:image];
            });
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf showFailedImage];
        });
    }
}

- (void)showImage:(UIImage*)image {

    if (!image
        || ![image isKindOfClass:[UIImage class]]) {
        [self showFailedImage];
        return;
    }

    self.loadingImage = NO;
    self.progressIndicator.hidden = YES;
    self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    self.image = image;
    self.contentView.image = self.image;
    [self sizeContent];
}

- (void)showAnimatedImage:(FLAnimatedImage*)image {
    if (!image
        || ![image isKindOfClass:[FLAnimatedImage class]]) {
        [self showFailedImage];
        return;
    }

    self.progressIndicator.hidden = YES;
    self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    self.animatedImage = image;
    self.contentView.animatedImage = image;
    [self sizeContent];
}

- (void)showFailedImage {
    self.loadingImage = NO;
    self.image = nil;
    self.progressIndicator.hidden = YES;
    self.contentView.contentMode = UIViewContentModeCenter;
    self.contentView.image = [UIImage imageNamed:@"placeholder.image.none"];
    [self sizeContent];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    scrollView.alwaysBounceVertical = scrollView.zoomScale > 1;
    scrollView.alwaysBounceHorizontal = scrollView.zoomScale > 1;

    if (scrollView.zoomScale == self.minimumZoomScale) {
        self.contentSize = CGSizeZero;
        self.contentInset = UIEdgeInsetsZero;
        return;
    }

    CGSize zoomedSize = self.contentView.bounds.size;
    zoomedSize.width *= self.zoomScale;
    zoomedSize.height *= self.zoomScale;

    CGFloat verticalOffset = 0;
    CGFloat horizontalOffset = 0;

    if (zoomedSize.width < self.bounds.size.width) {
        horizontalOffset = (self.bounds.size.width - zoomedSize.width) / 2.0;
    }

    if (zoomedSize.height < self.bounds.size.height) {
        verticalOffset = (self.bounds.size.height - zoomedSize.height) / 2.0;
    }

    self.contentInset = UIEdgeInsetsMake(verticalOffset - self.contentView.frame.origin.y,
                                         horizontalOffset - self.contentView.frame.origin.x,
                                         verticalOffset + self.contentView.frame.origin.y,
                                         horizontalOffset + self.contentView.frame.origin.x);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)dealloc {
}

@end
