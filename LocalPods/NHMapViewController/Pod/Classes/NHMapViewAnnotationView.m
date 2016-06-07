//
//  NHMapViewAnnotationView.m
//  Pods
//
//  Created by Sergey Minakov on 28.05.15.
//
//

#import "NHMapViewAnnotationView.h"
#import "WYPopoverController.h"

@interface NHMapViewAnnotationView ()


@property (nonatomic, strong) WYPopoverController *popoverController;
@property (nonatomic, strong) UIViewController *contentController;

@end

@implementation NHMapViewAnnotationView


- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    _useCustomAnnotation = NO;
    
    self.contentController = [[UIViewController alloc] init];
    self.contentController.view.backgroundColor = [UIColor whiteColor];

    [WYPopoverController setDefaultTheme:[WYPopoverTheme theme]];
    WYPopoverBackgroundView *appearance = [WYPopoverBackgroundView appearance];
    [appearance setTintColor:[UIColor whiteColor]];
    [appearance setFillTopColor:[UIColor whiteColor]];
    [appearance setFillBottomColor:[UIColor whiteColor]];
    [appearance setOverlayColor:[UIColor clearColor]];
    [appearance setOuterShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.35]];
    [appearance setOuterShadowBlurRadius:2.5];
    [appearance setOuterCornerRadius:12.5];
    
    self.popoverController = [[WYPopoverController alloc] initWithContentViewController:self.contentController];
    self.popoverController.popoverContentSize = CGSizeMake(100, 100);
}

- (void)showPopover {
    if (!self.useCustomAnnotation) {
        return;
    }
    [self.popoverController presentPopoverFromRect:self.bounds
                                            inView:self
                          permittedArrowDirections:WYPopoverArrowDirectionAny
                                          animated:YES];
}

@end
