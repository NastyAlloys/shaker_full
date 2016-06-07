//
//  NHFilterCollectionViewCell.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@interface NHFilterCollectionViewCell : UICollectionViewCell

- (void)reloadWithImage:(UIImage*)image
              andFilter:(GPUImageFilter*)filter;
- (void)reloadWithImage:(UIImage*)image
              andFilter:(GPUImageFilter*)filter
             isSelected:(BOOL)selected;
- (void)reloadWithImage:(UIImage*)image
              andFilter:(GPUImageFilter*)filter
                andName:(NSString*)name
             isSelected:(BOOL)selected;
@end
