//
//  NHCameraCropView.m
//  Pods
//
//  Created by Sergey Minakov on 28.07.15.
//
//

#import "NHCameraCropView.h"

const CGFloat kNHRecorderCornerOffset = 25;
const CGFloat kNHRecorderCornerWidth = 4;
const CGFloat kNHRecorderBorderWidth = 3;
const CGFloat kNHRecorderLineWidth = 0.5;

@interface NHCameraCropView ()
@end

@implementation NHCameraCropView

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
    _cropType = NHPhotoCropTypeNone;
    _maxCropSize = CGSizeZero;
    
    [self resetCrop];
}

- (CGRect)cropRegionForView:(UIView*)view {
    switch (self.cropType) {
        case NHPhotoCropTypeNone:
            return CGRectMake(0, 0, 1, 1);
        default: {
            CGRect newRect = [self convertRect:self.cropRect toView:view];
            
            CGFloat resultWidth = floor(newRect.size.width - 0.5);
            CGFloat resultHeight = floor(newRect.size.height - 0.5);
            CGFloat resultXOffset = ceil(newRect.origin.x + 0.5);
            CGFloat resultYOffset = ceil(newRect.origin.y + 0.5);
            
            CGRect resultRect = CGRectMake(
                                           resultXOffset / ceil(view.bounds.size.width),
                                           resultYOffset / ceil(view.bounds.size.height),
                                           resultWidth / ceil(view.bounds.size.width),
                                           resultHeight / ceil(view.bounds.size.height));
            
            
            if (resultRect.origin.x >= 0
                && resultRect.origin.y >= 0
                && resultRect.size.width != 0
                && resultRect.size.height != 0
                && CGRectGetMaxY(resultRect) <= 1
                && CGRectGetMaxX(resultRect) <= 1) {
                
                return resultRect;
            }
            else {
                return CGRectMake(0, 0, 1, 1);
            }
            
        }
    }
}

- (void)resetCrop {
    CGPoint cropCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
        switch (self.cropType) {
            case NHPhotoCropTypeNone:
                self.hidden = YES;
                self.cropRect = CGRectZero;
                return;
            case NHPhotoCropTypeSquare:
            case NHPhotoCropTypeCircle: {
                self.hidden = NO;
                CGFloat value = MAX(MIN(self.maxCropSize.width, self.maxCropSize.height), 0);
                
                if (!value) {
                    value = MAX(MIN(self.bounds.size.width, self.bounds.size.height), 0);
                }
                self.cropRect = CGRectMake(cropCenter.x - value / 2, cropCenter.y - value / 2, value, value);
            } break;
            case NHPhotoCropType4x3: {
                self.hidden = NO;
                CGFloat width = MAX(MIN(self.maxCropSize.width, self.maxCropSize.height), 0);
                
                if (!width) {
                    width = MAX(MIN(self.bounds.size.width, self.bounds.size.height), 0);
                }
                
                CGFloat height = round(width * 3 / 4);
                self.cropRect = CGRectMake(cropCenter.x - width / 2, cropCenter.y - height / 2, width, height);
            } break;
            case NHPhotoCropType16x9: {
                self.hidden = NO;
                CGFloat width = MAX(MIN(self.maxCropSize.width, self.maxCropSize.height), 0);
                
                if (!width) {
                    width = MAX(MIN(self.bounds.size.width, self.bounds.size.height), 0);
                }
                
                CGFloat height = round(width * 9 / 16);
                self.cropRect = CGRectMake(cropCenter.x - width / 2, cropCenter.y - height / 2, width, height);
            } break;
            case NHPhotoCropType3x4: {
                self.hidden = NO;
                CGFloat height = MAX(MAX(self.maxCropSize.width, self.maxCropSize.height), 0);
                
                if (!height) {
                    height = MAX(MIN(self.bounds.size.width, self.bounds.size.height), 0);
                }
                CGFloat width = round(height * 3 / 4);
                self.cropRect = CGRectMake(cropCenter.x - width / 2, cropCenter.y - height / 2, width, height);
            } break;
            default:
                break;
        }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    @autoreleasepool {
        if (!CGSizeEqualToSize(rect.size, CGSizeZero)
            && self.cropRect.size.width > 0
            && self.cropRect.size.height > 0) {
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (context) {
                
                CGContextAddPath(context, [UIBezierPath bezierPathWithRect:rect].CGPath);
                
                CGPathRef cropPath = NULL;
                UIBezierPath *cropStrokePath;
                
                switch (self.cropType) {
                    case NHPhotoCropTypeCircle:
                        cropPath = [UIBezierPath bezierPathWithRoundedRect:self.cropRect cornerRadius:self.cropRect.size.width / 2].CGPath;
                        cropStrokePath = [UIBezierPath bezierPathWithRoundedRect:self.cropRect cornerRadius:self.cropRect.size.width / 2];
                        break;
                    default:
                        cropPath = [UIBezierPath bezierPathWithRect:self.cropRect].CGPath;
                        cropStrokePath = [UIBezierPath bezierPathWithRect:self.cropRect];
                        break;
                }
                
                if (cropPath) {
                    CGContextAddPath(context, cropPath);
                }
                
                [self.cropBackgroundColor ?: [[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
                CGContextEOFillPath(context);
                
                if (cropStrokePath
                    && self.showBorder) {
                    [[UIColor whiteColor] setStroke];
                    CGContextSetLineWidth(context, kNHRecorderCornerWidth);
                    
                    CGFloat minX = CGRectGetMinX(self.cropRect);
                    CGFloat minY = CGRectGetMinY(self.cropRect);
                    CGFloat maxX = CGRectGetMaxX(self.cropRect);
                    CGFloat maxY = CGRectGetMaxY(self.cropRect);
                    
                    if (self.cropType != NHPhotoCropTypeCircle) {
                        CGContextMoveToPoint(context,
                                             minX - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2,
                                             minY + kNHRecorderCornerOffset);
                        CGContextAddLineToPoint(context,
                                                minX - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2,
                                                minY - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2);
                        CGContextAddLineToPoint(context,
                                                minX + kNHRecorderCornerOffset,
                                                minY - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2);
                        
                        CGContextMoveToPoint(context,
                                             minX - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2,
                                             maxY - kNHRecorderCornerOffset);
                        CGContextAddLineToPoint(context,
                                                minX - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2,
                                                maxY + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2);
                        CGContextAddLineToPoint(context,
                                                minX + kNHRecorderCornerOffset,
                                                maxY + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2);
                        
                        CGContextMoveToPoint(context,
                                             maxX + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2,
                                             minY + kNHRecorderCornerOffset);
                        CGContextAddLineToPoint(context,
                                                maxX + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2,
                                                minY - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2);
                        CGContextAddLineToPoint(context,
                                                maxX - kNHRecorderCornerOffset,
                                                minY - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2);
                        
                        
                        CGContextMoveToPoint(context,
                                             maxX + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2,
                                             maxY - kNHRecorderCornerOffset);
                        CGContextAddLineToPoint(context,
                                                maxX + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2,
                                                maxY + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2);
                        CGContextAddLineToPoint(context,
                                                maxX - kNHRecorderCornerOffset,
                                                maxY + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2);
                        
                        
                        CGContextDrawPath(context, kCGPathStroke);
                    }
                    
                    [[UIColor whiteColor] setStroke];
                    CGContextAddPath(context, cropStrokePath.CGPath);
                    CGContextEOClip(context);
                    
                    CGContextSetLineWidth(context, kNHRecorderBorderWidth);
                    CGContextAddPath(context, cropStrokePath.CGPath);
                    CGContextDrawPath(context, kCGPathStroke);
                    
                    CGContextSetLineWidth(context, kNHRecorderLineWidth);
                    CGFloat width = round(self.cropRect.size.width / 3);
                    CGFloat height = round(self.cropRect.size.height / 3);
                    
                    
                    [[UIColor whiteColor] setStroke];
                    CGContextMoveToPoint(context, minX + width, minY);
                    CGContextAddLineToPoint(context, minX + width, maxY);
                    
                    CGContextMoveToPoint(context, maxX - width, minY);
                    CGContextAddLineToPoint(context, maxX - width, maxY);
                    
                    CGContextMoveToPoint(context, minX, minY + height);
                    CGContextAddLineToPoint(context, maxX, minY + height);
                    
                    CGContextMoveToPoint(context, minX, maxY - height);
                    CGContextAddLineToPoint(context, maxX, maxY - height);
                    
                    CGContextDrawPath(context, kCGPathStroke);
                }
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self resetCrop];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    [self resetCrop];
}

- (void)setMaxCropSize:(CGSize)maxCropSize {
    [self willChangeValueForKey:@"maxCropSize"];
    
    if (!CGSizeEqualToSize(_maxCropSize, maxCropSize)) {
        _maxCropSize = maxCropSize;
        [self resetCrop];
    }
    
    [self didChangeValueForKey:@"maxCropSize"];
}

- (void)setCropType:(NHPhotoCropType)cropType {
    [self willChangeValueForKey:@"cropType"];
    _cropType = cropType;
    [self didChangeValueForKey:@"cropType"];
    [self resetCrop];
}

@end
