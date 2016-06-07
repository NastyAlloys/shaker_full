//
//  NHCollectionHeaderFooterView.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

@import UIKit;

@class NHModelObject;

@interface NHCollectionHeaderFooterView<__covariant T> : UICollectionReusableView

- (void)reset;
- (void)reload:(T)value;

@end
