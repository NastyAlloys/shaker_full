//
//  NHImagePickerViewController.h
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHRecorderButton.h"

typedef NS_ENUM(NSUInteger, NHMediaPickerType) {
    NHMediaPickerTypePhoto,
    NHMediaPickerTypeVideo,
    NHMediaPickerTypeAll,
};
@class NHMediaPickerViewController;

@protocol NHMediaPickerViewControllerDelegate <NSObject>

@optional
- (BOOL)mediaPicker:(NHMediaPickerViewController*)controller
     shouldEditImage:(UIImage*)image;
- (CGSize)imageSizeToFitForMediaPicker:(NHMediaPickerViewController*)controller;

- (void)mediaPickerDidStartExporting:(NHMediaPickerViewController*)controller;
- (void)mediaPickerDidFinishExporting:(NHMediaPickerViewController*)controller;
@end

@interface NHMediaPickerViewController : UIViewController

@property (nonatomic, weak) id<NHMediaPickerViewControllerDelegate> nhDelegate;

@property (nonatomic, assign) NHMediaPickerType mediaType;

@property (nonatomic, assign) BOOL firstController;

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;


@property (nonatomic, assign) BOOL linksToCamera;

@property (nonatomic, readonly, strong) UICollectionView *mediaCollectionView;
@property (nonatomic, readonly, strong) NHRecorderButton *closeButton;


- (instancetype)initWithMediaType:(NHMediaPickerType)type;

@end
