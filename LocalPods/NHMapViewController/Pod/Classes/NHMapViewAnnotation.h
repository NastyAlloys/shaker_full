//
//  NHMapViewAnnotation.h
//  Pods
//
//  Created by Sergey Minakov on 28.05.15.
//
//

#import <MapKit/MapKit.h>
#import "NHMapViewAnnotationView.h"

@interface NHMapViewAnnotation : MKPointAnnotation

@property (nonatomic, readonly, strong) NHMapViewAnnotationView *annotationView;

@end
