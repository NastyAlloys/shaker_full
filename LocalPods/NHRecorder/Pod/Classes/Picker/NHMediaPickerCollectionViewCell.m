//
//  NHMediaPickerCollectionViewCell.m
//  Pods
//
//  Created by Sergey Minakov on 15.06.15.
//
//

#import "NHMediaPickerCollectionViewCell.h"

@interface NHMediaPickerCollectionViewCell ()

@property (nonatomic, strong) id orientationChange;

@end

@implementation NHMediaPickerCollectionViewCell

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

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.durationLabel.text = nil;
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)commonInit {
    
    self.contentView.clipsToBounds = YES;
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.imageView];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:0]];
    
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.backgroundColor = [UIColor clearColor];
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationLabel.text = nil;
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    self.durationLabel.font = [UIFont systemFontOfSize:12];
    self.durationLabel.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:self.durationLabel];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:-5]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:-2.5]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:2.5]];
    
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

- (void)deviceOrientationChange {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    CGFloat xScale = 1;
    CGFloat angle = 0;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI_2;
            xScale = -1;
            break;
        default:
            return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.contentView.transform = CGAffineTransformMakeRotation(angle);
                         self.durationLabel.transform = CGAffineTransformMakeScale(xScale, 1);
                         self.imageView.transform = CGAffineTransformMakeScale(xScale, 1);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}
@end
