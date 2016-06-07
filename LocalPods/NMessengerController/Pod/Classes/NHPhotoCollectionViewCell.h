//
//  NHPhotoCollectionViewCell.h
//  Pods
//
//  Created by Naithar on 30.04.15.
//
//

#import <UIKit/UIKit.h>

@protocol NHPhotoCollectionViewCellDelegate <NSObject>

@optional
-(void)didTouchCloseButton:(UICollectionViewCell*)cell;

@end

@interface NHPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<NHPhotoCollectionViewCellDelegate> delegate;

- (void)reloadWithImage:(UIImage*)image;

@end
