//
//  NHMapViewController.h
//  Pods
//
//  Created by Sergey Minakov on 28.05.15.
//
//

#import <UIKit/UIKit.h>
#import "NHMapViewAnnotation.h"
@import MapKit;

@interface NHMapViewController : UIViewController

@property (nonatomic, readonly, strong) MKMapView *mapView;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D markLocation;
@property (nonatomic, readonly, copy) NSString *markName;
@property (nonatomic, readonly, strong) NHMapViewAnnotation *mark;

- (void)setMarkName:(NSString*)name andLocationLat:(CLLocationDegrees)lat andLon:(CLLocationDegrees)lon;
- (void)setMapCenterWithLat:(CLLocationDegrees)lat andLon:(CLLocationDegrees)lon;
- (void)openCurrentLocation;
- (void)openMarkLocation;
@end
