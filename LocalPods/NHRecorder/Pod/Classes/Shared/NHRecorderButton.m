//
//  NHRecorderButton.m
//  Pods
//
//  Created by Sergey Minakov on 16.06.15.
//
//

#import "NHRecorderButton.h"

@implementation NHRecorderButton

- (UIEdgeInsets)alignmentRectInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(self.customAlignmentInsets, UIEdgeInsetsZero)) {
        return [super alignmentRectInsets];
    }
    
    return self.customAlignmentInsets;
}

@end
