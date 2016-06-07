//
//  NHPhotoCollectionViewCell.m
//  Pods
//
//  Created by Naithar on 30.04.15.
//
//

#import "NHPhotoCollectionViewCell.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHPhotoCollectionViewCell class]]\
pathForResource:name ofType:@"png"]]


@interface NHPhotoCollectionViewCell ()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation NHPhotoCollectionViewCell


- (instancetype)init {
    self = [super init];

    if (self) {
        [self setupViews];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setupViews];
    }

    return self;
}

- (void)setupViews {

//    self.contentView.clipsToBounds = YES;
    self.contentView.opaque = YES;

    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.photoImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.photoImageView.opaque = YES;
    [self.photoImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.layer.cornerRadius = 5;
    self.photoImageView.clipsToBounds = YES;

    [self.contentView addSubview:self.photoImageView];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:5]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:0]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:0]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:-5]];

    self.closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.closeButton.opaque = YES;
    self.closeButton.imageView.contentMode = UIViewContentModeTopRight;
    self.closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.closeButton.backgroundColor = [UIColor clearColor];
    self.closeButton.clipsToBounds = YES;
    [self.closeButton setTitle:nil forState:UIControlStateNormal];
    [self.closeButton setImage:image(@"NHmessenger.remove") forState:UIControlStateNormal];
    [self.closeButton setTintColor:[UIColor grayColor]];

    [self.contentView addSubview:self.closeButton];

    [self.closeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.closeButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0 constant:35]];

    [self.closeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.closeButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0 constant:35]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:0]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:0]];

    [self.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)closeButtonAction:(UIButton*)button {
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.delegate respondsToSelector:@selector(didTouchCloseButton:)]) {
        [weakSelf.delegate didTouchCloseButton:weakSelf];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self reset];
}

- (void)reset {
    self.photoImageView.image = nil;
}

- (void)reloadWithImage:(UIImage*)image {
    self.photoImageView.image = image;
}
@end
