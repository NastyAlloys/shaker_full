/*
     File: CaptureManager.m
 
 Based on AVCamCaptureManager by Apple
 
 Abstract: Uses the AVCapture classes to capture video and still images.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "CaptureManager.h"
#import "AVCamRecorder.h"
#import "AVCamUtilities.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/CGImageProperties.h>

#define MAX_DURATION 0.25

@interface NHAssetContainer : NSObject

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

@end

@implementation NHAssetContainer

- (instancetype)initWithAsset:(AVAsset*)asset andCameraPosition:(AVCaptureDevicePosition)position {
    self = [super init];
    if (self) {
        _asset = asset;
        _captureDevicePosition = position;
    }
    
    return self;
}

@end

@interface CaptureManager (RecorderDelegate) <AVCamRecorderDelegate>
@end


#pragma mark -
@interface CaptureManager (InternalUtilityMethods)
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
- (AVCaptureDevice *) audioDevice;
- (NSURL *) tempFileURL;
- (void) removeFile:(NSURL *)outputFileURL;
- (void) copyFileToDocuments:(NSURL *)fileURL;
@end


#pragma mark -
@implementation CaptureManager

- (id) init
{
    self = [super init];
    if (self != nil) {
		__weak __typeof(self) weakSelf = self;
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
			BOOL sessionHasDeviceWithMatchingMediaType = NO;
			NSString *deviceMediaType = nil;
			if ([device hasMediaType:AVMediaTypeAudio])
                deviceMediaType = AVMediaTypeAudio;
			else if ([device hasMediaType:AVMediaTypeVideo])
                deviceMediaType = AVMediaTypeVideo;
			
			if (deviceMediaType != nil) {
				for (AVCaptureDeviceInput *input in [weakSelf.session inputs])
				{
					if ([[input device] hasMediaType:deviceMediaType]) {
						sessionHasDeviceWithMatchingMediaType = YES;
						break;
					}
				}
				
				if (!sessionHasDeviceWithMatchingMediaType) {
					NSError	*error;
					AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
					if ([weakSelf.session canAddInput:input])
						[weakSelf.session addInput:input];
				}				
			}
            
			if ([weakSelf.delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
				[weakSelf.delegate captureManagerDeviceConfigurationChanged:weakSelf];
			}			
        };
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
			if ([device hasMediaType:AVMediaTypeAudio]) {
				[weakSelf.session removeInput:[weakSelf audioInput]];
				[weakSelf setAudioInput:nil];
			}
			else if ([device hasMediaType:AVMediaTypeVideo]) {
				[weakSelf.session removeInput:[weakSelf videoInput]];
				[weakSelf setVideoInput:nil];
			}
			
			if ([weakSelf.delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
				[weakSelf.delegate captureManagerDeviceConfigurationChanged:weakSelf];
			}			
        };
        
        self.assets = [[NSMutableArray alloc] init];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		
		self.orientation = AVCaptureVideoOrientationPortrait;
    }
    
    return self;
}

- (void) dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[self deviceConnectedObserver]];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[self session] stopRunning];
}

- (BOOL) setupSession
{
    BOOL success = NO;
    
    //Torch or flash can be set here. I personaly don't like it 
	// Set torch and flash mode to auto
/*	if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	if ([[self backFacingCamera] hasTorch]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeAuto]) {
				[[self backFacingCamera] setTorchMode:AVCaptureTorchModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}*/
	
    // Init the device inputs
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    
    // Create session (use default AVCaptureSessionPresetHigh)
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    
    
    // Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    if ([newCaptureSession canAddInput:newAudioInput]) {
        [newCaptureSession addInput:newAudioInput];
    }

    [self setVideoInput:newVideoInput];
    [self setAudioInput:newAudioInput];
    [self setSession:newCaptureSession];
    
	// Set up the movie file output
    NSURL *outputFileURL = [self tempFileURL];
    AVCamRecorder *newRecorder = [[AVCamRecorder alloc] initWithSession:[self session] outputFileURL:outputFileURL];
    [newRecorder setDelegate:self];
	
	// Send an error to the delegate if video recording is unavailable
	if (![newRecorder recordsVideo] && [newRecorder recordsAudio]) {
		NSString *localizedDescription = NSLocalizedString(@"Video recording unavailable", @"Video recording unavailable description");
		NSString *localizedFailureReason = NSLocalizedString(@"Movies recorded on this device will only contain audio. They will be accessible through iTunes file sharing.", @"Video recording unavailable failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey, 
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey, 
								   nil];
		NSError *noVideoError = [NSError errorWithDomain:@"AVCam" code:0 userInfo:errorDict];
		if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
			[[self delegate] captureManager:self didFailWithError:noVideoError];
		}
	}
	
	[self setRecorder:newRecorder];
	
    success = YES;
    
    return success;
}

- (void)switchCamera
{
    NSArray* inputs = self.session.inputs;
    for (AVCaptureDeviceInput* input in inputs) {
        AVCaptureDevice* device = input.device;
        if ([device hasMediaType: AVMediaTypeVideo]) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice* newCamera = nil;
            AVCaptureDeviceInput* newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition: AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition: AVCaptureDevicePositionFront];
            
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error: nil] ;
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.session beginConfiguration] ;
            
            [self.session removeInput :input] ;
            [self.session addInput : newInput] ;
            
            //Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration] ;
            break ;
        }
    }
}


- (AVCaptureDevicePosition)currentCameraPosition {
    __block AVCaptureDevicePosition position;
    NSArray* inputs = self.session.inputs;
    for (AVCaptureDeviceInput* input in inputs) {
        AVCaptureDevice* device = input.device;
        if ([device hasMediaType: AVMediaTypeVideo]) {
            position = device.position;
            break;
        }
    }
    
    return position;
}

- (void) startRecording
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns
		// to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library
		// when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error:
		// after the recorded file has been saved.
        [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}]];
    }
    
    self.recordingDevicePosition = [self currentCameraPosition];
    
    [self removeFile:[[self recorder] outputFileURL]];
    [[self recorder] startRecordingWithOrientation:self.orientation];
    
}

- (void) stopRecording
{
    [[self recorder] stopRecording];
}

- (BOOL) saveVideoWithCompletionBlock:(void (^)(NSURL*))completion
{
    if ([self.assets count]
        && !self.exportSession) {

        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        // 2 - Video track
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];        
        __block CMTime time = kCMTimeZero;
//        __block 
        __block CGSize size = CGSizeZero;
        
        // Also tried videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack
        AVMutableVideoCompositionLayerInstruction *vLayerInstruction = [AVMutableVideoCompositionLayerInstruction
                                                                        videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        [self.assets enumerateObjectsUsingBlock:^(NHAssetContainer *assetContainer, NSUInteger idx, BOOL *stop) {
            AVAsset *asset = assetContainer.asset;
            
            AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            CGFloat desiredAspectRatio = 1.0;
            CGSize naturalSize = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
            CGSize adjustedSize = CGSizeApplyAffineTransform(naturalSize, videoAssetTrack.preferredTransform);
            adjustedSize.width = ABS(adjustedSize.width);
            adjustedSize.height = ABS(adjustedSize.height);
            
            CGSize newSize = CGSizeZero;
            if (adjustedSize.width > adjustedSize.height) {
                                    newSize = CGSizeMake(adjustedSize.height * desiredAspectRatio, adjustedSize.height);
//                translate = CGAffineTransformMakeTranslation(-(adjustedSize.width - size.width) / 2.0, 0);
            } else {
                                    newSize = CGSizeMake(adjustedSize.width, adjustedSize.width / desiredAspectRatio);
//                translate = CGAffineTransformMakeTranslation(0, -(adjustedSize.height - size.height) / 2.0);
            }
            
            if (newSize.width
                && newSize.height
                && size.width < newSize.width) {
                size = newSize;
            }
        }];
        
        [self.assets enumerateObjectsUsingBlock:^(NHAssetContainer *assetContainer, NSUInteger idx, BOOL *stop) {
            AVAsset *asset = assetContainer.asset;
            
           // AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:string]];//obj]];
            AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                           ofTrack:videoAssetTrack atTime:time error:nil];
            
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:[asset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:time error:nil];
//            if(idx == 0)
//            {
            
                // Set your desired output aspect ratio here. 1.0 for square, 16/9.0 for widescreen, etc.
            
                CGAffineTransform translate;
                CGSize naturalSize = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
                CGSize adjustedSize = CGSizeApplyAffineTransform(naturalSize, videoAssetTrack.preferredTransform);
                adjustedSize.width = ABS(adjustedSize.width);
                adjustedSize.height = ABS(adjustedSize.height);
            
            CGFloat xValue = (adjustedSize.width - size.width);
            CGFloat yValue = (adjustedSize.height - size.height);
            UIInterfaceOrientation orientation = [self orientationForTrack:asset];
            BOOL isPortrait = orientation == UIInterfaceOrientationMaskPortrait || orientation == UIInterfaceOrientationMaskPortraitUpsideDown;
            BOOL shouldMirror = assetContainer.captureDevicePosition == AVCaptureDevicePositionFront;
            
            if (adjustedSize.width > adjustedSize.height) {
                translate = CGAffineTransformMakeTranslation(-xValue / 2.0, 0);
            } else {
                translate = CGAffineTransformMakeTranslation(0, -yValue / 2.0);
            }
            
            CGAffineTransform newTransform = CGAffineTransformConcat(videoAssetTrack.preferredTransform, translate);
            
            if (shouldMirror) {
                switch (orientation) {
                    case UIInterfaceOrientationPortraitUpsideDown:
                        newTransform = CGAffineTransformTranslate(newTransform, size.width / 2, -size.height / 2);
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        newTransform = CGAffineTransformTranslate(newTransform, -size.width / 2, size.height / 2);
                        break;
                    default:
                        newTransform = CGAffineTransformTranslate(newTransform, size.width / 2, size.height / 2);
                        break;
                }
                
                newTransform = CGAffineTransformConcat(newTransform,
                                                       CGAffineTransformMakeScale(-1, 1));
                newTransform = CGAffineTransformConcat(newTransform,
                                                       CGAffineTransformMakeTranslation(size.width / 2,
                                                                                        (isPortrait ? 1 : -1) * size.height / 2));
            }
            
            CGFloat xDelta = size.width / adjustedSize.width;
            CGFloat yDelta = size.height / adjustedSize.height;
            CGFloat scaleDelta = MAX(xDelta, yDelta);
            
            if (scaleDelta > 1) {
                switch (orientation) {
                    case UIInterfaceOrientationPortrait:
                    case UIInterfaceOrientationPortraitUpsideDown:
                        newTransform = CGAffineTransformConcat(newTransform,
                                                               CGAffineTransformMakeTranslation(
                                                                                                (shouldMirror
                                                                                                 ? -size.width / 2 - xValue / 2
                                                                                                 : 0),
                                                                                                -yValue));
                        newTransform = CGAffineTransformConcat(newTransform, CGAffineTransformMakeScale(scaleDelta, scaleDelta));
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                    case UIInterfaceOrientationLandscapeRight:
                        newTransform = CGAffineTransformConcat(newTransform,
                                                               CGAffineTransformMakeTranslation(-xValue,
                                                                                                0));
                        newTransform = CGAffineTransformConcat(newTransform, CGAffineTransformMakeScale(scaleDelta, scaleDelta));
                        break;
                    default:
                        break;
                }
            }
            
                [vLayerInstruction setTransform:newTransform atTime:time];
            
                // Check the output size - for best results use sizes that are multiples of 16
                // More info: http://stackoverflow.com/questions/22883525/avassetexportsession-giving-me-a-green-border-on-right-and-bottom-of-output-vide
                if (fmod(size.width, 4.0) != 0)
                    NSLog(@"NOTE: The video output width %0.1f is not a multiple of 4, which may cause a green line to appear at the edge of the video", size.width);
                if (fmod(size.height, 4.0) != 0)
                    NSLog(@"NOTE: The video output height %0.1f is not a multiple of 4, which may cause a green line to appear at the edge of the video", size.height);
//            }
            
            time = CMTimeAdd(time, asset.duration);
        }];
        
        AVMutableVideoCompositionInstruction *vtemp = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        vtemp.timeRange = CMTimeRangeMake(kCMTimeZero, time);        
        vtemp.layerInstructions = @[vLayerInstruction];
        
        AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.renderSize = size;
        videoComposition.frameDuration = CMTimeMake(1,30);
        videoComposition.instructions = @[vtemp];
        
        // 4 - Get path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"mergedVideo.mov"]];
        unlink([path UTF8String]);
        NSURL *url = [NSURL fileURLWithPath:path];

        // 5 - Create exporter
        self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetHighestQuality];
        self.exportSession.outputURL = url;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        self.exportSession.shouldOptimizeForNetworkUse = YES;
        self.exportSession.videoComposition = videoComposition;
        
        [self.exportProgressBarTimer invalidate];
        self.exportProgressBarTimer = nil;
        self.exportProgressBarTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateExportProgress:) userInfo:nil repeats:YES];
        
        __weak __typeof(self) weakSelf = self;
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf exportDidFinish:weakSelf.exportSession withCompletionBlock:completion];
            });
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)updateExportProgress:(NSTimer*)timer {
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.delegate respondsToSelector:@selector(updateProgress)]) {
        [weakSelf.delegate updateProgress];
    }
}

//http://stackoverflow.com/questions/21077240/cropping-avasset-video-with-avfoundation
- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset {
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = tracks.firstObject;
        CGAffineTransform t = videoTrack.preferredTransform;
        
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            orientation = UIInterfaceOrientationPortrait;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            orientation = UIInterfaceOrientationPortraitUpsideDown;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            orientation = UIInterfaceOrientationLandscapeLeft;
        }
    }
    return orientation;
}

-(void)exportDidFinish:(AVAssetExportSession*)session withCompletionBlock:(void(^)(NSURL* assetURL))completion {
    self.exportSession = nil;
    
    __weak __typeof(self) weakSelf = self;
    //delete stored pieces
    [self.assets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NHAssetContainer *assetContainer, NSUInteger idx, BOOL *stop) {
        AVAsset *asset = assetContainer.asset;
        
        NSURL *fileURL = nil;
        if ([asset isKindOfClass:AVURLAsset.class])
        {
            AVURLAsset *urlAsset = (AVURLAsset*)asset;
            fileURL = urlAsset.URL;
        }
        
        if (fileURL)
            [weakSelf removeFile:fileURL];
    }];
    
    [self.exportProgressBarTimer invalidate];
    self.exportProgressBarTimer = nil;
    [self.delegate removeProgress];
    
    BOOL shouldSave = YES;
    
    if ([self.delegate respondsToSelector:@selector(captureManagerShouldSaveToCameraRoll:)]) {
        shouldSave = [self.delegate captureManagerShouldSaveToCameraRoll:self];
    }
    
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        
        if (shouldSave) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
                [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                    if (error) {
#ifdef DEBUG
                        NSLog(@"error = %@", error);
#endif
                        if ([weakSelf.delegate respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                            [weakSelf.delegate captureManager:weakSelf didFailWithError:error];
                        }
                        completion (outputURL);
                    } else {
                        [weakSelf removeFile:outputURL];
                        completion (assetURL);
                    }
                }];
            }
            
        }
        else {
            completion (outputURL);
        }
    }
}


#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    NSLog(@"COUNT");
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}


#pragma mark Camera Properties
// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void) autoFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }        
    }
}

// Switch to continuous auto focus mode at the specified point
- (void) continuousFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
	
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
			}
		}
	}
}

- (NSTimeInterval)currentDuration {
    __block NSTimeInterval returnValue = 0;
    
    [self.assets enumerateObjectsUsingBlock:^(NHAssetContainer *obj, NSUInteger idx, BOOL *stop) {
        returnValue += CMTimeGetSeconds(obj.asset.duration);
    }];
    
    return returnValue;
}

- (NSTimeInterval)lastAssetDuration {
    AVAsset *asset = ((NHAssetContainer*)[self.assets lastObject]).asset;
    return CMTimeGetSeconds(asset.duration);
}

-(void) deleteLastAsset
{
    AVAsset *asset = ((NHAssetContainer*)[self.assets lastObject]).asset;
    
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    
    NSURL *fileURL = nil;
    if ([asset isKindOfClass:AVURLAsset.class])
    {
        AVURLAsset *urlAsset = (AVURLAsset*)asset;
        fileURL = urlAsset.URL;
    }
    
    if (fileURL)
        [self removeFile:fileURL];
    
    [self.assets removeLastObject];
    
    [self.delegate removeTimeFromDuration:duration];
}

@end


#pragma mark -
@implementation CaptureManager (InternalUtilityMethods)

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

- (NSURL *) tempFileURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"]];
}

- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }            
        }
    }
}

- (void) copyFileToDocuments:(NSURL *)fileURL
{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
	NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/output_%@.mov", [dateFormatter stringFromDate:[NSDate date]]];
    
	NSError	*error;
	if (![[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error]) {
		if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
			[[self delegate] captureManager:self didFailWithError:error];
		}
	}
    
    //add asset into the array or pieces
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:destinationPath]];
    [self.assets addObject:[[NHAssetContainer alloc] initWithAsset:asset andCameraPosition:self.recordingDevicePosition]];
}

@end


#pragma mark -
@implementation CaptureManager (RecorderDelegate)

-(void)recorderRecordingDidBegin:(AVCamRecorder *)recorder
{
    if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingBegan:)]) {
        [[self delegate] captureManagerRecordingBegan:self];
    }
}

-(void)recorder:(AVCamRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
    //save file in the app's Documents directory for this session
    [self copyFileToDocuments:outputFileURL];
    
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[UIApplication sharedApplication] endBackgroundTask:[self backgroundRecordingID]];
    }
    
    if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingFinished:)]) {
        [[self delegate] captureManagerRecordingFinished:self];
    }
}

@end
