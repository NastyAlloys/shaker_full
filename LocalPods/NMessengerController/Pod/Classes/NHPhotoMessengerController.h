//
//  NHPhotoMessengerController.h
//  Pods
//
//  Created by Naithar on 30.04.15.
//
//

#import "NHMessengerController.h"

@class NHPhotoMessengerController;

@protocol NHPhotoMessengerControllerDelegate <NSObject>

@optional
- (void)photoMessenger:(NHPhotoMessengerController*)messenger didSendPhotos:(NSArray*)array;

@end

@interface NHPhotoMessengerController : NHMessengerController

@property (nonatomic, weak) id<NHPhotoMessengerControllerDelegate> photoDelegate;

@property (nonatomic, readonly, strong) UIButton *attachmentButton;
@property (nonatomic, readonly, strong) UICollectionView *photoCollectionView;
@property (nonatomic, readonly, copy) NSArray *imageArray;


- (void)addImageToCollection:(UIImage*)image;
- (void)clearImageArray;

@end
