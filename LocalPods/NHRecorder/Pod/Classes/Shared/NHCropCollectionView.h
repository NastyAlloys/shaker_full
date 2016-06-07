//
//  NHCameraCropCollectionView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoView.h"

@class NHCropCollectionView;

@protocol NHCropCollectionViewDelegate <NSObject>

@optional
- (void)cropView:(NHCropCollectionView*)cropView didSelectType:(NHPhotoCropType)type;

@end
@interface NHCropCollectionView : UICollectionView

@property (nonatomic, weak) id<NHCropCollectionViewDelegate> nhDelegate;

- (void)setSelected:(NSInteger)index;

@end
