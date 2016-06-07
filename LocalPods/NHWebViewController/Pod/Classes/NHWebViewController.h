//
//  NHWebViewController.h
//  Pods
//
//  Created by Sergey Minakov on 01.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHWebViewTitleView.h"

@interface NHWebViewController : UIViewController

@property (nonatomic, readonly, strong) UIWebView *webView;
@property (nonatomic, readonly, strong) NHWebViewTitleView *titleView;

@property (nonatomic, readonly, weak) UIBarButtonItem *backButton;
@property (nonatomic, readonly, weak) UIBarButtonItem *forwardButton;
@property (nonatomic, readonly, weak) UIBarButtonItem *updateButton;

@property (nonatomic, readonly, strong) UIProgressView *progressView;

- (void)setUrlPath:(NSString*)urlPath;
- (void)setUrl:(NSURL*)url;

- (void)updateCurrentPage;
- (void)moveToPreviousPage;
- (void)moveToNextPage;
- (void)openInSafari;
- (void)copyLink;

@end
