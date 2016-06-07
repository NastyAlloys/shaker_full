//
//  NHCameraCropView.h
//  Pods
//
//  Created by Sergey Minakov on 28.07.15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NHPhotoCropType) {
    NHPhotoCropTypeNone,
    NHPhotoCropTypeSquare,
    NHPhotoCropTypeCircle,
    NHPhotoCropType4x3,
    NHPhotoCropType16x9,
    NHPhotoCropType3x4
};

@interface NHCameraCropView : UIView

@property (nonatomic, strong) UIColor *cropBackgroundColor;
@property (nonatomic, assign) CGSize maxCropSize;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, assign) NHPhotoCropType cropType;
@property (nonatomic, assign) BOOL showBorder;


- (CGRect)cropRegionForView:(UIView*)view;
- (void)resetCrop;
@end
