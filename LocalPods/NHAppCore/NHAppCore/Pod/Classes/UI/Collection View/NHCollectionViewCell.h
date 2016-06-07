//
//  NHCollectionViewCell.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import <UIKit/UIKit.h>

@interface NHCollectionViewCell<__covariant T> : UICollectionViewCell

- (void)reset;
- (void)reload:(T)value;

@end
