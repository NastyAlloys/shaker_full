//
//  NHNavigationController.m
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import "NHNavigationController.h"
#import "NHViewController.h"

@interface NHNavigationController ()<UINavigationControllerDelegate>

@end

@implementation NHNavigationController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (void)nhCommonInit {
    self.delegate = self;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.topViewController isKindOfClass:[NHViewController class]]) {
        [UIView performWithoutAnimation:^{
            [((NHViewController*)self.topViewController).searchController hideSearch];
        }];
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if ([self.topViewController isKindOfClass:[NHViewController class]]) {
        [UIView performWithoutAnimation:^{
            [((NHViewController*)self.topViewController).searchController hideSearch];
        }];
    }
    
    return [super popViewControllerAnimated:animated];
}

@end

@implementation NHNavigationController (UINavigationControllerDelegate)

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if (navigationController.interactivePopGestureRecognizer.state == UIGestureRecognizerStatePossible
        && navigationController.view.window) {
        navigationController.view.userInteractionEnabled = NO;
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    navigationController.view.userInteractionEnabled = YES;
}

@end
