//
//  NHSearchBar.h
//  Pods
//
//  Created by Sergey Minakov on 13.08.15.
//
//

@import UIKit;
#import "NHSearchTextField.h"

extern const CGFloat kNHSearchButtonWidth;

@interface NHSearchBar : UIView

@property (nonatomic, readonly, strong) NHSearchTextField *textField;
@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UIButton *button;
@property (nonatomic, readonly, strong) UIView *topSeparator;
@property (nonatomic, readonly, strong) UIView *bottomSeparator;


- (void)setCloseButtonHidden:(BOOL)hidden;

@end