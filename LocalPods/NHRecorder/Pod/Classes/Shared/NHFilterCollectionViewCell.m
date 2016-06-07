//
//  NHFilterCollectionViewCell.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHFilterCollectionViewCell.h"

@interface NHFilterCollectionViewCell ()

@property (nonatomic, strong) UIImageView *filterImageView;
@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) UILabel *filterLabel;

@property (nonatomic, strong) id orientationChange;
@end

@implementation NHFilterCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.filterImageView = [[UIImageView alloc] init];
    self.filterImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.filterImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.filterImageView.layer.cornerRadius = 5;
    self.filterImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.filterImageView];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0 constant:50]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0 constant:0]];
    
    self.selectionView = [[UIView alloc] init];
    self.selectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionView.backgroundColor = [UIColor clearColor];
    self.selectionView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.selectionView.layer.cornerRadius = 7.5;
    self.selectionView.layer.borderWidth = 1;
    self.selectionView.clipsToBounds = YES;
    
    [self.contentView insertSubview:self.selectionView atIndex:0];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:-2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:-2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:2]];
    
    self.filterLabel = [[UILabel alloc] init];
    self.filterLabel.textColor = [UIColor whiteColor];
    self.filterLabel.font = [UIFont systemFontOfSize:12];
    self.filterLabel.backgroundColor = [UIColor clearColor];
    self.filterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterLabel.textAlignment = NSTextAlignmentCenter;
    self.filterLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.filterLabel.numberOfLines = 1;
    self.filterLabel.clipsToBounds = NO;
    
    [self.contentView insertSubview:self.filterLabel atIndex:0];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:-2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:-2]];
    
    __weak __typeof(self) weakSelf = self;
    self.orientationChange = [[NSNotificationCenter defaultCenter]
                              addObserverForName:UIDeviceOrientationDidChangeNotification
                              object:nil
                              queue:nil
                              usingBlock:^(NSNotification *note) {
                                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                                  if (strongSelf) {
                                      [strongSelf deviceOrientationChange];
                                  }
                              }];
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
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
                         self.contentView.transform = CGAffineTransformMakeRotation(angle);
                         self.contentView.frame = self.bounds;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)reloadWithImage:(UIImage*)image
              andFilter:(GPUImageFilter*)filter {
    [self reloadWithImage:image
                andFilter:filter
               isSelected:NO];
}

- (void)reloadWithImage:(UIImage*)image
              andFilter:(GPUImageFilter*)filter
             isSelected:(BOOL)selected {
    [self reloadWithImage:image andFilter:filter andName:nil isSelected:selected];
}

- (void)reloadWithImage:(UIImage*)image
              andFilter:(GPUImageFilter*)filter
                andName:(NSString*)name
             isSelected:(BOOL)selected {
    [filter useNextFrameForImageCapture];
    self.filterImageView.image = filter && image ? [filter imageByFilteringImage:image] : image;
    self.selectionView.hidden = !selected;
    self.filterLabel.text = name;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}
@end
