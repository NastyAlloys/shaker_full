//
//  NHWebNavigationViewController.h
//  Pods
//
//  Created by Sergey Minakov on 01.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHWebViewController.h"

@class NHWebNavigationViewController;

@protocol NHWebNavigationViewControllerDelegate <NSObject>

@optional
- (void)didTouchOptionsButtonInWebController:(NHWebNavigationViewController*)controller;

@end

@interface NHWebNavigationViewController : UINavigationController

@property (nonatomic, weak) id<NHWebNavigationViewControllerDelegate> webDelegate;

@property (nonatomic, readonly, strong) NHWebViewController *webViewController;

@end
