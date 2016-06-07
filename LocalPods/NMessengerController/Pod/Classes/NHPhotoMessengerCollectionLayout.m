//
//  NHPhotoMessengerCollectionLayout.m
//  Pods
//
//  Created by Naithar on 30.04.15.
//
//

#import "NHPhotoMessengerCollectionLayout.h"

@interface NHPhotoMessengerCollectionLayout ()

@end

@implementation NHPhotoMessengerCollectionLayout

- (instancetype)init {
    self = [super init];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

@end
