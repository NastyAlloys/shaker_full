//
//  NHRecorderProgressView.m
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import "NHRecorderProgressView.h"

@interface NHRecorderProgressView ()

@property (nonatomic, strong) NSMutableSet *separatorSet;

@end

@implementation NHRecorderProgressView

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
    self.separatorSet = [NSMutableSet new];
}

- (void)removeAllSeparators {
    self.separatorSet = [NSMutableSet new];
    [self setNeedsDisplay];
}

- (void)addSeparatorAtProgress:(float)value {
    
    [self.separatorSet addObject:@(value)];
    [self setNeedsDisplay];
}

- (void)setProgress:(float)progress {
    [self willChangeValueForKey:@"progress"];
    
    if (progress < _progress) {
        [self.separatorSet enumerateObjectsUsingBlock:^(NSNumber *obj, BOOL *stop) {
            if ([obj floatValue] > progress) {
                [self.separatorSet removeObject:obj];
            }
        }];
    }
    _progress = progress;
    
    [self setNeedsDisplay];
    [self didChangeValueForKey:@"progress"];
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat separatorWidth = 1;
    CGFloat width = round(self.progress * rect.size.width);
    CGFloat height = rect.size.height;
    
    [(self.minValueColor ?: [UIColor grayColor]) set];
    CGFloat minValueX = floor(self.minValue * rect.size.width - separatorWidth / 2);
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(minValueX, 0, separatorWidth, height)] fill];
    
    [(self.progressColor ?: [UIColor redColor]) set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)] fill];
    
    [self.separatorSet enumerateObjectsUsingBlock:^(NSNumber *key, BOOL *stop) {
        [(self.separatorColor ?: [UIColor blackColor]) set];
            CGFloat separatorX = floor([key floatValue] * rect.size.width - separatorWidth / 2);
            [[UIBezierPath bezierPathWithRect:CGRectMake(separatorX, 0, separatorWidth, height)] fill];
    }];
}

@end
