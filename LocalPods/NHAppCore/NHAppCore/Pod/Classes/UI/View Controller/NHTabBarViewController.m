//
//  NHTabBarViewController.m
//  Pods
//
//  Created by Sergey Minakov on 22.09.15.
//
//

#import "NHTabBarViewController.h"
#import "NHAppCoreHelper.h"
@interface NHTabBarViewController ()

@end

@implementation NHTabBarViewController

- (void)setTabBarHidden:(BOOL)hidden {
    [self setTabBarHidden:hidden animated:NO];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if (!hidden) {
        self.tabBar.hidden = hidden;
    }
    else {
        frame.size.height += self.tabBar.frame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.3 : 0
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = frame;
                         
                     } completion:^(BOOL _){
                         self.tabBar.hidden = hidden;
                         [self.view layoutIfNeeded];
                     }];
    
}

- (void)setTabBarHidden:(BOOL)hidden transitionCoordinator:(nullable id <UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator
     animateAlongsideTransitionInView:self.view
     animation:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         
         UIViewController *fromViewController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
         UIViewController *toViewController = [context viewControllerForKey:UITransitionContextToViewControllerKey];
         
         self.tabBar.hidden = hidden;
         
         CGRect frame = [UIScreen mainScreen].bounds;
         
         if (!hidden) {
             frame.size.height += 1;
         }
         else {
             frame.size.height += self.tabBar.frame.size.height + 1;
         }
         
         self.view.frame = frame;
         
         UIView *fromView = fromViewController.view;
         UIView *toView = toViewController.view;
         CGRect toFrame = toView.frame;
         CGRect fromFrame = fromView.frame;
         
         toFrame.size.height -= self.tabBar.frame.size.height - 1;
         fromFrame.size.height -= self.tabBar.frame.size.height - 1;
         
         fromView.frame = fromFrame;
         toView.frame = toFrame;
         
         [self.view layoutIfNeeded];
         [fromView layoutIfNeeded];
         [toView layoutIfNeeded];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         [UIView performWithoutAnimation:^{
             if (![context isCancelled]) {
                 [self setTabBarHidden:hidden];
             }
             else {
                 UIViewController *fromViewController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
                 UIViewController *toViewController = [context viewControllerForKey:UITransitionContextToViewControllerKey];
                 UIView *fromView = fromViewController.view;
                 UIView *toView = toViewController.view;
                 CGRect frame = toView.frame;
                 
                 fromView.frame = frame;
                 
                 [self setTabBarHidden:!hidden];
             }
         }];
     }];
}

@end
