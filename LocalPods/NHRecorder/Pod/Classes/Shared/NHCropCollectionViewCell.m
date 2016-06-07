//
//  NHCropCollectionViewCell.m
//  Pods
//
//  Created by Sergey Minakov on 15.06.15.
//
//

#import "NHCropCollectionViewCell.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHCropCollectionViewCell class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHCropCollectionViewCell class]], nil)

@interface NHCropCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) id orientationChange;

@end

@implementation NHCropCollectionViewCell


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
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.textLabel];
    
    [self setupImageViewConstraints];
    
    [self setupTextLabelConstraints];
    
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

- (void)setupImageViewConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0 constant:0]];
    
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.imageView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0 constant:50]];
    
    
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.imageView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0 constant:0]];
}

- (void)setupTextLabelConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.imageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:2]];
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:-2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:0]];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.textLabel.text = nil;
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)reloadWithType:(NHPhotoCropType)type {
    [self reloadWithType:type andSelected:NO];
}

- (void)reloadWithType:(NHPhotoCropType)type andSelected:(BOOL)selected {
    NSString *text;
    UIImage *image;
    
    switch (type) {
        case NHPhotoCropTypeNone:
            text = localization(@"NHRecorder.crop.none", @"NHRecorder");
            image = (selected
            ? image(@"NHRecorder.crop.none-active")
            : image(@"NHRecorder.crop.none"));
            break;
        case NHPhotoCropTypeSquare:
            text = localization(@"NHRecorder.crop.square", @"NHRecorder");
            image = (selected
            ? image(@"NHRecorder.crop.square-active")
            : image(@"NHRecorder.crop.square"));
            break;
        case NHPhotoCropType4x3:
            text = localization(@"NHRecorder.crop.4x3", @"NHRecorder");
            image = selected
            ? image(@"NHRecorder.crop.4x3-active")
            : image(@"NHRecorder.crop.4x3");
            break;
        case NHPhotoCropType16x9:
            text = localization(@"NHRecorder.crop.16x9", @"NHRecorder");
            image = selected
            ? image(@"NHRecorder.crop.16x9-active")
            : image(@"NHRecorder.crop.16x9");
            break;
        case NHPhotoCropType3x4:
            text = localization(@"NHRecorder.crop.3x4", @"NHRecorder");
            image = selected
            ? image(@"NHRecorder.crop.3x4-active")
            : image(@"NHRecorder.crop.3x4");
            break;
        default:
            break;
    }
    
    self.imageView.image = image;
    self.textLabel.text = text;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}
@end
