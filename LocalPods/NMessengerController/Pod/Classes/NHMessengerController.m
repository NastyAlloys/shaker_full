//
//  NMessengerController.m
//  Pods
//
//  Created by Naithar on 23.04.15.
//
//

#import "NHMessengerController.h"

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHMessengerController class]], nil)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface NHMessengerController ()<UIGestureRecognizerDelegate>{
    Class responderType;
}

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIView *superview;

@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) id textInputResponder;
@property (strong, nonatomic) NSLayoutConstraint *leftTextViewInset;
@property (strong, nonatomic) NSLayoutConstraint *rightTextViewInset;
@property (strong, nonatomic) NSLayoutConstraint *topTextViewInset;
@property (strong, nonatomic) NSLayoutConstraint *bottomTextViewInset;

@property (strong, nonatomic) NHContainerView *leftView;
@property (strong, nonatomic) NSLayoutConstraint *leftLeftViewInset;
@property (strong, nonatomic) NSLayoutConstraint *topLeftViewInset;
@property (strong, nonatomic) NSLayoutConstraint *bottomLeftViewInset;

@property (strong, nonatomic) NHContainerView *rightView;
@property (strong, nonatomic) NSLayoutConstraint *rightRightViewInset;
@property (strong, nonatomic) NSLayoutConstraint *topRightViewInset;
@property (strong, nonatomic) NSLayoutConstraint *bottomRightViewInset;

@property (nonatomic, strong) UIButton *sendButton;

@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) NSLayoutConstraint *rightSeparatorInset;
@property (strong, nonatomic) NSLayoutConstraint *leftSeparatorInset;
@property (strong, nonatomic) NSLayoutConstraint *bottomSeparatorInset;

@property (strong, nonatomic) NHContainerView *topView;
@property (strong, nonatomic) NSLayoutConstraint *rightTopViewInset;
@property (strong, nonatomic) NSLayoutConstraint *leftTopViewInset;

@property (strong, nonatomic) NHContainerView *bottomView;
@property (strong, nonatomic) NSLayoutConstraint *rightBottomViewInset;
@property (strong, nonatomic) NSLayoutConstraint *leftBottomViewInset;

@property (strong, nonatomic) id changeKeyboardObserver;
@property (strong, nonatomic) id showKeyboardObserver;
@property (strong, nonatomic) id hideKeyboardObserver;

@property (strong, nonatomic) id foundResponderForTextView;
@property (strong, nonatomic) id foundResponderForTextField;

@property (strong, nonatomic) id textFieldTextObserver;
@property (strong, nonatomic) id textViewTextObserver;

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

@property (weak, nonatomic) UIView *keyboardView;

@property (nonatomic, assign) BOOL isInteractive;

@property (nonatomic, assign) UIEdgeInsets keyboardInsets;
@property (nonatomic, assign) UIEdgeInsets messengerInsets;
@end

@implementation NHMessengerController

- (instancetype)initWithScrollView:(UIScrollView*)scrollView {
    return [self initWithScrollView:scrollView
                       andSuperview:scrollView];
}

- (instancetype)initWithScrollView:(UIScrollView*)scrollView
                      andSuperview:(UIView*)superview {
    return [self initWithScrollView:scrollView andSuperview:superview andTextInputClass:[UITextView class]];
}

- (instancetype)initWithScrollView:(UIScrollView*)scrollView
                      andSuperview:(UIView*)superview
                 andTextInputClass:(Class)textInputClass {
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _superview = superview;
        responderType = textInputClass;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {

    _textViewInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    _containerInsets = UIEdgeInsetsMake(2.5, 5, 2.5, 5);
    _separatorInsets = UIEdgeInsetsMake(0, 0, 1, 0);
    _sendButtonSize = CGSizeMake(35, 35);
    _initialScrollViewInsets = self.scrollView.contentInset;
    _additionalInsets = UIEdgeInsetsZero;

    [[UIApplication sharedApplication].keyWindow endEditing:YES];

    self.container = [[UIView alloc] initWithFrame:CGRectZero];
    [self.container setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.container.opaque = YES;
    self.container.backgroundColor = [UIColor whiteColor];
    self.container.clipsToBounds = YES;

    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.container
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0];

    [self.superview addSubview:self.container];
    [self.superview bringSubviewToFront:self.container];
    [self.superview addConstraint:self.bottomConstraint];

    [self.container addConstraint:[NSLayoutConstraint constraintWithItem:self.container
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationLessThanOrEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:0
                                                                constant:self.superview.bounds.size.height - 325]];

    [self.container addConstraint:[NSLayoutConstraint constraintWithItem:self.container
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:0
                                                                constant:30]];

    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.container
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0
                                                                constant:0]];

    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.container
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0
                                                                constant:0]];

    self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorView.opaque = YES;
    self.separatorView.backgroundColor = [UIColor colorWithRed:0.6 green:0.65 blue:0.65 alpha:1];
    [self.separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.container addSubview:self.separatorView];

    [self.container addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:0]];

    self.leftSeparatorInset = [NSLayoutConstraint constraintWithItem:self.separatorView
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.container
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1.0
                                                            constant:self.separatorInsets.left];

    [self.container addConstraint:self.leftSeparatorInset];

    self.rightSeparatorInset = [NSLayoutConstraint constraintWithItem:self.separatorView
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.container
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-self.separatorInsets.right];

    [self.container addConstraint:self.rightSeparatorInset];

    [self.separatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.separatorView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0
                                                                    constant:0.5]];

    self.topView = [[NHContainerView alloc] initWithFrame:CGRectZero];
    self.topView.opaque = YES;
    [self.topView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.container addSubview:self.topView];

    self.bottomSeparatorInset = [NSLayoutConstraint constraintWithItem:self.topView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.separatorView
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:self.separatorInsets.bottom];

    [self.container addConstraint:self.bottomSeparatorInset];

    self.leftTopViewInset = [NSLayoutConstraint constraintWithItem:self.topView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.container
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:self.containerInsets.left];

    [self.container addConstraint:self.leftTopViewInset];

    self.rightTopViewInset = [NSLayoutConstraint constraintWithItem:self.topView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.container
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-self.containerInsets.right];

    [self.container addConstraint:self.rightTopViewInset];


    self.bottomView = [[NHContainerView alloc] initWithFrame:CGRectZero];
    self.bottomView.opaque = YES;
    [self.bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.container addSubview:self.bottomView];

    self.leftBottomViewInset = [NSLayoutConstraint constraintWithItem:self.bottomView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.container
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:self.containerInsets.left];

    [self.container addConstraint:self.leftBottomViewInset];

    self.rightBottomViewInset = [NSLayoutConstraint constraintWithItem:self.bottomView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.container
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0
                                                              constant:-self.containerInsets.right];

    [self.container addConstraint:self.rightBottomViewInset];

    [self.container addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:0]];

    self.textInputResponder = [[responderType alloc] initWithFrame:CGRectZero];
    ((UIView*)self.textInputResponder).backgroundColor = [UIColor groupTableViewBackgroundColor];
    ((UIView*)self.textInputResponder).layer.cornerRadius = 10;
    ((UIView*)self.textInputResponder).clipsToBounds = YES;
    [((UIView*)self.textInputResponder) setTranslatesAutoresizingMaskIntoConstraints:NO];
    if ([self.textInputResponder respondsToSelector:@selector(setInputAccessoryView:)]) {
        [self.textInputResponder performSelector:@selector(setInputAccessoryView:) withObject:[UIView new]];
    }
    if ([self.textInputResponder respondsToSelector:@selector(setScrollsToTop:)]) {
        [self.textInputResponder setScrollsToTop:NO];
    }
    [self.container addSubview:self.textInputResponder];

    self.leftView = [[NHContainerView alloc] initWithFrame:CGRectZero];
    self.leftView.opaque = YES;
    self.leftView.backgroundColor = [UIColor whiteColor];
    [self.leftView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.leftView.clipsToBounds = YES;
    [self.container addSubview:self.leftView];

    self.rightView = [[NHContainerView alloc] initWithFrame:CGRectZero];
    self.rightView.opaque = YES;
    [self.rightView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.rightView.backgroundColor = [UIColor whiteColor];
    self.rightView.hidden = YES;
    self.rightView.contentSize = CGSizeMake(0, self.sendButtonSize.height);
    [self.container addSubview:self.rightView];

    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.sendButtonInsets.left,
                                                                 self.sendButtonInsets.top,
                                                                 self.sendButtonSize.width,
                                                                 self.sendButtonSize.height)];
    self.sendButton.opaque = YES;
    [self.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.backgroundColor = [UIColor whiteColor];
    [self.sendButton setTitle:@"" forState:UIControlStateNormal];
    UIImage *originalImage = [UIImage imageNamed:@"ic_msg_send"];
    UIImage *newImage = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)]; // your image size
    
//    imageView.tintColor = [UIColor colorWithRed:1 green:146 blue:230 alpha:1];  // or whatever color that has been selected
    imageView.image = newImage;
    [self.sendButton setImage: imageView.image  forState:UIControlStateNormal];
    
    [self.sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sendButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.rightView addSubview:self.sendButton];

    self.leftLeftViewInset = [NSLayoutConstraint constraintWithItem:self.leftView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.container
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:self.containerInsets.left];
    [self.container addConstraint:self.leftLeftViewInset];

    self.bottomLeftViewInset = [NSLayoutConstraint constraintWithItem:self.leftView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.bottomView
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:-self.containerInsets.bottom];

    [self.container addConstraint:self.bottomLeftViewInset];

    self.topLeftViewInset = [NSLayoutConstraint constraintWithItem:self.leftView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self.topView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:self.containerInsets.top];

    [self.container addConstraint:self.topLeftViewInset];



    self.topTextViewInset = [NSLayoutConstraint constraintWithItem:self.textInputResponder
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self.topView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:self.textViewInsets.top];
    [self.container addConstraint:self.topTextViewInset];

    self.bottomTextViewInset = [NSLayoutConstraint constraintWithItem:self.textInputResponder
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.bottomView
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:-self.textViewInsets.bottom];
    [self.container addConstraint:self.bottomTextViewInset];

    self.leftTextViewInset = [NSLayoutConstraint constraintWithItem:self.textInputResponder
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.leftView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:self.textViewInsets.left];
    [self.container addConstraint:self.leftTextViewInset];

    self.rightTextViewInset = [NSLayoutConstraint constraintWithItem:self.textInputResponder
                                                           attribute:NSLayoutAttributeRight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.rightView
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1.0
                                                            constant:-self.textViewInsets.right];
    [self.container addConstraint:self.rightTextViewInset];

    self.rightRightViewInset = [NSLayoutConstraint constraintWithItem:self.rightView
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.container
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-self.containerInsets.right];
    [self.container addConstraint:self.rightRightViewInset];

    self.bottomRightViewInset = [NSLayoutConstraint constraintWithItem:self.rightView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.bottomView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:-self.containerInsets.bottom];

    [self.container addConstraint:self.bottomRightViewInset];

    self.topRightViewInset = [NSLayoutConstraint constraintWithItem:self.rightView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:self.topView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:self.containerInsets.top];

    [self.container addConstraint:self.topRightViewInset];


    __weak __typeof(self) weakSelf = self;
    self.changeKeyboardObserver = [[NSNotificationCenter defaultCenter]
                                   addObserverForName:UIKeyboardWillChangeFrameNotification
                                   object:nil
                                   queue:nil
                                   usingBlock:^(NSNotification *note) {
                                       __strong __typeof(weakSelf) strongSelf = weakSelf;

                                       [strongSelf processKeyboardNotification:note.userInfo];
                                   }];

    self.showKeyboardObserver = [[NSNotificationCenter defaultCenter]
                                 addObserverForName:UIKeyboardWillShowNotification
                                 object:nil
                                 queue:nil
                                 usingBlock:^(NSNotification *note) {
                                     __strong __typeof(weakSelf) strongSelf = weakSelf;

                                     [strongSelf processKeyboardNotification:note.userInfo];

                                     strongSelf.keyboardView.hidden = NO;
                                     strongSelf.panGesture.enabled = YES;

                                     if ([weakSelf.delegate respondsToSelector:@selector(willShowKeyboardForMessenger:)]) {
                                         [weakSelf.delegate willShowKeyboardForMessenger:weakSelf];
                                     }
                                 }];

    self.hideKeyboardObserver = [[NSNotificationCenter defaultCenter]
                                 addObserverForName:UIKeyboardWillHideNotification
                                 object:nil
                                 queue:nil
                                 usingBlock:^(NSNotification *note) {
                                     __strong __typeof(weakSelf) strongSelf = weakSelf;

                                     [strongSelf processKeyboardNotification:note.userInfo];

                                     //                                       strongSelf.keyboardView.hidden = NO;
                                     strongSelf.panGesture.enabled = NO;

                                     if ([weakSelf.delegate respondsToSelector:@selector(willHideKeyboardForMessenger:)]) {
                                         [weakSelf.delegate willHideKeyboardForMessenger:weakSelf];
                                     }
                                 }];

    self.foundResponderForTextView = [[NSNotificationCenter defaultCenter]
                                      addObserverForName:UITextViewTextDidBeginEditingNotification
                                      object:nil
                                      queue:nil
                                      usingBlock:^(NSNotification *note) {
                                          __strong __typeof(weakSelf) strongSelf = weakSelf;
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [strongSelf getKeyboardViewFromFirstResponder:note.object];
                                          });

                                      }];

    self.foundResponderForTextField = [[NSNotificationCenter defaultCenter]
                                       addObserverForName:UITextFieldTextDidBeginEditingNotification
                                       object:nil
                                       queue:nil
                                       usingBlock:^(NSNotification *note) {
                                           __strong __typeof(weakSelf) strongSelf = weakSelf;
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [strongSelf getKeyboardViewFromFirstResponder:note.object];
                                           });
                                       }];

    self.textFieldTextObserver = [[NSNotificationCenter defaultCenter]
                                  addObserverForName:UITextFieldTextDidChangeNotification
                                  object:self.textInputResponder
                                  queue:nil
                                  usingBlock:^(NSNotification *note) {
                                      __strong __typeof(weakSelf) strongSelf = weakSelf;
                                      [strongSelf processText];
                                  }];

    self.textViewTextObserver = [[NSNotificationCenter defaultCenter]
                                 addObserverForName:UITextViewTextDidChangeNotification
                                 object:self.textInputResponder
                                 queue:nil
                                 usingBlock:^(NSNotification *note) {
                                     __strong __typeof(weakSelf) strongSelf = weakSelf;
                                     [strongSelf processText];
                                 }];

    if ([self.textInputResponder respondsToSelector:@selector(text)]) {
        [self.textInputResponder addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }

    [self.container addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(panGestureAction:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.delegate = self;
    [self.scrollView addGestureRecognizer:self.panGesture];

    if (self.scrollView.keyboardDismissMode != UIScrollViewKeyboardDismissModeOnDrag) {
        self.isInteractive = YES;
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    }
    else {
        self.isInteractive = NO;
    }

    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];

    _messengerInsets = UIEdgeInsetsMake(0, 0, self.container.bounds.size.height, 0);

}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"text"]
        && object == self.textInputResponder) {

        NSString *oldText = change[NSKeyValueChangeOldKey];
        NSString *newText = change[NSKeyValueChangeNewKey];

        if ([oldText isEqualToString:newText]) {
            return;
        }

        [self processText];
    }

    if ([keyPath isEqualToString:@"bounds"]
        && object == self.container) {

        CGRect oldRect = [change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newRect = [change[NSKeyValueChangeNewKey] CGRectValue];

        if (CGRectEqualToRect(oldRect, newRect)) {
            return;
        }

        self.messengerInsets = UIEdgeInsetsMake(0, 0, newRect.size.height, 0);

        [self updateInsets];
    }
}

- (BOOL)shouldShowSendButton {
    NSString *currentText = [[self.textInputResponder text]
                             stringByTrimmingCharactersInSet:[NSCharacterSet
                                                              whitespaceAndNewlineCharacterSet]];

    return currentText && [currentText length] > 0;
}

- (void)updateSendButtonState {
    BOOL sendButtonShow = [self shouldShowSendButton];
    CGFloat newSize = (sendButtonShow
                       ? self.sendButtonSize.width + self.sendButtonInsets.left + self.sendButtonInsets.right
                       : self.sendButtonInsets.left);

    if (newSize == self.rightView.contentSize.width) {
        self.rightView.hidden = newSize == 0;
        self.sendButton.hidden = !sendButtonShow;
        return;
    }

    if (newSize != 0) {
        self.rightView.hidden = NO;
    }

    if (sendButtonShow) {
        self.sendButton.hidden = NO;
    }

    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.delegate respondsToSelector:@selector(messenger:didChangeButtonHiddenTo:)]) {
        [weakSelf.delegate messenger:weakSelf didChangeButtonHiddenTo:newSize == 0];
    }

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.rightView.contentSize = CGSizeMake(newSize,
                                                self.sendButtonSize.height
                                                + self.sendButtonInsets.top
                                                + self.sendButtonInsets.bottom);
        [self.rightView invalidateIntrinsicContentSize];
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished){
        self.rightView.hidden = newSize == 0;
        self.sendButton.hidden = ![self shouldShowSendButton];
    }];
}

- (void)processText {
    if ([self.textInputResponder respondsToSelector:@selector(text)]) {
        NSString *currentText = [[self.textInputResponder text]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet
                                                                  whitespaceAndNewlineCharacterSet]];

        __weak __typeof(self) weakSelf = self;
        if ([weakSelf.delegate respondsToSelector:@selector(messenger:didChangeText:)]) {
            [weakSelf.delegate messenger:weakSelf didChangeText:currentText];
        }

        [self updateSendButtonState];
    }
}

- (void)processKeyboardNotification:(NSDictionary *)data {

    NSValue *keyboardRect = data[UIKeyboardFrameEndUserInfoKey];
    NSNumber *keyboardAnimationDuration = data[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *keyboardAnimationCurve = data[UIKeyboardAnimationCurveUserInfoKey];

    if (keyboardRect) {

        CGRect rect = [self.superview convertRect:[keyboardRect CGRectValue] fromView:nil];

        CGFloat offset = MAX(0, self.superview.frame.size.height - rect.origin.y);

        [UIView animateWithDuration:[keyboardAnimationDuration floatValue]
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
         | ([keyboardAnimationCurve integerValue] << 16)
                         animations:^{
                             self.bottomConstraint.constant = -offset;
                             self.keyboardInsets = UIEdgeInsetsMake(0, 0, offset, 0);
                             [self updateInsets];
                             [self.superview layoutIfNeeded];
                         } completion:nil];

    }
}

- (void)getKeyboardViewFromFirstResponder:(UIResponder*)responder {
    [self __getKeyboardViewFromFirstResponder:responder];

    __weak __typeof(self) weakSelf = self;
    if (responder == self.textInputResponder
        && [weakSelf.delegate respondsToSelector:@selector(didStartEditingInMessenger:)]) {
        [weakSelf.delegate didStartEditingInMessenger:weakSelf];
    }
}

- (void)__getKeyboardViewFromFirstResponder:(UIResponder*)responder {
    if (!responder.inputAccessoryView) {
        if ([responder respondsToSelector:@selector(setInputAccessoryView:)]) {
            [responder performSelector:@selector(setInputAccessoryView:) withObject:[UIView new]];
        }
    }
    
    if (responder.inputAccessoryView
        && !self.keyboardView
        && !SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.keyboardView.hidden = NO;
        self.keyboardView = [responder.inputAccessoryView superview];
        self.keyboardView.hidden = NO;
        
        if (!self.keyboardView
            && responder != self.textInputResponder
            && [responder isKindOfClass:[UITextField class]]) {
            [responder resignFirstResponder];
            [responder becomeFirstResponder];
            return;
        }
    }
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")
             && !self.keyboardView) {
        for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
            if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
                self.keyboardView = [[window.subviews firstObject].subviews firstObject];
            }
        }
    }
}


- (void)panGestureAction:(UIPanGestureRecognizer*)recognizer {
    if (!self.isInteractive) {
        return;
    }

    if (!self.keyboardView) {
        if ([self.textInputResponder respondsToSelector:@selector(inputAccessoryView)]) {
            [self __getKeyboardViewFromFirstResponder:self.textInputResponder];
        }
        return;
    }


    CGFloat maxWindowHeight = CGRectGetMaxY(self.superview.window.frame);
    CGFloat pointOffset = CGRectGetMaxY(self.superview.frame) - CGRectGetHeight(self.superview.frame);
    CGFloat viewOffsetY = CGRectGetMaxY(self.superview.window.frame) - CGRectGetMaxY(self.superview.frame);

    CGPoint pointInView = [recognizer locationInView:self.superview];
    CGPoint velocityInView = [recognizer velocityInView:self.superview];
    [recognizer setTranslation:CGPointZero inView:self.superview];

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            
            [UIView performWithoutAnimation:^{
            
            
            CGRect keyboardFrame = self.keyboardView.frame;
            CGFloat keyboardHeight = keyboardFrame.size.height;

            keyboardFrame.origin.y = pointInView.y + self.container.bounds.size.height + pointOffset;

            keyboardFrame.origin.y = MIN(keyboardFrame.origin.y, maxWindowHeight);
            keyboardFrame.origin.y = MAX(keyboardFrame.origin.y, maxWindowHeight - keyboardHeight);

            if (CGRectGetMinY(keyboardFrame) == CGRectGetMinY(self.keyboardView.frame)) {
                return;
            }
            
//            [UIView animateWithDuration:0.0
//                                  delay:0.0
//                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone
//                             animations:^{
                                 CGFloat offset = MAX(0, maxWindowHeight
                                                      - keyboardFrame.origin.y
                                                      - viewOffsetY);
                                 self.keyboardView.frame = keyboardFrame;
                                 self.bottomConstraint.constant = -offset;
                                 self.keyboardInsets = UIEdgeInsetsMake(0, 0, offset, 0);
                                 [self updateInsets];
                [self.superview setNeedsLayout];
                                 [self.superview layoutIfNeeded];
//                             }
//                             completion:nil];

            if (self.bottomConstraint.constant == 0) {
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
            }];
        } break;
        default: {
            if (CGRectGetMaxY(self.keyboardView.frame) == maxWindowHeight
                || self.keyboardView.hidden) {
                return;
            }

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 CGRect keyboardFrame = self.keyboardView.frame;
                                 CGFloat keyboardHeight = keyboardFrame.size.height;

                                 keyboardFrame.origin.y = maxWindowHeight - ((velocityInView.y < 0) ? keyboardHeight : 0);

                                 CGFloat offset = MAX(0, maxWindowHeight
                                                      - keyboardFrame.origin.y
                                                      - viewOffsetY);


                                 self.keyboardView.frame = keyboardFrame;
                                 self.bottomConstraint.constant = -offset;
                                 self.keyboardInsets = UIEdgeInsetsMake(0, 0, offset, 0);
                                 [self updateInsets];
                                 [self.superview layoutIfNeeded];
                             }
                             completion:^(BOOL _){
                                 [self updateInsets];
                                 if (velocityInView.y >= 0) {
                                     self.keyboardView.hidden = YES;
                                     [[UIApplication sharedApplication].keyWindow endEditing:YES];

                                 }
                             }];
            //            }
        } break;
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setTextViewInsets:(UIEdgeInsets)textViewInsets {
    [self willChangeValueForKey:@"textViewInsets"];
    _textViewInsets = textViewInsets;

    self.leftTextViewInset.constant = _textViewInsets.left;
    self.rightTextViewInset.constant = - _textViewInsets.right;
    self.topTextViewInset.constant = _textViewInsets.top;
    self.bottomTextViewInset.constant = - _textViewInsets.bottom;

    [self.superview layoutIfNeeded];

    [self didChangeValueForKey:@"textViewInsets"];
}

- (void)setSendButtonInsets:(UIEdgeInsets)sendButtonInsets {
    [self willChangeValueForKey:@"sendButtonInsets"];
    _sendButtonInsets = sendButtonInsets;

    self.sendButton.frame = CGRectMake(sendButtonInsets.left,
                                       sendButtonInsets.top,
                                       self.sendButtonSize.width,
                                       self.sendButtonSize.height);

    [self updateSendButtonState];

    [self didChangeValueForKey:@"sendButtonInsets"];
}

- (void)updateMessengerView {
    [self.topView calculateContentSize];
    [self.topView invalidateIntrinsicContentSize];

    [self.bottomView calculateContentSize];
    [self.bottomView invalidateIntrinsicContentSize];

    [self.leftView calculateContentSize];
    [self.leftView invalidateIntrinsicContentSize];

    [self.rightView invalidateIntrinsicContentSize];

    if ([self.textInputResponder respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
        [self.textInputResponder invalidateIntrinsicContentSize];
    }

    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];

    self.messengerInsets = UIEdgeInsetsMake(0, 0, self.container.bounds.size.height, 0);
    [self updateInsets];
}


- (void)setContainerInsets:(UIEdgeInsets)containerInsets {
    [self willChangeValueForKey:@"containerInsets"];
    _containerInsets = containerInsets;

    self.leftLeftViewInset.constant = _containerInsets.left;
    self.topLeftViewInset.constant = _containerInsets.top;
    self.bottomLeftViewInset.constant = - _containerInsets.bottom;

    self.rightRightViewInset.constant = - _containerInsets.right;
    self.topRightViewInset.constant = _containerInsets.top;
    self.bottomRightViewInset.constant = - _containerInsets.bottom;

    self.leftTopViewInset.constant = _containerInsets.left;
    self.rightTopViewInset.constant = - _containerInsets.right;

    self.leftBottomViewInset.constant = _containerInsets.left;
    self.rightBottomViewInset.constant = - _containerInsets.right;

    [self.superview layoutIfNeeded];

    [self didChangeValueForKey:@"containerInsets"];
}

- (void)setSeparatorInsets:(UIEdgeInsets)separatorInsets {
    [self willChangeValueForKey:@"separatorInsets"];
    _separatorInsets = separatorInsets;
    self.leftSeparatorInset.constant = _separatorInsets.left;
    self.rightSeparatorInset.constant = - _separatorInsets.right;
    self.bottomSeparatorInset.constant = _separatorInsets.bottom;
    [self didChangeValueForKey:@"separatorInsets"];
}

- (void)setSendButtonSize:(CGSize)sendButtonSize {
    [self willChangeValueForKey:@"sendButtonSize"];



    //    if (CGSizeEqualToSize(self.rightView.contentSize, _sendButtonSize)) {
    //        self.rightView.contentSize = sendButtonSize;
    //        [self.rightView invalidateIntrinsicContentSize];
    //        [self.superview layoutIfNeeded];
    //    }

    _sendButtonSize = sendButtonSize;

    self.sendButton.frame = CGRectMake(self.sendButtonInsets.left,
                                       self.sendButtonInsets.top,
                                       sendButtonSize.width,
                                       sendButtonSize.height);

    [self updateSendButtonState];

    [self didChangeValueForKey:@"sendButtonSize"];
}

- (void)sendButtonAction:(UIButton*)sender {
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.delegate respondsToSelector:@selector(messenger:didSendText:)]) {
        NSString *currentText;

        if ([self.textInputResponder respondsToSelector:@selector(text)]) {
            currentText = [[self.textInputResponder text]
                           stringByTrimmingCharactersInSet:[NSCharacterSet
                                                            whitespaceAndNewlineCharacterSet]];
        }

        [weakSelf.delegate messenger:weakSelf didSendText:currentText];
    }
}

- (void)setMessengerInsets:(UIEdgeInsets)messengerInsets {
    [self willChangeValueForKey:@"messengerInsets"];
    _messengerInsets = messengerInsets;

    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.delegate respondsToSelector:@selector(messenger:willChangeMessengerInset:)]) {
        [weakSelf.delegate messenger:weakSelf willChangeMessengerInset:messengerInsets];
    }

    if ([weakSelf.delegate respondsToSelector:@selector(messenger:willChangeInsets:)]) {
        UIEdgeInsets insets = UIEdgeInsetsMake(messengerInsets.top + self.keyboardInsets.top,
                                               messengerInsets.left + self.keyboardInsets.left,
                                               messengerInsets.bottom + self.keyboardInsets.bottom,
                                               messengerInsets.right + self.keyboardInsets.right);

        [weakSelf.delegate messenger:weakSelf willChangeInsets:insets];
    }

    [self didChangeValueForKey:@"messengerInsets"];
}

- (void)setKeyboardInsets:(UIEdgeInsets)keyboardInsets {
    [self willChangeValueForKey:@"keyboardInsets"];
    _keyboardInsets = keyboardInsets;

    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.delegate respondsToSelector:@selector(messenger:willChangeKeyboardInset:)]) {
        [weakSelf.delegate messenger:weakSelf willChangeKeyboardInset:keyboardInsets];
    }

    if ([weakSelf.delegate respondsToSelector:@selector(messenger:willChangeInsets:)]) {
        UIEdgeInsets insets = UIEdgeInsetsMake(self.messengerInsets.top + keyboardInsets.top,
                                               self.messengerInsets.left + keyboardInsets.left,
                                               self.messengerInsets.bottom + keyboardInsets.bottom,
                                               self.messengerInsets.right + keyboardInsets.right);

        [weakSelf.delegate messenger:weakSelf willChangeInsets:insets];
    }

    [self didChangeValueForKey:@"keyboardInsets"];
}

- (void)updateInsets {
    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top,
                                                    self.scrollView.contentInset.left,
                                                    self.initialScrollViewInsets.bottom
                                                    + self.additionalInsets.bottom
                                                    + self.messengerInsets.bottom
                                                    + self.keyboardInsets.bottom,
                                                    self.scrollView.contentInset.right);

    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.scrollView.scrollIndicatorInsets.top,
                                                             self.scrollView.scrollIndicatorInsets.left,
                                                             self.initialScrollViewInsets.bottom
                                                             + self.messengerInsets.bottom
                                                             + self.keyboardInsets.bottom,
                                                             self.scrollView.scrollIndicatorInsets.right);
}

- (void)scrollToBottom {
    [self scrollToBottomAnimated:NO];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
//    [UIView animateWithDuration:animated ? 0.3 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
                         [self.scrollView scrollRectToVisible:CGRectMake(0, self.scrollView.contentSize.height - 1, 1, 1) animated:animated];
//                     } completion:nil];
}

- (void)dealloc {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if ([self.textInputResponder respondsToSelector:@selector(text)]) {
        [self.textInputResponder removeObserver:self forKeyPath:@"text" context:nil];
    }
    [self.container removeObserver:self forKeyPath:@"bounds" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.changeKeyboardObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.showKeyboardObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.hideKeyboardObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.foundResponderForTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self.foundResponderForTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self.textFieldTextObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.textViewTextObserver];
    self.keyboardView.userInteractionEnabled = YES;
    self.keyboardView.hidden = NO;
    [self.scrollView removeGestureRecognizer:self.panGesture];
    self.panGesture.delegate = nil;
}
@end
