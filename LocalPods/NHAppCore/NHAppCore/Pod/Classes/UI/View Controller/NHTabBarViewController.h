//
//  NHTabBarViewController.h
//  Pods
//
//  Created by Sergey Minakov on 22.09.15.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHTabBarViewController : UITabBarController

- (void)setTabBarHidden:(BOOL)hidden transitionCoordinator:(nullable id <UIViewControllerTransitionCoordinator>)coordinator;
- (void)setTabBarHidden:(BOOL)hidden;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END