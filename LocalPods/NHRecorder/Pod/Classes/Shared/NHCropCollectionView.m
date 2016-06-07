//
//  NHCameraCropCollectionView.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHCropCollectionView.h"
#import "NHCropCollectionViewCell.h"

@interface NHCropCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation NHCropCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    UICollectionViewFlowLayout *realLayout = [UICollectionViewFlowLayout new];
    realLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self = [super initWithFrame:frame collectionViewLayout:realLayout];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.delegate = self;
    self.dataSource = self;
    self.scrollsToTop = NO;
    self.bounces = YES;
    self.alwaysBounceVertical = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    [self registerClass:[NHCropCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width / 4 - 5, self.bounds.size.height);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NHCropCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell reloadWithType:[self typeFromIndex:indexPath.row] andSelected:self.selectedIndex == indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    [self setSelected:indexPath.row];
}

- (void)setSelected:(NSInteger)index {
    self.selectedIndex = index;
    
    [self reloadData];
    
    NHPhotoCropType type = [self typeFromIndex:index];
    
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(cropView:didSelectType:)]) {
        [weakSelf.nhDelegate cropView:weakSelf didSelectType:type];
    }
}

- (NHPhotoCropType)typeFromIndex:(NSInteger)index {
    switch (index) {
        case 1:
            return NHPhotoCropTypeSquare;
        case 2:
            return NHPhotoCropType4x3;
        case 3:
            return NHPhotoCropType16x9;
        case 4:
            return NHPhotoCropType3x4;
        default:
            break;
    }
    
    return NHPhotoCropTypeNone;
}


- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
}

@end
