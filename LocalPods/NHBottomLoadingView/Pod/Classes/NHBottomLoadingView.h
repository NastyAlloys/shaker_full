//
//  NHBottomLoadingView.h
//  Pods
//
//  Created by Sergey Minakov on 06.05.15.
//
//

@import UIKit;

typedef NS_ENUM(NSUInteger, NHBottomLoadingViewState) {
    NHBottomLoadingViewStateLoading,
    NHBottomLoadingViewStateNoResults,
    NHBottomLoadingViewStateFinished,
    NHBottomLoadingViewStateFailed,
    NHBottomLoadingViewStateView
};

typedef void(^NHBottomLoadingViewBlock)(void);

@interface NHBottomLoadingView : NSObject

@property (nonatomic, readonly, assign) NHBottomLoadingViewState viewState;


@property (nonatomic, copy) NSString *noResultText;
@property (nonatomic, strong) UIColor *noResultsTextColor;
@property (nonatomic, strong) UIFont *noResultsTextFont;

@property (nonatomic, copy) NSString *failedText;
@property (nonatomic, copy) NSString *failedNoConnectionText;
@property (nonatomic, copy) NSString *failedSubtext;
@property (nonatomic, strong) UIColor *failedTextColor;
@property (nonatomic, strong) UIFont *failedTextFont;
@property (nonatomic, strong) UIColor *failedSubtextColor;
@property (nonatomic, strong) UIFont *failedSubtextFont;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, assign) CGFloat loadingOffset;

@property (nonatomic, copy) NHBottomLoadingViewBlock refreshBlock;

- (instancetype)initWithScrollView:(UIScrollView*)scrollView;
- (instancetype)initWithScrollView:(UIScrollView*)scrollView withBlock:(NHBottomLoadingViewBlock)block;
- (instancetype)initWithScrollView:(UIScrollView*)scrollView
                      withAutoload:(BOOL)autoload
                         withBlock:(NHBottomLoadingViewBlock)block;

- (void)setState:(NHBottomLoadingViewState)state;
- (void)setState:(NHBottomLoadingViewState)state animated:(BOOL)animated;

- (void)setView:(UIView*)view forKey:(NSString*)key;
- (void)setView:(UIView*)view withHeight:(CGFloat)height forKey:(NSString*)key;
- (UIView*)setViewWithKey:(NSString*)key;
- (UIView*)setViewWithKey:(NSString*)key animated:(BOOL)animated;

- (void)startRefreshing;
- (void)stopRefreshing;
- (UIView*)viewForCurrentState;

@end
