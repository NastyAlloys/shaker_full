//
//  NHWebViewTitleLabel.h
//  Pods
//
//  Created by Sergey Minakov on 01.06.15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NHWebViewTitleViewState) {
    NHWebViewTitleViewStateText,
    NHWebViewTitleViewStateLoading,
    NHWebViewTitleViewStateFailed,
};

@interface NHWebViewTitleView : UIView

@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UILabel *urlLabel;

@property (nonatomic, readonly, assign) NHWebViewTitleViewState currentState;

- (void)setState:(NHWebViewTitleViewState)state;
@end
