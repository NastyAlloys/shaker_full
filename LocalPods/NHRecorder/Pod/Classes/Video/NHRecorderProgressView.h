//
//  NHRecorderProgressView.h
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import <UIKit/UIKit.h>

@interface NHRecorderProgressView : UIView

@property (nonatomic, strong) UIColor *progressColor;

@property (nonatomic, assign) float minValue;
@property (nonatomic, strong) UIColor *minValueColor;

@property (nonatomic, strong) UIColor *separatorColor;

@property (nonatomic, assign) float progress;

- (void)addSeparatorAtProgress:(float)value;
- (void)removeAllSeparators;

@end
