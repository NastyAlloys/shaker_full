//
//  NHVideoEditViewController.m
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import "NHVideoEditViewController.h"
#import "NHRecorderButton.h"
#import "NHFilterCollectionView.h"
#import "NHPhotoEditorViewController.h"
#import "NHVideoView.h"

@import AssetsLibrary;

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHVideoEditViewController class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHVideoEditViewController class]], nil)

@interface NHVideoEditViewController ()<NHFilterCollectionViewDelegate, NHCropCollectionViewDelegate>

@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

@property (nonatomic, strong) id orientationChange;

@property (nonatomic, strong) NHRecorderButton *backButton;

@property (nonatomic, strong) NHVideoView *videoView;

@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UIView *selectorSeparatorView;
@property (nonatomic, strong) UIView *selectionContainerView;
@property (nonatomic, strong) UIView *videoSeparatorView;


@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *cropButton;
@property (nonatomic, strong) NHFilterCollectionView *filterCollectionView;
@property (nonatomic, strong) NHCropCollectionView *cropCollectionView;

@end

@implementation NHVideoEditViewController

- (instancetype)initWithAssetURL:(NSURL*)url {
    self = [super init];
    
    if (self) {
        _assetURL = url;
        [self commonInit];
    }
    
    return self;
}

- (NSString *)filteredVideoPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
}

- (void)commonInit {
    self.view.backgroundColor = [UIColor blackColor];
    
    self.backButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(0, 0, 44, 44);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton setImage:image(@"NHRecorder.back") forState:UIControlStateNormal];
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.backButton addTarget:self action:@selector(backButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:localization(@"NHRecorder.button.done", @"NHRecorder")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(nextButtonTouch:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    self.videoView = [[NHVideoView alloc] initWithURL:self.assetURL];
    self.videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.videoView];
    
    self.selectorView = [[UIView alloc] init];
    self.selectorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectorView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.selectorView];
    
    self.selectionContainerView = [[UIView alloc] init];
    self.selectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionContainerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.selectionContainerView];
    
    [self setupSelectorViewConstraints];
    [self setupSelectionContainerViewConstraints];
    [self setupVideoEditViewConstraints];
    
    [self startVideo];
    
    self.filterButton = [[UIButton alloc] init];
    self.filterButton.backgroundColor = [UIColor clearColor];
    self.filterButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.filterButton setTitle:nil forState:UIControlStateNormal];
    [self.filterButton setImage:[image(@"NHRecorder.filter.button")
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateNormal];
    [self.filterButton setImage:[image(@"NHRecorder.filter.button-active")
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateSelected];
    [self.selectorView addSubview:self.filterButton];
    [self.filterButton addTarget:self action:@selector(filterButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.filterButton.selected = YES;
    
    
    self.cropButton = [[UIButton alloc] init];
    self.cropButton.backgroundColor = [UIColor clearColor];
    self.cropButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cropButton setTitle:nil forState:UIControlStateNormal];
    [self.cropButton setImage:[image(@"NHRecorder.crop.button")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateNormal];
    [self.cropButton setImage:[image(@"NHRecorder.crop.button-active")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateSelected];
    [self.cropButton addTarget:self action:@selector(cropButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupSelectorButtons];
    
    self.filterCollectionView = [[NHFilterCollectionView alloc] initWithImage:[self generateThumbImage:self.assetURL]];
    self.filterCollectionView.backgroundColor = [UIColor clearColor];
    self.filterCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.filterCollectionView];
    
    [self setupFilterCollectionViewConstraints];
    
    self.cropCollectionView = [[NHCropCollectionView alloc] init];
    self.cropCollectionView.backgroundColor = [UIColor clearColor];
    self.cropCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cropCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.cropCollectionView];
    [self setupCropCollectionViewConstraints];
    
    [self.filterCollectionView setSelected:0];
    [self.cropCollectionView setSelected:0];
    
    [self showFiltersCollection];
    
    __weak __typeof(self) weakSelf = self;
    self.enterForegroundNotification = [[NSNotificationCenter defaultCenter]
                                        addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:nil
                                        queue:nil
                                        usingBlock:^(NSNotification *note) {
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            if (strongSelf
                                                && strongSelf.view.window) {
                                                [self startVideo];
                                            }
                                        }];
    
    self.resignActiveNotification = [[NSNotificationCenter defaultCenter]
                                     addObserverForName:UIApplicationWillResignActiveNotification
                                     object:nil
                                     queue:nil
                                     usingBlock:^(NSNotification *note) {
                                         __strong __typeof(weakSelf) strongSelf = weakSelf;
                                         if (strongSelf
                                             && strongSelf.view.window) {
                                         }
                                     }];
    
    self.orientationChange = [[NSNotificationCenter defaultCenter]
                              addObserverForName:UIDeviceOrientationDidChangeNotification
                              object:nil
                              queue:nil
                              usingBlock:^(NSNotification *note) {
                                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                                  if (strongSelf
                                      && strongSelf.view.window) {
                                      [strongSelf deviceOrientationChange];
                                  }
                              }];
    
    [self.videoView.panGestureRecognizer addTarget:self action:@selector(videoGestureAction:)];
    [self.videoView.pinchGestureRecognizer addTarget:self action:@selector(videoGestureAction:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self startVideo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)videoGestureAction:(UIGestureRecognizer*)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNextEnabled) object:nil];
            break;
        default: {
            [self performSelector:@selector(checkNextEnabled) withObject:nil afterDelay:0.5];
        } break;
    }
}

- (void)checkNextEnabled {
    self.navigationItem.rightBarButtonItem.enabled =
    ((self.videoView.panGestureRecognizer.state == UIGestureRecognizerStateFailed
      || self.videoView.panGestureRecognizer.state == UIGestureRecognizerStatePossible)
     && (self.videoView.pinchGestureRecognizer.state == UIGestureRecognizerStateFailed
         || self.videoView.pinchGestureRecognizer.state == UIGestureRecognizerStatePossible));
}

//http://stackoverflow.com/questions/1347562/getting-thumbnail-from-a-video-url-or-data-in-iphone-sdk
-(UIImage *)generateThumbImage:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 1;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

- (void)deviceOrientationChange {
    CGFloat angle = 0;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        default:
            return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.filterButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.cropButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)backButtonTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)startSaving {
    
    __weak __typeof(self) weakSelf = self;
    
    [self.videoView processVideoToPath:[self filteredVideoPath]
                             withBlock:^(NSURL *videoURL) {
        weakSelf.navigationController.view.userInteractionEnabled = YES;
        
                                 
                                 if (!videoURL) {
#ifdef DEBUG
                                     NSLog(@"video url is nil");
#endif
                                     return;
                                 }
        
        BOOL shouldSave = YES;
        NSURL *outputURL = videoURL;
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:shouldSaveFilteredVideoAtURL:)]) {
            shouldSave = [weakSelf.nhDelegate nhVideoEditor:weakSelf shouldSaveFilteredVideoAtURL:outputURL];
        }
        
        if (shouldSave) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
                [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                    if (!error
                        && assetURL) {
#ifdef DEBUG
                        NSLog(@"saved");
#endif
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didSaveAtURL:)]) {
                            [weakSelf.nhDelegate nhVideoEditor:weakSelf didSaveAtURL:assetURL];
                        }
                        
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didFinishExportingAtURL:)]) {
                            [weakSelf.nhDelegate nhVideoEditor:weakSelf didFinishExportingAtURL:assetURL];
                        }
                    }
                    else {
#ifdef DEBUG
                        NSLog(@"error = %@", error);
#endif
                        
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didFailWithError:)]) {
                            [weakSelf.nhDelegate nhVideoEditor:weakSelf didFailWithError:error];
                        }
                        
                        BOOL shouldContinue = YES;
                        
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditorShouldContinueAfterSaveFail:)]) {
                            shouldContinue = [weakSelf.nhDelegate nhVideoEditorShouldContinueAfterSaveFail:weakSelf];
                        }
                        
                        if (shouldContinue) {
                            if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didFinishExportingAtURL:)]) {
                                [weakSelf.nhDelegate nhVideoEditor:weakSelf
                                           didFinishExportingAtURL:outputURL];
                            }
                        }
                    }
                }];
            }
            
        }
        else {
            
            if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didFinishExportingAtURL:)]) {
                [weakSelf.nhDelegate nhVideoEditor:weakSelf didFinishExportingAtURL:outputURL];
            }
        }
    }];
}

- (void)nextButtonTouch:(id)sender {
    
    if (self.videoView.panGestureRecognizer.state == UIGestureRecognizerStatePossible
        && self.videoView.pinchGestureRecognizer.state == UIGestureRecognizerStatePossible) {
        self.navigationController.view.userInteractionEnabled = NO;
        
        [self startSaving];
        
        __weak __typeof(self) weakSelf = self;
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditorDidStartExporting:)]) {
            [weakSelf.nhDelegate nhVideoEditorDidStartExporting:weakSelf];
        }
    }
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.videoView sizeContent];
}

- (void)setupVideoEditViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:-1]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupSelectorViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0 constant:kNHRecorderSelectorViewHeight]];
    
    self.selectorSeparatorView = [[UIView alloc] init];
    self.selectorSeparatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.selectorSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectorView addSubview:self.selectorSeparatorView];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.selectorSeparatorView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:0 constant:0.5]];
}

- (void)setupSelectionContainerViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.selectorView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:0 constant:kNHRecorderSelectionContainerViewHeight]];
    
    self.videoSeparatorView = [[UIView alloc] init];
    self.videoSeparatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.videoSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectionContainerView addSubview:self.videoSeparatorView];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSeparatorView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSeparatorView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSeparatorView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0 constant:0]];
    
    [self.videoSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSeparatorView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.videoSeparatorView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0 constant:0.5]];
}

- (void)setupSelectorButtons {
    [self.filterButton removeFromSuperview];
    [self.cropButton removeFromSuperview];
    
    [self.selectorView addSubview:self.filterButton];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0 constant:0]];
    
    if (self.forcedCropType == NHPhotoCropTypeNone) {
        [self.selectorView addSubview:self.cropButton];
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0 constant:0]];
        
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.filterButton
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.filterButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0 constant:0]];
    }
    else {
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
    }
    
}

- (void)setupCropCollectionViewConstraints {
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0 constant:5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0 constant:-5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0 constant:15]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0 constant:-15]];
}

- (void)setupFilterCollectionViewConstraints {
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0 constant:5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0 constant:-5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0 constant:15]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0 constant:-15]];
}

- (void)filterButtonTouch:(id)sender {
    if (!self.filterButton.selected) {
        [self showFiltersCollection];
    }
}

- (void)cropButtonTouch:(id)sender {
    if (!self.cropButton.selected) {
        [self showCropCollection];
    }
}

- (void)showFiltersCollection {
    self.filterButton.selected = YES;
    self.cropButton.selected = NO;
    
    self.filterCollectionView.hidden = NO;
    self.cropCollectionView.hidden = YES;
}

- (void)showCropCollection {
    self.filterButton.selected = NO;
    self.cropButton.selected = YES;
    
    self.filterCollectionView.hidden = YES;
    self.cropCollectionView.hidden = NO;
}

- (void)setForcedCropType:(NHPhotoCropType)forcedCropType {
    [self willChangeValueForKey:@"forcedCropType"];
    _forcedCropType = forcedCropType;
    [self didChangeValueForKey:@"forcedCropType"];
    [self.videoView setCropType:forcedCropType];
    [self setupSelectorButtons];
}

- (void)cropView:(NHCropCollectionView *)cropView didSelectType:(NHPhotoCropType)type {
    [self.videoView setCropType:type];
}

- (void)filterView:(NHFilterCollectionView *)filterView didSelectFilterType:(NHFilterType)filterType {
    [self.videoView setDisplayFilter:[NHFilterCollectionView filterForType:filterType]];
    [self.videoView setSavingFilterType:filterType];
}

- (void)startVideo {
    [self.videoView startVideo];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
