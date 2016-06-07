//
//  NHMapViewAnnotationView.h
//  Pods
//
//  Created by Sergey Minakov on 28.05.15.
//
//

#import <MapKit/MapKit.h>

@interface NHMapViewAnnotationView : MKAnnotationView

@property (nonatomic, assign) BOOL useCustomAnnotation;

- (void)showPopover;

@end
