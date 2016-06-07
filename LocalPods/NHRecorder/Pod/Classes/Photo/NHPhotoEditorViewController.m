//
//  NHCameraImageEditorController.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHPhotoEditorViewController.h"
#import "UIImage+Resize.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHPhotoEditorViewController class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHPhotoEditorViewController class]], nil)

const CGFloat kNHRecorderSelectorViewHeight = 40;
const CGFloat kNHRecorderSelectionContainerViewHeight = 85;

@interface NHPhotoEditorViewController ()<NHFilterCollectionViewDelegate, NHCropCollectionViewDelegate>

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NHPhotoView *photoView;

@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UIView *selectorSeparatorView;
@property (nonatomic, strong) UIView *selectionContainerView;
@property (nonatomic, strong) UIView *photoSeparatorView;

@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *cropButton;

@property (nonatomic, strong) UIColor *blackDarkColor;

@property (nonatomic, strong) NHCropCollectionView *cropCollectionView;
@property (nonatomic, strong) NHFilterCollectionView *filterCollectionView;

@property (nonatomic, strong) NHRecorderButton *backButton;

@property (nonatomic, strong) id orientationChange;

@end

@implementation NHPhotoEditorViewController

- (instancetype)initWithUIImage:(UIImage*)image {
    self = [super init];
    
    if (self) {
        _image = image;
        [self commonInit];
    }
    
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.photoView sizeContent];
}

- (void)commonInit {
    
    _forcedCropType = NHPhotoCropTypeNone;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.blackDarkColor = [[UIColor alloc] initWithRed:29/255.0 green:25/255.0 blue:31/255.0 alpha:1];
    
    self.backButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(0, 0, 44, 44);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton setImage:image(@"NHRecorder.back") forState:UIControlStateNormal];
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.backButton addTarget:self action:@selector(backButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:localization(@"NHRecorder.button.done", @"NHRecorder")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(nextButtonTouch:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    self.photoView = [[NHPhotoView alloc] initWithImage:self.image];
    self.photoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.photoView];
    
    self.selectorView = [[UIView alloc] init];
    self.selectorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectorView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.selectorView];
    
    self.selectionContainerView = [[UIView alloc] init];
    self.selectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionContainerView.backgroundColor = self.blackDarkColor;
    
    [self.view addSubview:self.selectionContainerView];
    
    [self setupSelectorViewConstraints];
    [self setupSelectionContainerViewConstraints];
    [self setupPhotoViewConstraints];
    
    self.filterButton = [[UIButton alloc] init];
    self.filterButton.backgroundColor = [UIColor clearColor];
    self.filterButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.filterButton setTitle:nil forState:UIControlStateNormal];
    [self.filterButton setImage:[image(@"NHRecorder.filter.button")
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateNormal];
    [self.filterButton setImage:[image(@"NHRecorder.filter.button-active")
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateSelected];
    [self.filterButton addTarget:self action:@selector(filterButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cropButton = [[UIButton alloc] init];
    self.cropButton.backgroundColor = [UIColor clearColor];
    self.cropButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cropButton setTitle:nil forState:UIControlStateNormal];
    [self.cropButton setImage:[image(@"NHRecorder.crop.button")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateNormal];
    [self.cropButton setImage:[image(@"NHRecorder.crop.button-active")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateSelected];
    [self.cropButton addTarget:self action:@selector(cropButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupSelectorButtons];
    
    self.filterCollectionView = [[NHFilterCollectionView alloc] initWithImage:self.image];
    self.filterCollectionView.backgroundColor = [UIColor clearColor];
    self.filterCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.filterCollectionView];
    [self setupFilterCollectionViewConstraints];

    
    self.cropCollectionView = [[NHCropCollectionView alloc] init];
    self.cropCollectionView.backgroundColor = [UIColor clearColor];
    self.cropCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cropCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.cropCollectionView];
    [self setupCropCollectionViewConstraints];
    
    [self.filterCollectionView setSelected:0];
    [self.cropCollectionView setSelected:0];
    
    [self showFiltersCollection];
    
    __weak __typeof(self) weakSelf = self;
    self.orientationChange = [[NSNotificationCenter defaultCenter]
                              addObserverForName:UIDeviceOrientationDidChangeNotification
                              object:nil
                              queue:nil
                              usingBlock:^(NSNotification *note) {
                                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                                  if (strongSelf
                                      && strongSelf.view.window) {
                                      [strongSelf deviceOrientationChange];
                                  }
                              }];
    
    [self.photoView.panGestureRecognizer addTarget:self action:@selector(photoGestureAction:)];
    [self.photoView.pinchGestureRecognizer addTarget:self action:@selector(photoGestureAction:)];
}


//MARK: setup

- (void)photoGestureAction:(UIGestureRecognizer*)recognizer {
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNextEnabled) object:nil];
            break;
        default: {
            [self performSelector:@selector(checkNextEnabled) withObject:nil afterDelay:0.5];
        } break;
    }
}
                           
- (void)checkNextEnabled {
        self.navigationItem.rightBarButtonItem.enabled =
        ((self.photoView.panGestureRecognizer.state == UIGestureRecognizerStateFailed
              || self.photoView.panGestureRecognizer.state == UIGestureRecognizerStatePossible)
         && (self.photoView.pinchGestureRecognizer.state == UIGestureRecognizerStateFailed
                 || self.photoView.pinchGestureRecognizer.state == UIGestureRecognizerStatePossible));
}

- (void)deviceOrientationChange {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    CGFloat angle = 0;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        default:
            return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.filterButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.cropButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                     }
     completion:^(BOOL finished) {
         
     }];
}

- (void)setupSelectorViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0 constant:kNHRecorderSelectorViewHeight]];
    
    self.selectorSeparatorView = [[UIView alloc] init];
    self.selectorSeparatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.selectorSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectorView addSubview:self.selectorSeparatorView];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.selectorSeparatorView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:0.5]];
}

- (void)setupSelectionContainerViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.selectorView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:0 constant:kNHRecorderSelectionContainerViewHeight]];
    
    self.photoSeparatorView = [[UIView alloc] init];
    self.photoSeparatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.photoSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectionContainerView addSubview:self.photoSeparatorView];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoSeparatorView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoSeparatorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoSeparatorView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:0]];
    
    [self.photoSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoSeparatorView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.photoSeparatorView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:0 constant:0.5]];
}

- (void)setupPhotoViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupSelectorButtons {
    [self.filterButton removeFromSuperview];
    [self.cropButton removeFromSuperview];
    
    [self.selectorView addSubview:self.filterButton];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0 constant:0]];
    if (self.forcedCropType == NHPhotoCropTypeNone) {
        [self.selectorView addSubview:self.cropButton];
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0 constant:0]];
        
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.filterButton
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.filterButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0 constant:0]];
    }
    else {
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
    }
}

- (void)setupFilterCollectionViewConstraints {
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0 constant:12]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0 constant:-5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0 constant:15]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0 constant:-15]];
}

- (void)setupCropCollectionViewConstraints {
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:12]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0 constant:-5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:15]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:-15]];
}

- (void)showFiltersCollection {
    self.filterButton.selected = YES;
    self.cropButton.selected = NO;
    
    self.filterCollectionView.hidden = NO;
    self.cropCollectionView.hidden = YES;
}

- (void)showCropCollection {
    self.filterButton.selected = NO;
    self.cropButton.selected = YES;
    
    self.filterCollectionView.hidden = YES;
    self.cropCollectionView.hidden = NO;
}

//MARK: Setters

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barTintColor = barTintColor;
    self.navigationController.navigationBar.barTintColor = barTintColor ?: self.blackDarkColor;
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setBarButtonTintColor:(UIColor *)barButtonTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barButtonTintColor = barButtonTintColor;
    self.navigationController.navigationBar.tintColor = barButtonTintColor ?: [UIColor whiteColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setForcedCropType:(NHPhotoCropType)forcedCropType {
    [self willChangeValueForKey:@"forcedCropType"];
    _forcedCropType = forcedCropType;
    [self didChangeValueForKey:@"forcedCropType"];
    [self.photoView setCropType:forcedCropType];
    [self setupSelectorButtons];
}

//MARK: buttons

- (void)backButtonTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonTouch:(id)sender {
    if (self.photoView.panGestureRecognizer.state == UIGestureRecognizerStatePossible
        && self.photoView.pinchGestureRecognizer.state == UIGestureRecognizerStatePossible) {
        
        self.navigationController.view.userInteractionEnabled = NO;
        __weak __typeof(self) weakSelf = self;
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(photoEditorDidStartExporting:)]) {
            [weakSelf.nhDelegate photoEditorDidStartExporting:weakSelf];
        }
        
        [self.photoView processImageWithBlock:^(UIImage *image) {
            
            weakSelf.navigationController.view.userInteractionEnabled = YES;
            
            if (image) {
                UIImage *resultImage;
                
                CGSize imageSizeToFit = CGSizeZero;
                
                if ([weakSelf.nhDelegate respondsToSelector:@selector(imageSizeToFitForPhotoEditor:)]) {
                    imageSizeToFit = [weakSelf.nhDelegate imageSizeToFitForPhotoEditor:weakSelf];
                }
                
                if (CGSizeEqualToSize(imageSizeToFit, CGSizeZero)) {
                    resultImage = image;
                }
                else {
                    resultImage = [image nhr_rescaleToFit:imageSizeToFit];
                }
                
                if ([weakSelf.nhDelegate respondsToSelector:@selector(photoEditorDidFinishExporting:)]) {
                    [weakSelf.nhDelegate photoEditorDidFinishExporting:weakSelf];
                }
                
                if (resultImage) {
                    BOOL shouldSave = YES;
                    
                    __weak __typeof(self) weakSelf = self;
                    if ([weakSelf.nhDelegate respondsToSelector:@selector(photoEditor:shouldSaveImage:)]) {
                        shouldSave = [weakSelf.nhDelegate photoEditor:weakSelf shouldSaveImage:resultImage];
                    }
                    
                    if (shouldSave) {
                        UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(savedCapturedImage:error:context:), nil);
                    }
                }
            }
        }];
    }
}

- (void)savedCapturedImage:(UIImage*)image error:(NSError*)error context:(void*)context {
    BOOL shouldContinue = YES;
    __weak __typeof(self) weakSelf = self;
    if (error) {
        if ([weakSelf.nhDelegate respondsToSelector:@selector(photoEditor:receivedErrorOnSave:)]) {
            [weakSelf.nhDelegate photoEditor:weakSelf receivedErrorOnSave:error];
        }
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(photoEditorShouldContinueAfterSaveFail:)]) {
            shouldContinue = [weakSelf.nhDelegate photoEditorShouldContinueAfterSaveFail:weakSelf];
        }
    }
    
    if (shouldContinue
        && [weakSelf.nhDelegate respondsToSelector:@selector(photoEditor:savedImage:)]) {
        [weakSelf.nhDelegate photoEditor:weakSelf savedImage:image];
    }
}

- (void)filterButtonTouch:(id)sender {
    if (!self.filterButton.selected) {
        [self showFiltersCollection];
    }
}

- (void)cropButtonTouch:(id)sender {
    if (!self.cropButton.selected) {
        [self showCropCollection];
    }
}

//MARK: delegates

- (void)cropView:(NHCropCollectionView *)cropView didSelectType:(NHPhotoCropType)type {
    if (self.forcedCropType == NHPhotoCropTypeNone) {
        [self.photoView setCropType:type];
    }
}

- (void)filterView:(NHFilterCollectionView *)filteView didSelectFilter:(GPUImageFilter *)filter {
    [self.photoView setFilter:filter];
}

//MARK: view overrides

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.barTintColor ?: self.blackDarkColor;
    self.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
