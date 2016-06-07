//
//  NHImageData.h
//  Pods
//
//  Created by Sergey Minakov on 18.05.15.
//
//

@import UIKit;

@interface NHImageData : NSObject

@property (nonatomic, readonly, strong) UIImage *image;
@property (nonatomic, readonly, copy) NSString *path;

- (instancetype)initWithImage:(UIImage*)image andUrl:(NSURL*)url;
- (instancetype)initWithImage:(UIImage*)image andPath:(NSString*)path;
@end
