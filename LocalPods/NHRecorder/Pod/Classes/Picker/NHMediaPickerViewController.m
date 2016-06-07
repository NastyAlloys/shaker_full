//
//  NHImagePickerViewController.m
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

#import "NHMediaPickerViewController.h"
#import "NHMediaPickerCollectionViewCell.h"
#import "NHPhotoCaptureViewController.h"
#import "NHPhotoEditorViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Resize.h"
#import "NHVideoEditViewController.h"
#import "NHVideoCaptureViewController.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHMediaPickerViewController class]]\
pathForResource:name ofType:@"png"]]


const CGFloat kNHRecorderCollectionViewSpace = 1;

@interface NHMediaPickerViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *mediaCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *mediaCollectionViewLayout;
@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, strong) ALAssetsLibrary *mediaLibrary;
@property (nonatomic, strong) NHRecorderButton *closeButton;

@property (nonatomic, strong) id orientationChange;
@end

@implementation NHMediaPickerViewController

- (instancetype)initWithMediaType:(NHMediaPickerType)type {
    
    _mediaType = type;
    self = [super init];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}


- (void)commonInit {
    
    self.mediaItems = @[];
    
    self.mediaLibrary = [[ALAssetsLibrary alloc] init];
    
    self.linksToCamera = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self preferredStatusBarStyle];
    
    self.closeButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.frame = CGRectMake(0, 0, 44, 44);
    self.closeButton.tintColor = [UIColor blackColor];
    [self.closeButton setImage:image(@"NHRecorder.close") forState:UIControlStateNormal];
    self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.closeButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    self.mediaCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.mediaCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.mediaCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.mediaCollectionViewLayout];
    self.mediaCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mediaCollectionView.backgroundColor = [UIColor whiteColor];
    self.mediaCollectionView.delegate = self;
    self.mediaCollectionView.dataSource = self;
    [self.mediaCollectionView registerClass:[NHMediaPickerCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.mediaCollectionView.scrollsToTop = YES;
    self.mediaCollectionView.bounces = YES;
    self.mediaCollectionView.alwaysBounceVertical = YES;
    
    [self.view addSubview:self.mediaCollectionView];
    
    [self setupCollectionViewConstraints];
    
    [self loadMediaFromLibrary];
    
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
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//MARK: setup

- (void)deviceOrientationChange {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    CGFloat xScale = 1;
    CGFloat yScale = 1;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            self.mediaCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            self.mediaCollectionView.alwaysBounceVertical = YES;
            self.mediaCollectionView.alwaysBounceHorizontal = NO;
            break;
        case UIDeviceOrientationLandscapeLeft:
            xScale = -1;
            self.mediaCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.mediaCollectionView.alwaysBounceVertical = NO;
            self.mediaCollectionView.alwaysBounceHorizontal = YES;
            break;
        case UIDeviceOrientationLandscapeRight:
            xScale = 1;
            yScale = -1;
            self.mediaCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.mediaCollectionView.alwaysBounceVertical = NO;
            self.mediaCollectionView.alwaysBounceHorizontal = YES;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            yScale = -1;
            xScale = -1;
            self.mediaCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            self.mediaCollectionView.alwaysBounceVertical = YES;
            self.mediaCollectionView.alwaysBounceHorizontal = NO;
            break;
        default:
            return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.mediaCollectionView.transform = CGAffineTransformMakeScale(xScale, yScale);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}


- (void)setupCollectionViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mediaCollectionView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mediaCollectionView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mediaCollectionView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mediaCollectionView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
}

- (void)loadMediaFromLibrary {
    
    __weak __typeof(self) weakSelf = self;
    [self.mediaLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               if (group
                                   && group.numberOfAssets > 0) {
                                   __strong __typeof(weakSelf) strongSelf = weakSelf;
                                   
                                   NSLog(@"group %@", group);
                                   
                                   NSString *newTitle = [group valueForProperty:ALAssetsGroupPropertyName];
                                   NSMutableArray *newArray = [[NSMutableArray alloc] init];
                                   
                                   [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       
                                       if (result) {
                                           NSString *type = [result valueForProperty:ALAssetPropertyType];
                                           
                                           switch (strongSelf.mediaType) {
                                               case NHMediaPickerTypeAll:
                                                   [newArray insertObject:result atIndex:0];
                                                   break;
                                               case NHMediaPickerTypePhoto:
                                                   if ([type isEqualToString:ALAssetTypePhoto]) {
                                                       [newArray insertObject:result atIndex:0];
                                                   }
                                                   break;
                                               case NHMediaPickerTypeVideo:
                                                   if ([type isEqualToString:ALAssetTypeVideo]
                                                       && [[result valueForProperty:ALAssetPropertyDuration] doubleValue] >= kNHVideoMinDuration) {
                                                       [newArray insertObject:result atIndex:0];
                                                   }
                                                   break;
                                               default:
                                                   break;
                                           }
                                       }
                                   }];
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       strongSelf.navigationItem.title = newTitle;
                                       strongSelf.mediaItems = newArray;
                                       [strongSelf.mediaCollectionView reloadData];
                                   });
                                   
                                   *stop = YES;
                               }
                           } failureBlock:^(NSError *error) {
                               NSLog(@"library error = %@", error);
                           }];
}


//MARK: buttons

- (void)closeButtonTouch:(id)sender {
    if (self.firstController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//MARK: collection view

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            CGFloat height = self.view.bounds.size.height;
            CGFloat cellHeight = height / 5 - kNHRecorderCollectionViewSpace;
            return CGSizeMake(cellHeight, cellHeight);
        }
        default:
            break;
    }
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat cellWidth = width / 4 - kNHRecorderCollectionViewSpace;
    return CGSizeMake(cellWidth, cellWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kNHRecorderCollectionViewSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kNHRecorderCollectionViewSpace;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mediaItems.count + (self.linksToCamera ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NHMediaPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSInteger itemNumber = indexPath.row;
    
    if (self.linksToCamera) {
        itemNumber--;
    }
    
    if (itemNumber < 0) {
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.image = [UIImage imageNamed:@"sk.recorder.photo"];
        
        NSLog(@"qweewqe");
    }
    else {
        if (itemNumber < self.mediaItems.count) {
            ALAsset *asset = self.mediaItems[itemNumber];
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
        
            cell.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
            
            if ([type isEqualToString:ALAssetTypePhoto]) {
                cell.durationLabel.text = nil;
            }
            else if ([type isEqualToString:ALAssetTypeVideo]) {
                cell.durationLabel.text = [self formatTime:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
            }
        }
        
    }
    
    return cell;
}

//http://stackoverflow.com/questions/22652624/getting-video-duration-from-alasset
- (NSString *)formatTime:(double)totalSeconds

{
    NSTimeInterval timeInterval = totalSeconds;
    long seconds = lroundf(timeInterval); // Modulo (%) operator below needs int or long
    int hour = 0;
    int minute = seconds/60.0f;
    int second = seconds % 60;
    if (minute > 59) {
        hour = minute/60;
        minute = minute%60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    }
    else{
        return [NSString stringWithFormat:@"%02d:%02d", minute, second];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemNumber = indexPath.row;
    
    if (self.linksToCamera) {
        itemNumber--;
    }
    
    if (itemNumber < 0) {
        NHPhotoCaptureViewController *viewController = [[NHPhotoCaptureViewController alloc] init];
        viewController.firstController = NO;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        if (itemNumber < self.mediaItems.count) {
            
            __weak __typeof(self) weakSelf = self;
            ALAsset *asset = self.mediaItems[itemNumber];
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            
            if ([weakSelf.nhDelegate respondsToSelector:@selector(mediaPickerDidStartExporting:)]) {
                [weakSelf.nhDelegate mediaPickerDidStartExporting:weakSelf];
            }
            
            if ([type isEqualToString:ALAssetTypePhoto]) {
                CGFloat scale = [representation scale];
                UIImageOrientation orientation = UIImageOrientationUp;
                NSNumber* orientationValue = [asset valueForProperty:ALAssetPropertyOrientation];
                if (orientationValue != nil) {
                    orientation = [orientationValue intValue];
                }
                
                UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:scale orientation:orientation];
                
                if (image) {
                    UIImage *resultImage;
                    CGSize imageSizeToFit = CGSizeZero;
                    
                    
                    if ([weakSelf.nhDelegate respondsToSelector:@selector(imageSizeToFitForMediaPicker:)]) {
                        imageSizeToFit = [weakSelf.nhDelegate imageSizeToFitForMediaPicker:weakSelf];
                    }
                    
                    if (CGSizeEqualToSize(imageSizeToFit, CGSizeZero)) {
                        resultImage = image;
                    }
                    else {
                        resultImage = [image nhr_rescaleToFit:imageSizeToFit];
                    }
                    
                    if (resultImage) {
                        BOOL shouldEdit = YES;
                        
                        __weak __typeof(self) weakSelf = self;
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(mediaPicker:shouldEditImage:)]) {
                            shouldEdit = [weakSelf.nhDelegate mediaPicker:weakSelf shouldEditImage:resultImage];
                        }
                        
                        if (shouldEdit) {
                            NHPhotoEditorViewController *viewController = [[NHPhotoEditorViewController alloc] initWithUIImage:resultImage];
                            [self.navigationController pushViewController:viewController animated:YES];
                            
                        }
                    }
                }
            } //if type is Photo
            else if ([type isEqualToString:ALAssetTypeVideo]) {
                NSURL *assetURL = [representation url];
                if (assetURL) {
                    
                    
                    NHVideoEditViewController *viewController = [[NHVideoEditViewController alloc] initWithAssetURL:assetURL];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
            } //if type is Video
            
            
            if ([weakSelf.nhDelegate respondsToSelector:@selector(mediaPickerDidFinishExporting:)]) {
                [weakSelf.nhDelegate mediaPickerDidFinishExporting:weakSelf];
            }
        }
    }
    
}

//MARK: setters

- (void)setLinksToCamera:(BOOL)linksToCamera {
    [self willChangeValueForKey:@"linksToCamera"];
    _linksToCamera = linksToCamera;
    [self.mediaCollectionView reloadData];
    [self didChangeValueForKey:@"linksToCamera"];
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barTintColor = barTintColor;
    self.navigationController.navigationBar.barTintColor = barTintColor ?: [UIColor whiteColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setBarButtonTintColor:(UIColor *)barButtonTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barButtonTintColor = barButtonTintColor;
    self.navigationController.navigationBar.tintColor = barButtonTintColor ?: [UIColor blackColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setFirstController:(BOOL)firstController {
    [self willChangeValueForKey:@"firstController"];
    _firstController = firstController;
    
    [self.closeButton setImage:(firstController ? image(@"NHRecorder.close") : image(@"NHRecorder.back")) forState:UIControlStateNormal];
    [self didChangeValueForKey:@"firstController"];
}

//MARK: view overrides

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor blackColor];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.mediaCollectionView reloadData];
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)setMediaType:(NHMediaPickerType)mediaType {
    [self willChangeValueForKey:@"mediaType"];
    _mediaType = mediaType;
    
    [self loadMediaFromLibrary];
    [self didChangeValueForKey:@"mediaType"];
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
    self.mediaCollectionView.delegate = nil;
    self.mediaCollectionView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}
@end
