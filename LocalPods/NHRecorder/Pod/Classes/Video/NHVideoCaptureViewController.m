//
//  NHVideoCaptureViewController.m
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

#import "NHVideoCaptureViewController.h"
#import "CaptureManager.h"
#import "NHRecorderButton.h"
#import "NHCameraGridView.h"
#import "NHPhotoCaptureViewController.h"
#import "NHCameraCropView.h"
#import "NHVideoFocusView.h"
#import "AVCamRecorder.h"
#import "NHVideoEditViewController.h"
#import "NHRecorderProgressView.h"
#import "NHMediaPickerViewController.h"

@import AssetsLibrary;

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHVideoCaptureViewController class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHVideoCaptureViewController class]], nil)

const NSTimeInterval kNHVideoTimerInterval = 0.05;
const NSTimeInterval kNHVideoMaxDuration = 15.0;
const NSTimeInterval kNHVideoMinDuration = 2.0;

@interface NHVideoCaptureViewController ()<CaptureManagerDelegate>

@property (nonatomic, strong) CaptureManager *captureManager;
@property (nonatomic, strong) UIView *videoCameraView;
@property (nonatomic, strong) NHCameraGridView *cameraGridView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

@property (nonatomic, strong) id orientationChange;

@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) NHRecorderButton *removeFragmentButton;
@property (nonatomic, strong) UIButton *captureButton;

@property (nonatomic, strong) NHRecorderButton *libraryButton;

@property (nonatomic, strong) NHRecorderButton *backButton;
@property (nonatomic, strong) NHRecorderButton *gridButton;
@property (nonatomic, strong) NHRecorderButton *switchButton;

@property (nonatomic, strong) NHRecorderProgressView *durationProgressView;

@property (nonatomic, assign) NSTimeInterval currentDuration;

@property (nonatomic, strong) NHCameraCropView *cropView;

@property (nonatomic, strong) NHVideoFocusView *cameraFocusView;

@property (nonatomic, strong) NSTimer *recordTimer;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGestureRecognizer;
@end

@implementation NHVideoCaptureViewController


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.view.backgroundColor = [UIColor blackColor];
    
    self.videoCameraView = [[UIView alloc] init];
    self.videoCameraView.backgroundColor = [UIColor blackColor];
    self.videoCameraView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoCameraView.userInteractionEnabled = NO;
    self.videoCameraView.clipsToBounds = YES;
    self.videoCameraView.layer.masksToBounds = YES;
    [self.view addSubview:self.videoCameraView];
    
    self.bottomContainerView = [[UIView alloc] init];
    self.bottomContainerView.backgroundColor = [UIColor blackColor];
    self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bottomContainerView];
    
    [self setupBottomContainerViewContraints];
    [self setupVideoViewConstraints];
    
    self.cameraFocusView = [[NHVideoFocusView alloc] init];
    self.cameraFocusView.backgroundColor = [UIColor clearColor];
    self.cameraFocusView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.cameraFocusView];
    [self setupCameraFocusViewConstraints];
    
    self.cameraGridView = [[NHCameraGridView alloc] init];
    self.cameraGridView.backgroundColor = [UIColor clearColor];
    self.cameraGridView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraGridView.userInteractionEnabled = NO;
    self.cameraGridView.numberOfRows = 2;
    self.cameraGridView.numberOfColumns = 2;
    self.cameraGridView.hidden = YES;
    [self.view addSubview:self.cameraGridView];

    [self setupCameraGridViewConstraints];
    
    self.cropView = [[NHCameraCropView alloc] init];
    self.cropView.cropType = NHPhotoCropTypeSquare;
    self.cropView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cropView.userInteractionEnabled = NO;
    self.cropView.backgroundColor = [UIColor clearColor];
    self.cropView.cropBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.cropView];
    [self setupCropViewConstraints];
    
    self.removeFragmentButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.removeFragmentButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.removeFragmentButton.backgroundColor = [UIColor clearColor];
    [self.removeFragmentButton setImage:image(@"NHRecorder.remove") forState:UIControlStateNormal];
    [self.removeFragmentButton setTitle:nil forState:UIControlStateNormal];
    [self.removeFragmentButton addTarget:self action:@selector(removeFragmentButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.removeFragmentButton.layer.cornerRadius = 5;
    self.removeFragmentButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.removeFragmentButton];
    
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.captureButton setTitle:nil forState:UIControlStateNormal];
    self.captureButton.backgroundColor = [UIColor whiteColor];
    self.longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(captureGestureAction:)];
    self.longGestureRecognizer.minimumPressDuration = 0.15;
    self.longGestureRecognizer.numberOfTouchesRequired = 1;
    [self.captureButton addGestureRecognizer:self.longGestureRecognizer];
    self.captureButton.layer.cornerRadius = kNHRecorderCaptureButtonHeight / 2;
    self.captureButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.captureButton];
    
    self.libraryButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.libraryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.libraryButton.backgroundColor = [UIColor clearColor];
    [self.libraryButton setTitle:nil forState:UIControlStateNormal];
    [self.libraryButton addTarget:self action:@selector(libraryButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.libraryButton.layer.cornerRadius = 5;
    self.libraryButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.libraryButton];
    
    [self setupRemoveFragmentButtonConstraints];
    [self setupLibraryButtonConstraints];
    [self setupCaptureButtonConstraints];
    [self resetLibrary];
    
    self.durationProgressView = [[NHRecorderProgressView alloc] init];
    self.durationProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationProgressView.progressColor = [UIColor redColor];
    self.durationProgressView.backgroundColor = [UIColor darkGrayColor];
    self.durationProgressView.minValue = kNHVideoMinDuration / kNHVideoMaxDuration;
    self.durationProgressView.minValueColor = [UIColor lightGrayColor];
    
    [self.bottomContainerView addSubview:self.durationProgressView];
    
    [self setupDurationProgressViewConstraints];
    
    self.captureManager = [[CaptureManager alloc] init];
    self.captureManager.delegate = self;
    
    if ([self.captureManager setupSession]) {
        self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureManager.session];
        
        if ([self.videoPreviewLayer.connection isVideoOrientationSupported]) {
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [self.videoCameraView.layer insertSublayer:self.videoPreviewLayer atIndex:0];
        
        self.cameraFocusView.captureManager = self.captureManager;
    }
    
    self.backButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(0, 0, 44, 44);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton setImage:image(@"NHRecorder.back") forState:UIControlStateNormal];
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.backButton addTarget:self action:@selector(backButtonTouch:) forControlEvents:UIControlEventTouchUpInside];

    self.switchButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.switchButton.frame = CGRectMake(0, 0, 44, 44);
    self.switchButton.tintColor = [UIColor whiteColor];
    self.switchButton.customAlignmentInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.switchButton setImage:image(@"NHRecorder.switch") forState:UIControlStateNormal];
    self.switchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.switchButton addTarget:self action:@selector(switchButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.gridButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.gridButton.frame = CGRectMake(0, 0, 44, 44);
    self.gridButton.tintColor = [UIColor whiteColor];
    self.gridButton.customAlignmentInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [self.gridButton setImage:[image(@"NHRecorder.grid")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.gridButton setImage:[image(@"NHRecorder.grid-active")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    self.gridButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.gridButton addTarget:self action:@selector(gridButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    UIBarButtonItem *gridBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.gridButton];
    UIBarButtonItem *switchBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.switchButton];
    
    self.navigationItem.leftBarButtonItems = @[backBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               switchBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               gridBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil]];


    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:localization(@"NHRecorder.button.next", @"NHRecorder")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(nextButtonTouch:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    [self resetGrid];
    self.currentDuration = 0;
    
    __weak __typeof(self) weakSelf = self;
    self.enterForegroundNotification = [[NSNotificationCenter defaultCenter]
                                        addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:nil
                                        queue:nil
                                        usingBlock:^(NSNotification *note) {
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            if (strongSelf
                                                && strongSelf.view.window) {
                                                [strongSelf startCamera];
                                                [strongSelf resetLibrary];
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
                                             [strongSelf stopCapture];
//                                             [strongSelf stopCamera];
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
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)startCamera {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureManager.session startRunning];
//    });
}

- (void)stopCamera {
    [self.captureManager.session stopRunning];
}

- (void)startCapture {
    
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (cameraStatus != AVAuthorizationStatusAuthorized) {
        
        __weak __typeof(self) weakSelf = self;
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:cameraAvailability:)]) {
            [weakSelf.nhDelegate
             nhVideoCapture:weakSelf
             cameraAvailability:cameraStatus];
        }
        return;
    }
    
    if (![self.captureManager.recorder isRecording]
        && self.currentDuration < kNHVideoMaxDuration) {
        [self.captureManager startRecording];
        self.captureButton.selected = YES;
    }
    
    
}

- (void)stopCapture {
    if ([self.captureManager.recorder isRecording]) {
        [self.captureManager stopRecording];
        self.captureButton.selected = NO;
    }
    
    [self stopTimer];
}

- (void)startTimer {
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:kNHVideoTimerInterval target:self
                                                      selector:@selector(updateCaptureDuration:)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopTimer {
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startCamera];
    [self resetLibrary];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopCapture];
    [self stopCamera];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.videoPreviewLayer.frame = self.videoCameraView.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupBottomContainerViewContraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:0 constant:kNHRecorderBottomViewHeight]];
}

- (void)setupLibraryButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:-25]];
    
    [self.libraryButton addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:0 constant:kNHRecorderSideButtonHeight]];
    
    [self.libraryButton addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:1.0 constant:0]];
}

- (void)setupRemoveFragmentButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.removeFragmentButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.removeFragmentButton
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:25]];
    
    [self.removeFragmentButton addConstraint:[NSLayoutConstraint constraintWithItem:self.removeFragmentButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.removeFragmentButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:kNHRecorderSideButtonHeight]];
    
    [self.removeFragmentButton addConstraint:[NSLayoutConstraint constraintWithItem:self.removeFragmentButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.removeFragmentButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
}

- (void)setupCaptureButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0 constant:0]];
    
    [self.captureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.captureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:kNHRecorderCaptureButtonHeight]];
    
    [self.captureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.captureButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
    UIView *captureButtonBorder = [[UIView alloc] init];
    captureButtonBorder.translatesAutoresizingMaskIntoConstraints = NO;
    captureButtonBorder.layer.borderWidth = 2;
    captureButtonBorder.layer.borderColor = [UIColor whiteColor].CGColor;
    captureButtonBorder.layer.cornerRadius = (kNHRecorderCaptureButtonHeight + 2 * kNHRecorderCaptureButtonBorderOffset) / 2;
    captureButtonBorder.userInteractionEnabled = NO;
    captureButtonBorder.backgroundColor = [UIColor clearColor];
    [self.bottomContainerView addSubview:captureButtonBorder];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureButton
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:-kNHRecorderCaptureButtonBorderOffset]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureButton
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:-kNHRecorderCaptureButtonBorderOffset]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureButton
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:kNHRecorderCaptureButtonBorderOffset]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureButton
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0 constant:kNHRecorderCaptureButtonBorderOffset]];
}

- (void)setupDurationProgressViewConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationProgressView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationProgressView
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationProgressView
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:0]];
    
    [self.durationProgressView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationProgressView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.durationProgressView
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:0 constant:3]];
}

- (void)setupVideoViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:-1]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraGridViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraFocusViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCropViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0 constant:0]];
}

- (void)deviceOrientationChange {
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    CGFloat angle = 0;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            self.captureManager.orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.captureManager.orientation = AVCaptureVideoOrientationLandscapeRight;
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            self.captureManager.orientation = AVCaptureVideoOrientationLandscapeLeft;
            angle = -M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.captureManager.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            angle = M_PI;
            break;
        default:
            return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.gridButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.switchButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.removeFragmentButton.transform = CGAffineTransformMakeRotation(angle);
                         self.libraryButton.transform = CGAffineTransformMakeRotation(angle);
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)backButtonTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gridButtonTouch:(id)sender {
    self.cameraGridView.hidden = !self.cameraGridView.hidden;
    [self resetGrid];
}

- (void)switchButtonTouch:(id)sender {
    [self.captureManager switchCamera];
}


- (void)nextButtonTouch:(id)sender {
    
    [self stopCapture];
    
    __weak __typeof(self) weakSelf = self;
    

    
    BOOL isExporting = [self.captureManager saveVideoWithCompletionBlock:^(NSURL *assetURL) {
        
#ifdef DEBUG
        NSLog(@"save with url = %@", assetURL);
#endif
        
        weakSelf.navigationController.view.userInteractionEnabled = YES;
        
        if (assetURL) {
            
            BOOL shouldEdit = YES;
            if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:shouldEditVideoAtURL:)]) {
                shouldEdit = [weakSelf.nhDelegate nhVideoCapture:weakSelf shouldEditVideoAtURL:assetURL];
            }
            
            if (shouldEdit) {
                NHVideoEditViewController *editViewController = [[NHVideoEditViewController alloc] initWithAssetURL:assetURL];
                [self.navigationController pushViewController:editViewController animated:YES];
            }
        }
        
        if (weakSelf
            && [weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:didFinishExportingWithSuccess:)]) {
            [weakSelf.nhDelegate nhVideoCapture:weakSelf didFinishExportingWithSuccess:assetURL != nil];
        }
    }];
    
    if (isExporting) {
        self.navigationController.view.userInteractionEnabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = [self nextButtonEnabled];
        
        __weak __typeof(self) weakSelf = self;
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidStartExporting:)]) {
            [weakSelf.nhDelegate nhVideoCaptureDidStartExporting:weakSelf];
        }
    }
    else {
        self.navigationController.view.userInteractionEnabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = [self nextButtonEnabled];
    }
}

- (void)captureGestureAction:(UILongPressGestureRecognizer*)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            if (CGRectContainsPoint(self.captureButton.bounds, [recognizer locationInView:self.captureButton])) {
                [self startCapture];
            }
            else {
                [self stopCapture];
            }
            break;
        default:
            [self stopCapture];
            break;
    }
}

- (void)libraryButtonTouch:(id)sender {
    NHMediaPickerViewController *viewController = [[NHMediaPickerViewController alloc]
                                                   initWithMediaType:NHMediaPickerTypeVideo];
    viewController.firstController = NO;
    viewController.linksToCamera = NO;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)removeFragmentButtonTouch:(id)sender {
    [self.captureManager deleteLastAsset];
}

- (void)removeTimeFromDuration:(float)removeTime {
    self.currentDuration = MAX(0, [self.captureManager currentDuration]);
}

- (void)captureManagerRecordingBegan:(CaptureManager *)captureManager {
    [self startTimer];
    self.captureButton.backgroundColor = [UIColor redColor];
    
    __weak __typeof(self) weakSelf = self;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidStart:)]) {
        [weakSelf.nhDelegate nhVideoCaptureDidStart:weakSelf];
    }
}

- (void)updateCaptureDuration:(NSTimer *)timer {
    if ([[[self captureManager] recorder] isRecording])
    {
        self.currentDuration += kNHVideoTimerInterval;
    }
    else
    {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
}

- (void)captureManagerRecordingFinished:(CaptureManager *)captureManager {
    self.captureButton.backgroundColor = [UIColor whiteColor];
    
    self.currentDuration = [self.captureManager currentDuration];
    
    [self.durationProgressView addSeparatorAtProgress:self.durationProgressView.progress];
    
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidFinish:)]) {
        [weakSelf.nhDelegate nhVideoCaptureDidFinish:weakSelf];
    }
}

- (void)updateProgress {
    
    NSLog(@"progress");
    
    __weak __typeof(self) weakSelf = self;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:exportProgressChanged:)]) {
        [weakSelf.nhDelegate nhVideoCapture:weakSelf exportProgressChanged:weakSelf.captureManager.exportSession.progress];
    }
}

- (void)removeProgress {
    __weak __typeof(self) weakSelf = self;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidStartSaving:)]) {
        [weakSelf.nhDelegate nhVideoCaptureDidStartSaving:weakSelf];
    }
}

- (void)captureManager:(CaptureManager *)captureManager didFailWithError:(NSError *)error {
    __weak __typeof(self) weakSelf = self;
#ifdef DEBUG
    NSLog(@"fail with: %@", error);
#endif
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:didFailWithError:)]) {
        [weakSelf.nhDelegate nhVideoCapture:weakSelf didFailWithError:error];
    }
}

- (BOOL)captureManagerShouldSaveToCameraRoll:(CaptureManager *)captureManager {
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureShouldSaveNonFilteredVideo:)]) {
        return [weakSelf.nhDelegate nhVideoCaptureShouldSaveNonFilteredVideo:weakSelf];
    }
    
    return YES;
}

- (void)resetGrid {
    self.gridButton.selected = !self.cameraGridView.hidden;
}

- (void)resetRecorder {
    [self stopCapture];
    [self.durationProgressView removeAllSeparators];
    self.currentDuration = 0;
    
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidReset:)]) {
        [weakSelf.nhDelegate nhVideoCaptureDidReset:weakSelf];
    }
}

- (void)resetLibrary {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                      usingBlock:^(ALAsset *result,
                                                                   NSUInteger index,
                                                                   BOOL *stop) {
                                                          
                                                          if (result
                                                              && [[result valueForProperty:ALAssetPropertyType]
                                                                  isEqualToString:ALAssetTypeVideo]) {
                                                                  UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                                                                  
                                                                  if (image) {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          [self.libraryButton setImage:image forState:UIControlStateNormal];
                                                                      });
                                                                      
                                                                      *stop = YES;
                                                                  }
                                                              }
                                                          
                                                      }];
                           } failureBlock:^(NSError *error) {
                               [self.libraryButton setImage:image(@"NHRecorder.video.error") forState:UIControlStateNormal];
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

- (void)setCurrentDuration:(NSTimeInterval)currentDuration {
    [self willChangeValueForKey:@"currentDuration"];
    _currentDuration = currentDuration;
    
    self.durationProgressView.progress = currentDuration / kNHVideoMaxDuration;
    self.navigationItem.rightBarButtonItem.enabled = [self nextButtonEnabled];
    if (self.currentDuration >= kNHVideoMaxDuration) {
        [self stopCapture];
    }
    [self didChangeValueForKey:@"currentDuration"];
}

- (BOOL)nextButtonEnabled {
    return self.currentDuration >= kNHVideoMinDuration;
}

- (void)dealloc {
    [self stopCapture];
    [self stopCamera];
    self.captureManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
