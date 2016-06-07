//
//  NHContainerView.h
//  Pods
//
//  Created by Naithar on 29.04.15.
//
//

@import UIKit;

@interface NHContainerView : UIView

@property (nonatomic, assign) CGSize contentSize;

- (void)calculateContentSize;
- (void)addSubview:(UIView *)view andIndex:(NSUInteger)index;
- (void)addSubview:(UIView *)view withSize:(CGSize)size andIndex:(NSUInteger)index;
@end
