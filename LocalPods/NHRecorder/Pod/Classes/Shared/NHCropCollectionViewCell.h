//
//  NHCropCollectionViewCell.h
//  Pods
//
//  Created by Sergey Minakov on 15.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoView.h"

@interface NHCropCollectionViewCell : UICollectionViewCell

- (void)reloadWithType:(NHPhotoCropType)type;
- (void)reloadWithType:(NHPhotoCropType)type andSelected:(BOOL)selected;
@end
