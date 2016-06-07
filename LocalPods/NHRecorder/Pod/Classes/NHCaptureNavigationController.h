//
//  NHCameraNavigationController.h
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoCaptureViewController.h"
#import "NHPhotoEditorViewController.h"
#import "NHMediaPickerViewController.h"

typedef NS_ENUM(NSUInteger, NHCaptureType) {
    NHCaptureTypePhotoCamera,
    NHCaptureTypeMediaPicker,
};

@interface NHCaptureNavigationController : UINavigationController

- (instancetype)initWithType:(NHCaptureType)type;

@end
