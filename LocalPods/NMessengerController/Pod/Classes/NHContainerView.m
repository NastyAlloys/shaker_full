//
//  NHContainerView.m
//  Pods
//
//  Created by Naithar on 29.04.15.
//
//

#import "NHContainerView.h"

const NSInteger kNHContainerViewTagIndex = 10000;

@implementation NHContainerView


- (CGSize)intrinsicContentSize {
    return self.contentSize;
}

- (void)calculateContentSize {

    if (!self.subviews.count
        || ![self viewWithTag:kNHContainerViewTagIndex]) {
        return;
    }

    __block CGSize newContentSize = CGSizeZero;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {

        if (obj.tag >= kNHContainerViewTagIndex) {
            CGFloat maxX = CGRectGetMaxX(obj.frame);
            CGFloat maxY = CGRectGetMaxY(obj.frame);

            if (maxX > newContentSize.width) {
                newContentSize.width = maxX;
            }

            if (maxY > newContentSize.height) {
                newContentSize.height = maxY;
            }
        }
    }];

    self.contentSize = newContentSize;
}

- (void)addSubview:(UIView *)view andIndex:(NSUInteger)index {
    [self addSubview:view withSize:view.bounds.size andIndex:index];
}
- (void)addSubview:(UIView *)view withSize:(CGSize)size andIndex:(NSUInteger)index {
    view.tag = kNHContainerViewTagIndex + index;

    CGRect viewFrame = view.frame;
    viewFrame.size = size;

    if (index == 0) {
        viewFrame.origin = CGPointZero;
    }
    else {
        UIView *indexedView = [self viewWithTag:kNHContainerViewTagIndex + index - 1];
        if (indexedView) {
            viewFrame.origin = CGPointMake(CGRectGetMaxX(indexedView.frame), 0);
        }
    }

    view.frame = viewFrame;

    [self addSubview:view];

    [self calculateContentSize];
    [self invalidateIntrinsicContentSize];
    [self.superview layoutIfNeeded];
}

@end
