//
//  NHWebViewTitleLabel.m
//  Pods
//
//  Created by Sergey Minakov on 01.06.15.
//
//

#import "NHWebViewTitleView.h"

@interface NHWebViewTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *urlLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) NHWebViewTitleViewState currentState;

@end

@implementation NHWebViewTitleView

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
    self.clipsToBounds = YES;
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    [self addSubview:self.titleLabel];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0 constant:0]];
    [self.titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.titleLabel
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0 constant:26]];
    
    
    
    self.urlLabel = [[UILabel alloc] init];
    [self.urlLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.urlLabel.textAlignment = NSTextAlignmentCenter;
    self.urlLabel.font = [UIFont systemFontOfSize:12];
    self.urlLabel.textColor = [UIColor grayColor];
    [self addSubview:self.urlLabel];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.urlLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.titleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.urlLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.urlLabel
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0 constant:0]];
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.activityIndicator startAnimating];
    [self addSubview:self.activityIndicator];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.titleLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.titleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];

    
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.urlLabel.hidden = frame.size.height < 35;
}

- (void)setState:(NHWebViewTitleViewState)state {
    switch (state) {
        case NHWebViewTitleViewStateText:
            self.activityIndicator.hidden = YES;
            self.titleLabel.hidden = NO;
            break;
        case NHWebViewTitleViewStateFailed:
            self.activityIndicator.hidden = YES;
            self.titleLabel.hidden = YES;
            break;
        case NHWebViewTitleViewStateLoading:
            self.activityIndicator.hidden = NO;
            self.titleLabel.hidden = YES;
            break;
        default:
            break;
    }
    
    self.currentState = state;
}

@end
