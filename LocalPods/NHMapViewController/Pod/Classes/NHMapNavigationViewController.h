//
//  NHMapNavigationViewController.h
//  Pods
//
//  Created by Sergey Minakov on 28.05.15.
//
//

#import <UIKit/UIKit.h>
#import "NHMapViewController.h"

@class NHMapNavigationViewController;

@protocol NHMapViewControllerDelegate <NSObject>

@optional
- (void)didTouchOptionsButtonInMapController:(NHMapNavigationViewController*)controller;

@end
@interface NHMapNavigationViewController : UINavigationController

@property (nonatomic, weak) id<NHMapViewControllerDelegate> mapDelegate;

@property (nonatomic, readonly, strong) NHMapViewController *mapViewController;

+ (Class)mapViewControllerClass;

@end
