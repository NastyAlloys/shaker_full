//
//  NHSearchViewController.m
//  Pods
//
//  Created by Sergey Minakov on 12.08.15.
//
//

#import "NHSearchController.h"


#define SYSTEM_VERSION_LESS_THAN(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)



@interface NHSearchController ()<UITextFieldDelegate, NHSearchTextFieldDelegate>

@property (nonatomic, weak) UIViewController *container;
@property (nonatomic, weak) UIView *searchBackgroundView;

@property (nonatomic, assign) CGRect searchBarInitialRect;
@property (nonatomic, assign) CGRect searchBarContainerInitialRect;

@property (nonatomic, strong) NHSearchBar *searchBar;

@property (nonatomic, strong) NHSearchResultView *searchResultView;

@property (nonatomic, assign) BOOL searchEnabled;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, weak) UIView *initialSearchBarSuperview;

@property (nonatomic, assign) BOOL bottonSeparatorState;
@property (nonatomic, copy) NSString *searchText;

@end

@implementation NHSearchController

- (instancetype)initWithContainerViewController:(UIViewController*)container {
    return [self initWithContainerViewController:container andBackgroundView:nil];
}

- (instancetype)initWithContainerViewController:(UIViewController*)container
                              andBackgroundView:(UIView*)view {
    self = [super init];
    
    if (self) {
        _container = container;
        _searchBackgroundView = view;
        _shouldOffsetStatusBar = YES;
        [self nhCommonInit];
    }
    return self;
}


- (void)nhCommonInit {
    self.searchBar = [[NHSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.backgroundColor = [UIColor lightGrayColor];
    self.searchBar.textField.delegate = self;
    self.searchBar.textField.nhDelegate = self;
    [self.searchBar.button addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchResultView = [[NHSearchResultView alloc] initWithBackgroundView:self.searchBackgroundView];
    self.searchResultView.backgroundColor = self.searchBackgroundView ? [UIColor whiteColor] : [UIColor clearColor];
    self.searchResultView.overlayColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    self.tapGesture.cancelsTouchesInView = NO;
    [self.searchResultView addGestureRecognizer:self.tapGesture];
    
    [self.searchBar setNeedsLayout];
    [self.searchBar layoutIfNeeded];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self startSearch];
}

- (void)closeButtonTouch:(UIButton*)button {
    [self stopSearch];
}

- (void)tapGestureAction:(UITapGestureRecognizer*)recognizer {
    if ([self.searchBar.textField.text length]) {
        return;
    }
    
    [self stopSearch];
}

- (void)changeText:(NSString*)text {
    if (!self.searchEnabled
        || [self.searchText isEqualToString:text]) {
        return;
    }
    
    self.searchResultView.tableView.hidden = ![text length];
    
    if ([self.nhDelegate respondsToSelector:@selector(nhSearchController:didChangeText:)]) {
        [self.nhDelegate nhSearchController:self didChangeText:text];
    }
    
    self.searchText = text;
}

- (void)startSearch {
    
    if (self.searchEnabled) {
        return;
    }
    
    self.searchEnabled = YES;
    
    [self showSearch];
    
    if ([self.nhDelegate respondsToSelector:@selector(nhSearchControllerWillBegin:)]) {
        [self.nhDelegate nhSearchControllerDidBegin:self];
    }
}

- (void)stopSearch {
    [self stopSearch:NO];
}


- (void)stopSearch:(BOOL)force {
    if (!self.searchEnabled) {
        return;
    }
    
    self.searchEnabled = NO;
    self.searchBar.textField.text = nil;
    [self.searchBar setCloseButtonHidden:YES];
    
    [self hideSearch:force];
    
    if ([self.nhDelegate respondsToSelector:@selector(nhSearchControllerDidEnd:)]) {
        [self.nhDelegate nhSearchControllerDidEnd:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if ([self.nhDelegate respondsToSelector:@selector(nhSearchController:didChangeText:)]) {
        [self.nhDelegate nhSearchController:self didChangeText:self.searchText];
    }
    
    return YES;
}

- (void)hideSearch {
    [self hideSearch:NO];
}

- (void)hideSearch:(BOOL)force {
    if (CGRectEqualToRect(CGRectZero, self.searchBarInitialRect)
        || !self.containerWindow) {
        return;
    }
    
    [self.searchBar.textField resignFirstResponder];
    
    CGRect resultFrame = self.searchResultView.frame;
    
    resultFrame.origin.y = CGRectGetMaxY(self.searchBarContainerInitialRect);
    
    self.searchBar.bottomSeparator.hidden = self.bottonSeparatorState;
    
    [UIView animateWithDuration:(force ? 0 : 0.25)
                          delay:0
                        options:(UIViewAnimationOptionBeginFromCurrentState
                                 |UIViewAnimationCurveEaseIn)
                     animations:^{
                         self.searchBar.frame = self.searchBarContainerInitialRect;
                         self.searchBar.textField.textAlignment = NSTextAlignmentCenter;
                         self.searchResultView.frame = resultFrame;
                         [self.searchBar layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:(force ? 0 : 0.15) animations:^{
                             self.searchResultView.alpha = 0;
                         } completion:^(BOOL finished) {
                             [self.searchResultView removeFromSuperview];
                             self.searchBar.frame = self.searchBarInitialRect;
                             [self.containerWindow removeFromSuperview];
                             [self.initialSearchBarSuperview addSubview:self.searchBar];
                             [self.container.view setNeedsLayout];
                             [self.container.view layoutIfNeeded];
                             self.containerWindow.hidden = YES;
                             self.containerWindow = nil;
                             [[[UIApplication sharedApplication] delegate].window makeKeyWindow];
                         }];
                     }];
}


- (void)showSearch {
    if (!self.searchEnabled) {
        return;
    }
    
    self.searchBarInitialRect = self.searchBar.frame;
    self.initialSearchBarSuperview = self.searchBar.superview;
    
    self.searchBarContainerInitialRect = [self.searchBar convertRect:self.searchBar.bounds toView:self.container.view];
    CGRect newSearchBarFrame = self.searchBarContainerInitialRect;
    CGRect newContainerFrame = self.container.view.frame;
    
    CGRect backgroundViewOffsetRect = [self.searchBar convertRect:self.searchBar.bounds toView:self.searchBackgroundView];
    [self.searchResultView prepareWithOffsetPoint:CGPointMake(0, CGRectGetMaxY(backgroundViewOffsetRect))];
    
    self.searchBar.frame = newSearchBarFrame;
    
    [self.containerWindow removeFromSuperview];
    self.containerWindow = nil;
    
    // TODO make as container controller
    //self.containerWindow = [[UIView alloc] initWithFrame:self.container.view.bounds];
    //UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] //rootViewController];
    //[root.view addSubview:self.containerWindow];
    //[root.view bringSubviewToFront:self.containerWindow];
    
    self.containerWindow = [[UIWindow alloc] initWithFrame:self.container.view.bounds];
    [self.containerWindow makeKeyAndVisible];
    
    self.containerWindow.rootViewController = self;
    [self.containerWindow sendSubviewToBack:self.view];
    
    [self.containerWindow addSubview:self.searchBar];
    [self.containerWindow addSubview:self.searchResultView];
    [self.containerWindow bringSubviewToFront:self.searchBar];
    
    newContainerFrame.origin.y = CGRectGetMaxY(newSearchBarFrame);
    
    if (self.shouldOffsetStatusBar) {
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        newSearchBarFrame.size.height += statusBarHeight;
    }
    
    newContainerFrame.size.height -= newSearchBarFrame.size.height;
    self.searchResultView.tableView.hidden = ![self.searchBar.textField.text length];
    self.searchResultView.frame = newContainerFrame;
    [self.searchResultView setNeedsLayout];
    [self.searchResultView layoutIfNeeded];
    
    [self.searchBar setCloseButtonHidden:NO];
    [self.searchBar.superview bringSubviewToFront:self.searchBar];
    
    newSearchBarFrame.origin.y = 0;
    newContainerFrame.origin.y = CGRectGetMaxY(newSearchBarFrame);
    
    self.bottonSeparatorState = self.searchBar.bottomSeparator.hidden;
    self.searchBar.bottomSeparator.hidden = NO;
    
    self.searchResultView.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.searchResultView.alpha = 1;
    }];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:(UIViewAnimationOptionBeginFromCurrentState
                                 |UIViewAnimationCurveEaseIn)
                     animations:^{
                         self.searchBar.textField.textAlignment = NSTextAlignmentLeft;
                         [self.searchBar layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                     }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBar.frame = newSearchBarFrame;
        self.searchBar.textField.textAlignment = NSTextAlignmentLeft;
        self.searchResultView.frame = newContainerFrame;
        [self.searchResultView layoutIfNeeded];
    }];
}

- (void)nhSearchTextField:(NHSearchTextField *)textField didChangeText:(NSString *)text {
    [self changeText:text];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"dealloc search");
#endif
    
    [self.searchBar removeFromSuperview];
    [self.searchResultView removeFromSuperview];
    self.containerWindow = nil;
}

@end
