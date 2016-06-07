//
//  NHSearchResultView.m
//  Pods
//
//  Created by Sergey Minakov on 13.08.15.
//
//

#import "NHSearchResultView.h"

@interface NHSearchResultView ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) UIView *searchBackgroundView;

@end

@implementation NHSearchResultView

- (instancetype)initWithBackgroundView:(UIView *)view {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        _searchBackgroundView = view;
        
        [self nhCommonInit];
    }
    return self;
}

- (void)prepareWithOffsetPoint:(CGPoint)point {
    self.image = nil;
    if (!self.searchBackgroundView) {
        return;
    }
    
    CGRect snapshotRect = CGRectMake(point.x,
                                     point.y,
                                     self.searchBackgroundView.bounds.size.width - point.x,
                                     self.searchBackgroundView.bounds.size.height - point.y);
    [self getSnapshotForView:self.searchBackgroundView withRect:snapshotRect];
}

- (void)drawRect:(CGRect)rect {
    [self.image drawInRect:CGRectMake(rect.origin.x, rect.origin.y, self.image.size.width, self.image.size.height)];
    
    [(self.overlayColor ?: [[UIColor blackColor] colorWithAlphaComponent:0.5]) set];
    
    [[UIBezierPath bezierPathWithRect:rect] fill];
}

- (CGImageRef)gradientImage {
    static UIImage *gradientImage;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 0);
        CGContextRef maskContext = UIGraphicsGetCurrentContext();
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        int componentCount = 2;
        CGFloat components[8] = {
            1.0, 1.0, 1.0, 1.0,
            .0, .0, .0, .0,
        };
        CGFloat locations[2] = { 0.0, 0.9 };
        
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, componentCount);
        CGPoint startPoint = CGPointMake(0, 100);
        CGPoint endPoint = CGPointMake(0, 0);
        CGContextDrawLinearGradient(maskContext, gradient, startPoint, endPoint, 0);
        
        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    });
    
    return gradientImage.CGImage;
}
- (void)getSnapshotForView:(UIView*)view withRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextConcatCTM(context,
                       CGAffineTransformMakeTranslation(
                                                        -rect.origin.x,
                                                        -rect.origin.y));
    
    
    
    CGContextClipToMask(context, rect, [self gradientImage]);
    
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }
    else {
        [view.layer renderInContext:context];
    }
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplay];
}

- (void)nhCommonInit {
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.tableView
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeTop
                         multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.tableView
                         attribute:NSLayoutAttributeLeft
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeLeft
                         multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.tableView
                         attribute:NSLayoutAttributeRight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeRight
                         multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.tableView
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeBottom
                         multiplier:1.0 constant:0]];
    
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"dealloc search result view");
#endif
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end