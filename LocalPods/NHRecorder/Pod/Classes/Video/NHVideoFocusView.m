//
//  NHVideoFocusView.m
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import "NHVideoFocusView.h"

@interface NHVideoFocusView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) CALayer *innerFocusCircle;
@property (nonatomic, strong) CALayer *outterFocusCircle;
@end

@implementation NHVideoFocusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    
    self.innerFocusCircle = [[CALayer alloc] init];
    self.innerFocusCircle.borderWidth = 2.5;
    self.innerFocusCircle.borderColor = [UIColor whiteColor].CGColor;
    self.innerFocusCircle.cornerRadius = 25;
    self.innerFocusCircle.bounds = CGRectMake(0, 0, 50, 50);
    self.innerFocusCircle.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.innerFocusCircle];
    self.innerFocusCircle.opacity = 0;
    
    self.outterFocusCircle = [[CALayer alloc] init];
    self.outterFocusCircle.bounds = CGRectMake(0, 0, 90, 90);
    self.outterFocusCircle.borderWidth = 4;
    self.outterFocusCircle.borderColor = [UIColor whiteColor].CGColor;
    self.outterFocusCircle.cornerRadius = 45;
    self.outterFocusCircle.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.outterFocusCircle];
    self.outterFocusCircle.opacity = 0;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)tapGestureAction:(UITapGestureRecognizer*)recognizer {
    
    CGPoint focusPoint = [recognizer locationInView:self];
    
    [self setFocusPoint:focusPoint withMode:AVCaptureFocusModeAutoFocus];
    
    [self drawFocusAtPoint:focusPoint andRemove:YES];
}

- (void)drawFocusAtPoint:(CGPoint)point andRemove:(BOOL)remove
{
    if ( remove ) {
        [self.innerFocusCircle removeAllAnimations];
        [self.outterFocusCircle removeAllAnimations];
    }
    
    if ( [self.outterFocusCircle animationForKey:@"transform.scale"] == nil
        && [self.outterFocusCircle animationForKey:@"opacity"] == nil
        && [self.innerFocusCircle animationForKey:@"opacity"] == nil) {
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        [self.outterFocusCircle setPosition:point];
        [self.innerFocusCircle setPosition:point];
        [CATransaction commit];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:1]];
        [scale setToValue:[NSNumber numberWithFloat:0.7]];
        [scale setDuration:0.8];
        [scale setRemovedOnCompletion:YES];
        
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity setFromValue:[NSNumber numberWithFloat:1]];
        [opacity setToValue:[NSNumber numberWithFloat:0]];
        [opacity setDuration:0.8];
        [opacity setRemovedOnCompletion:YES];
        
        [self.outterFocusCircle addAnimation:scale forKey:@"transform.scale"];
        [self.outterFocusCircle addAnimation:opacity forKey:@"opacity"];
        
        [self.innerFocusCircle addAnimation:opacity forKey:@"opacity"];
    }
}

- (void)setFocusPoint:(CGPoint)point withMode:(AVCaptureFocusMode)mode {
    
    switch (mode) {
        case AVCaptureFocusModeAutoFocus:
            [self.captureManager autoFocusAtPoint:point];
            break;
        case AVCaptureFocusModeContinuousAutoFocus:
            [self.captureManager continuousFocusAtPoint:point];
            break;
        default:
            break;
    }
}


@end
