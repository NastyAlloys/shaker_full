//
//  NHCameraFocusView.m
//  Pods
//
//  Created by Sergey Minakov on 13.06.15.
//
//

#import "NHPhotoFocusView.h"

const CGFloat kNHRecorderMinZoom = 1;
const CGFloat kNHRecorderMaxZoom = 5;

@interface NHPhotoFocusView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) CALayer *innerFocusCircle;
@property (nonatomic, strong) CALayer *outterFocusCircle;

@property (nonatomic, assign) CGFloat currentZoom;
@property (nonatomic, assign) CGFloat prevZoom;
@end

@implementation NHPhotoFocusView

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
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    [self addGestureRecognizer:self.pinchGesture];
    
    self.currentZoom = 1;
    self.prevZoom = 1;
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

- (void)pinchGestureAction:(UIPinchGestureRecognizer*)recognizer {
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self];
        
        if (![self.layer containsPoint:location]) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        self.currentZoom = self.prevZoom * recognizer.scale;
        
        if (self.currentZoom < kNHRecorderMinZoom) {
            self.currentZoom = kNHRecorderMinZoom;
        }
        if (self.currentZoom > kNHRecorderMaxZoom) {
            self.currentZoom = kNHRecorderMaxZoom;
        }
        
        [self setZoom:self.currentZoom];
    }
    
    if ( [recognizer state] == UIGestureRecognizerStateEnded ||
        [recognizer state] == UIGestureRecognizerStateCancelled ||
        [recognizer state] == UIGestureRecognizerStateFailed) {
        self.prevZoom = self.currentZoom;
    }
}

- (void)setZoom:(CGFloat)zoomValue {
    CGFloat len = 1 / zoomValue; // notice: zoomValue >= 1
    CGFloat pos = (1 - len) * .5f;
    
    CGRect cropRect = CGRectMake(pos, pos, len, len);
    NSLog(@"%@", NSStringFromCGRect(cropRect));
    [self.cropFilter setCropRegion:cropRect];
}

- (void)setFocusPoint:(CGPoint)point {
    [self setFocusPoint:point withMode:AVCaptureFocusModeContinuousAutoFocus];
}

- (void)setFocusPoint:(CGPoint)point withMode:(AVCaptureFocusMode)mode {
    AVCaptureDevice *camera = self.camera.inputCamera;
    if ([camera isFocusModeSupported:mode]) {
        [camera lockForConfiguration:nil];
        [camera setFocusMode:mode];
        [camera setFocusPointOfInterest:point];
        [camera unlockForConfiguration];
    }
}

@end
