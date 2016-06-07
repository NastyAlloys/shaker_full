//
//  NHCameraFilterView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@class NHFilterCollectionView;

typedef NS_ENUM(NSUInteger, NHFilterType) {
    NHFilterTypeOriginal,
    NHFilterType1997,
    NHFilterTypeAmaro,
    NHFilterTypeGray,
    NHFilterTypeHudson,
    NHFilterTypeMayfair,
    NHFilterTypeNashville,
    NHFilterTypeValencia
};

@protocol NHFilterCollectionViewDelegate <NSObject>

@optional
- (void)filterView:(NHFilterCollectionView*)filteView didSelectFilter:(GPUImageFilter*)filter;
- (void)filterView:(NHFilterCollectionView*)filteView didSelectFilterType:(NHFilterType)filterType;

@end

@interface NHFilterCollectionView : UICollectionView

@property (nonatomic, weak) id<NHFilterCollectionViewDelegate> nhDelegate;

- (instancetype)initWithImage:(UIImage*)image;

- (void)setSelected:(NSInteger)index;

+ (GPUImageFilter*)filterForType:(NHFilterType)type;
@end
