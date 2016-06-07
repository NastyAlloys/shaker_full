//
//  NHCameraFocusView.h
//  Pods
//
//  Created by Sergey Minakov on 13.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@interface NHPhotoFocusView : UIView

@property (nonatomic, weak) GPUImageVideoCamera *camera;
@property (nonatomic, weak) GPUImageCropFilter *cropFilter;


- (void)setFocusPoint:(CGPoint)point;
- (void)setFocusPoint:(CGPoint)point
             withMode:(AVCaptureFocusMode)mode;

@end
