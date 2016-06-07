//
//  NHVideoCaptureViewController.h
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

@import UIKit;
@import AVFoundation;

@class NHRecorderButton;
@class CaptureManager;
@class NHCameraGridView;
@class NHVideoCaptureViewController;
@class NHRecorderProgressView;
@class NHCameraCropView;

extern const NSTimeInterval kNHVideoTimerInterval;
extern const NSTimeInterval kNHVideoMaxDuration;
extern const NSTimeInterval kNHVideoMinDuration;

@protocol NHVideoCaptureViewControllerDelegate <NSObject>

@optional
- (void)nhVideoCaptureDidStart:(NHVideoCaptureViewController*)controller;
- (void)nhVideoCaptureDidFinish:(NHVideoCaptureViewController*)controller;

- (void)nhVideoCapture:(NHVideoCaptureViewController*)controller exportProgressChanged:(float)progress;
- (void)nhVideoCaptureDidStartExporting:(NHVideoCaptureViewController*)controller;
- (void)nhVideoCaptureDidStartSaving:(NHVideoCaptureViewController*)controller;
- (void)nhVideoCapture:(NHVideoCaptureViewController *)controller didFinishExportingWithSuccess:(BOOL)success;

- (void)nhVideoCapture:(NHVideoCaptureViewController *)controller didFailWithError:(NSError*)error;

- (BOOL)nhVideoCapture:(NHVideoCaptureViewController*)controller shouldEditVideoAtURL:(NSURL *)videoURL;
- (BOOL)nhVideoCapture:(NHVideoCaptureViewController*)controller cameraAvailability:(AVAuthorizationStatus)status;

- (void)nhVideoCaptureDidReset:(NHVideoCaptureViewController*)controller;

- (BOOL)nhVideoCaptureShouldSaveNonFilteredVideo:(NHVideoCaptureViewController*)controller;

@end

@interface NHVideoCaptureViewController : UIViewController

@property (nonatomic, weak) id<NHVideoCaptureViewControllerDelegate> nhDelegate;

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) CaptureManager *captureManager;
@property (nonatomic, readonly, strong) UIView *videoCameraView;
@property (nonatomic, readonly, strong) NHCameraGridView *cameraGridView;

@property (nonatomic, readonly, strong) UIView *bottomContainerView;
@property (nonatomic, readonly, strong) NHRecorderButton *removeFragmentButton;
@property (nonatomic, readonly, strong) UIButton *captureButton;

@property (nonatomic, readonly, strong) NHRecorderButton *libraryButton;

@property (nonatomic, readonly, strong) NHRecorderButton *backButton;
@property (nonatomic, readonly, strong) NHRecorderButton *gridButton;
@property (nonatomic, readonly, strong) NHRecorderButton *switchButton;

@property (nonatomic, readonly, strong) NHRecorderProgressView *durationProgressView;

@property (nonatomic, readonly, strong) NHCameraCropView *cropView;

@end
