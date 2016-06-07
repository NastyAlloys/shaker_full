//
//  NHImageData.m
//  Pods
//
//  Created by Sergey Minakov on 18.05.15.
//
//

#import "NHImageData.h"

@interface NHImageData ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *path;

@end


@implementation NHImageData

- (instancetype)initWithImage:(UIImage*)image andUrl:(NSURL*)url {
    return [self initWithImage:image andPath:url.absoluteString];
}
- (instancetype)initWithImage:(UIImage*)image andPath:(NSString*)path {
    self = [super init];

    if (self) {
        _image = image;
        _path = path;
    }

    return self;
}

@end
