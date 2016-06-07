//
//  NHImageViewController.h
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import <UIKit/UIKit.h>
#import "NHImageData.h"

extern NSString *const kNHImageViewBackgroundColorAttributeName;
extern NSString *const kNHImageViewTextColorAttributeName;
extern NSString *const kNHImageViewTextFontAttributeName;


@interface NHImageViewLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets textInsets;

@end

@interface NHImageViewController : UIViewController

@property (strong, readonly, nonatomic) UIButton *closeButton;
@property (strong, readonly, nonatomic) UIButton *optionsButton;

@property (strong, readonly, nonatomic) NHImageViewLabel *noteLabel;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;

+ (NSMutableDictionary*)defaultSettings;

- (void)setStartingPage:(NSInteger)startPage;

- (BOOL)hideInterface;
- (BOOL)displayInterface;

- (BOOL)saveCurrentPageImage;
- (void)reloadCurrentPageImage;
- (BOOL)canCopyLink;
- (void)copyLink;

+ (instancetype)showImage:(UIImage*)image inViewController:(UIViewController*)controller;
+ (instancetype)showImage:(UIImage*)image withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (instancetype)showImageAtPath:(NSString*)imagePath inViewController:(UIViewController*)controller;
+ (instancetype)showImageAtPath:(NSString*)imagePath withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (instancetype)showImageAtURL:(NSURL*)imageURL inViewController:(UIViewController*)controller;
+ (instancetype)showImageAtURL:(NSURL*)imageURL withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (instancetype)presentIn:(UIViewController*)controller withData:(NSArray*)dataArray;
+ (instancetype)presentIn:(UIViewController*)controller withData:(NSArray*)dataArray andNote:(NSString*)note;


@end
