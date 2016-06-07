//
//  NHMapViewAnnotation.m
//  Pods
//
//  Created by Sergey Minakov on 28.05.15.
//
//

#import "NHMapViewAnnotation.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHMapViewAnnotation class]]\
pathForResource:name ofType:@"png"]]

@interface NHMapViewAnnotation ()

@property (nonatomic, strong) NHMapViewAnnotationView *annotationView;

@end

@implementation NHMapViewAnnotation

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.annotationView = [[NHMapViewAnnotationView alloc] init];
    self.annotationView.image = [UIImage imageNamed:@"feed.shake.marker"];
    self.annotationView.centerOffset = CGPointMake(0, -13);
    self.annotationView.canShowCallout = YES;
}

@end
