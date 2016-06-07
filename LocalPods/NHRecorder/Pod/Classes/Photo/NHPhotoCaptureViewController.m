//
//  NHCameraViewController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHPhotoCaptureViewController.h"
#import "NHPhotoFocusView.h"
#import "NHCameraGridView.h"
#import "NHPhotoEditorViewController.h"
#import "NHVideoCaptureViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+Resize.h"
#import "NHMediaPickerViewController.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHPhotoCaptureViewController class]]\
pathForResource:name ofType:@"png"]]


const CGFloat kNHRecorderBottomViewHeight = 90;
const CGFloat kNHRecorderCaptureButtonHeight = 60;
const CGFloat kNHRecorderSideButtonHeight = 50;
const CGFloat kNHRecorderCaptureButtonBorderOffset = 5;

@interface NHPhotoCaptureViewController ()

@property (nonatomic, strong) GPUImageStillCamera *photoCamera;
@property (nonatomic, strong) GPUImageCropFilter *photoCropFilter;
@property (nonatomic, strong) GPUImageView *photoCameraView;

@property (nonatomic, strong) NHCameraGridView *cameraGridView;
@property (nonatomic, strong) NHPhotoFocusView *cameraFocusView;

@property (nonatomic, strong) UIView *bottomContainerView;

@property (nonatomic, strong) NHRecorderButton *closeButton;
@property (nonatomic, strong) NHRecorderButton *flashButton;
@property (nonatomic, strong) NHRecorderButton *gridButton;
@property (nonatomic, strong) NHRecorderButton *switchButton;

@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) NHRecorderButton *libraryButton;
@property (nonatomic, strong) NHRecorderButton *videoCaptureButton;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

@property (nonatomic, strong) id orientationChange;

@end

@implementation NHPhotoCaptureViewController

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
    
    self.photoCamera = [[GPUImageStillCamera alloc]
                        initWithSessionPreset:AVCaptureSessionPresetPhoto
                        cameraPosition:AVCaptureDevicePositionBack];
    
    self.photoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.photoCamera.horizontallyMirrorFrontFacingCamera = YES;
    if ([self.photoCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [self.photoCamera.inputCamera lockForConfiguration:nil];
        [self.photoCamera.inputCamera setFlashMode:AVCaptureFlashModeAuto];
        [self.photoCamera.inputCamera unlockForConfiguration];
    }
    
    self.photoCropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];
    
    [self.photoCamera addTarget:self.photoCropFilter];
    
    self.photoCameraView = [[GPUImageView alloc] init];
    self.photoCameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.photoCameraView.backgroundColor = [UIColor blackColor];
    self.photoCameraView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoCameraView.userInteractionEnabled = NO;
    [self.view addSubview:self.photoCameraView];
    [self.photoCropFilter addTarget:self.photoCameraView];
    
    self.bottomContainerView = [[UIView alloc] init];
    self.bottomContainerView.backgroundColor = [UIColor blackColor];
    self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bottomContainerView];
    
    [self setupBottomContainerViewContraints];
    [self setupCameraViewConstraints];
    
    self.cameraFocusView = [[NHPhotoFocusView alloc] init];
    self.cameraFocusView.backgroundColor = [UIColor clearColor];
    self.cameraFocusView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraFocusView.camera = self.photoCamera;
    self.cameraFocusView.cropFilter = self.photoCropFilter;
    [self.view addSubview:self.cameraFocusView];
    
    self.cameraGridView = [[NHCameraGridView alloc] init];
    self.cameraGridView.backgroundColor = [UIColor clearColor];
    self.cameraGridView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraGridView.userInteractionEnabled = NO;
    self.cameraGridView.numberOfRows = 2;
    self.cameraGridView.numberOfColumns = 2;
    self.cameraGridView.hidden = YES;
    [self.view addSubview:self.cameraGridView];
    
    [self setupCameraFocusViewConstraints];
    [self setupCameraGridViewConstraints];
    
    self.closeButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.frame = CGRectMake(0, 0, 44, 44);
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.closeButton setImage:image(@"NHRecorder.close") forState:UIControlStateNormal];
    self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.closeButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.flashButton.frame = CGRectMake(0, 0, 44, 44);
    self.flashButton.tintColor = [UIColor whiteColor];
    [self.flashButton setImage:[image(@"NHRecorder.flash")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    self.flashButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.flashButton addTarget:self action:@selector(flashButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.gridButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.gridButton.frame = CGRectMake(0, 0, 44, 44);
    self.gridButton.tintColor = [UIColor whiteColor];
    [self.gridButton setImage:[image(@"NHRecorder.grid")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.gridButton setImage:[image(@"NHRecorder.grid-active")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    self.gridButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.gridButton addTarget:self action:@selector(gridButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.switchButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.switchButton.frame = CGRectMake(0, 0, 44, 44);
    self.switchButton.tintColor = [UIColor whiteColor];
    [self.switchButton setImage:image(@"NHRecorder.switch") forState:UIControlStateNormal];
    self.switchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.switchButton addTarget:self action:@selector(switchButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
    UIBarButtonItem *flashBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.flashButton];
    UIBarButtonItem *gridBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.gridButton];
    UIBarButtonItem *switchBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.switchButton];
    
    self.navigationItem.leftBarButtonItems = @[closeBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               flashBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               gridBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               switchBarButton];
    

    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    [self resetFlash];
    [self resetGrid];
    
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.captureButton setTitle:nil forState:UIControlStateNormal];
    self.captureButton.backgroundColor = [UIColor whiteColor];
    [self.captureButton addTarget:self action:@selector(captureButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.videoCaptureButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.videoCaptureButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoCaptureButton.backgroundColor = [UIColor clearColor];
    [self.videoCaptureButton setTitle:nil forState:UIControlStateNormal];
    [self.videoCaptureButton setImage:image(@"NHRecorder.video") forState:UIControlStateNormal];
    [self.videoCaptureButton addTarget:self action:@selector(videoCaptureButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.videoCaptureButton.layer.cornerRadius = 5;
    self.videoCaptureButton.clipsToBounds = YES;
    self.videoCaptureButton.hidden = !self.videoCaptureEnabled;
    [self.bottomContainerView addSubview:self.videoCaptureButton];
    
    [self setupCaptureButtonConstraints];
    [self setupLibraryButtonConstraints];
    [self setupVideoCaptureButtonConstraints];
    [self resetLibrary];
   
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


- (void)deviceOrientationChange {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    CGFloat angle = 0;
    
    switch (deviceOrientation) {
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
                         self.flashButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                          self.gridButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.switchButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.libraryButton.transform = CGAffineTransformMakeRotation(angle);
                         self.videoCaptureButton.transform = CGAffineTransformMakeRotation(angle);
                     } completion:^(BOOL finished) {
                         
                     }];

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

- (void)setupCameraViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:-1]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraFocusViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraGridViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeBottom
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

- (void)setupLibraryButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:25]];
    
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

- (void)setupVideoCaptureButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCaptureButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCaptureButton
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:-25]];
    
    [self.videoCaptureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCaptureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.videoCaptureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:kNHRecorderSideButtonHeight]];
    
    [self.videoCaptureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCaptureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.videoCaptureButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
}

//MARK: Buttons

- (void)closeButtonTouch:(id)sender {
    if (self.firstController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)flashButtonTouch:(id)sender {
    if (self.photoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        return;
    }
    
    AVCaptureFlashMode newFlashMode = AVCaptureFlashModeAuto;
    
    switch (self.photoCamera.inputCamera.flashMode) {
        case AVCaptureFlashModeAuto:
            newFlashMode = AVCaptureFlashModeOff;
            break;
        case AVCaptureFlashModeOff:
            newFlashMode = AVCaptureFlashModeOn;
            break;
        case AVCaptureFlashModeOn:
            newFlashMode = AVCaptureFlashModeAuto;
            break;
        default:
            break;
    }
    
    if ([self.photoCamera.inputCamera isFlashModeSupported:newFlashMode]) {
        [self.photoCamera.inputCamera lockForConfiguration:nil];
        [self.photoCamera.inputCamera setFlashMode:newFlashMode];
        [self.photoCamera.inputCamera unlockForConfiguration];
    }
    
    [self resetFlash];
}

- (void)gridButtonTouch:(id)sender {
    self.cameraGridView.hidden = !self.cameraGridView.hidden;
    [self resetGrid];
}

- (void)switchButtonTouch:(id)sender {
    [self.photoCamera rotateCamera];
    
    if (self.photoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        self.flashButton.enabled = NO;
    }
    else {
        self.flashButton.enabled = YES;
    }
    [self resetFlash];
}

- (void)captureButtonTouch:(id)sender {
    
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    __weak __typeof(self) weakSelf = self;
    
    if (cameraStatus != AVAuthorizationStatusAuthorized) {
        if ([weakSelf.nhDelegate respondsToSelector:@selector(photoCapture:cameraAvailability:)]) {
            [weakSelf.nhDelegate
             photoCapture:weakSelf
             cameraAvailability:cameraStatus];
        }
        return;
    }
    
    self.navigationController.view.userInteractionEnabled = NO;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(photoCaptureDidStartExporting:)]) {
        [weakSelf.nhDelegate photoCaptureDidStartExporting:weakSelf];
    }
    
    [self.photoCamera capturePhotoAsImageProcessedUpToFilter:self.photoCropFilter
                                       withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                                           @autoreleasepool {
                                               
                                               weakSelf.navigationController.view.userInteractionEnabled = YES;
                                               
                                               if (error
                                                   || !processedImage) {
                                                   NSLog(@"error - %@", error);
                                                   return;
                                               }
                                               
                                               UIImage *resultImage;
                                               
                                               CGSize imageSizeToFit = CGSizeZero;
                                               
                                               if ([weakSelf.nhDelegate respondsToSelector:@selector(imageSizeToFitForPhotoCapture:)]) {
                                                   imageSizeToFit = [weakSelf.nhDelegate imageSizeToFitForPhotoCapture:weakSelf];
                                               }
                                               
                                               if (CGSizeEqualToSize(imageSizeToFit, CGSizeZero)) {
                                                   resultImage = processedImage;
                                               }
                                               else {
                                                   resultImage = [processedImage nhr_rescaleToFit:imageSizeToFit];
                                               }
                                               
                                               if ([weakSelf.nhDelegate respondsToSelector:@selector(photoCaptureDidFinishExporting:)]) {
                                                   [weakSelf.nhDelegate photoCaptureDidFinishExporting:weakSelf];
                                               }
                                               
                                               if (resultImage) {
                                                   BOOL shouldEdit = YES;
                                                   
                                                   __weak __typeof(self) weakSelf = self;
                                                   if ([weakSelf.nhDelegate respondsToSelector:@selector(photoCapture:shouldEditImage:)]) {
                                                       shouldEdit = [weakSelf.nhDelegate photoCapture:weakSelf shouldEditImage:resultImage];
                                                   }
                                                   
                                                   if (shouldEdit) {
                                                       NHPhotoEditorViewController *viewController = [[NHPhotoEditorViewController alloc] initWithUIImage:resultImage];
                                                       [self.navigationController pushViewController:viewController animated:YES];
                                                   }
                                               }
                                           }
                                       }];
}

- (void)libraryButtonTouch:(id)sender {
    NHMediaPickerViewController *viewController = [[NHMediaPickerViewController alloc]
                                                   initWithMediaType:NHMediaPickerTypePhoto];
    viewController.firstController = NO;
    viewController.linksToCamera = NO;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)videoCaptureButtonTouch:(id)sender {
    NHVideoCaptureViewController *viewController = [[NHVideoCaptureViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

//MARK: resets

- (void)resetFlash {
    NSString *imageName;
    switch (self.photoCamera.inputCamera.flashMode) {
        case AVCaptureFlashModeAuto:
            imageName = @"NHRecorder.flash-auto";
            break;
        case AVCaptureFlashModeOn:
            imageName = @"NHRecorder.flash-active";
            break;
        case AVCaptureFlashModeOff:
            imageName = @"NHRecorder.flash";
            break;
        default:
            break;
    }
    
    
    if (imageName) {
    [self.flashButton setImage:[image(imageName)
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                         forState:UIControlStateNormal];
    }
}

- (void)resetGrid {
    self.gridButton.selected = !self.cameraGridView.hidden;
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
                                                                  isEqualToString:ALAssetTypePhoto]) {
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
                               [self.libraryButton setImage:image(@"NHRecorder.library.error") forState:UIControlStateNormal];
                           }];
}


//MARK: Setters

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barTintColor = barTintColor;
    self.navigationController.navigationBar.barTintColor = barTintColor ?: [UIColor blackColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setBarButtonTintColor:(UIColor *)barButtonTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barButtonTintColor = barButtonTintColor;
    self.navigationController.navigationBar.tintColor = barButtonTintColor ?: [UIColor whiteColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setFirstController:(BOOL)firstController {
    [self willChangeValueForKey:@"firstController"];
    _firstController = firstController;
    
    [self.closeButton setImage:(firstController ? image(@"NHRecorder.close") : image(@"NHRecorder.back")) forState:UIControlStateNormal];
    [self didChangeValueForKey:@"firstController"];
}

- (void)setVideoCaptureEnabled:(BOOL)videoCaptureEnabled {
    [self willChangeValueForKey:@"videoCaptureEnabled"];
    _videoCaptureEnabled = videoCaptureEnabled;
    
    self.videoCaptureButton.hidden = !videoCaptureEnabled;
    [self didChangeValueForKey:@"videoCaptureEnabled"];
}

//MARK: View overrides


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self startCamera];
    [self resetLibrary];
}

- (void)startCamera {
    
    [self.photoCamera stopCameraCapture];    
    [self.photoCamera.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    [self resetFlash];

    [self.photoCamera startCameraCapture];
}

- (void)stopCamera {
    [self.photoCamera stopCameraCapture];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopCamera];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (void)dealloc {
    [self stopCamera];
    self.photoCamera = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}



@end

