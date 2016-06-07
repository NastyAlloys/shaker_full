//
//  NHVideoView.h
//  Pods
//
//  Created by Sergey Minakov on 28.07.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "NHCameraCropView.h"
#import "NHFilterCollectionView.h"

@interface NHVideoView : UIScrollView

@property (nonatomic, readonly, strong) GPUImageView *contentView;
@property (nonatomic, readonly, strong) NHCameraCropView *cropView;

- (instancetype)initWithURL:(NSURL*)url;

- (void)sizeContent;
- (void)processVideoToPath:(NSString*)path withBlock:(void(^)(NSURL *videoURL))block;
- (void)setCropType:(NHPhotoCropType)type;
- (void)setDisplayFilter:(GPUImageFilter*)filter;
- (void)setSavingFilterType:(NHFilterType)filterType;


- (void)startVideo;

@end
