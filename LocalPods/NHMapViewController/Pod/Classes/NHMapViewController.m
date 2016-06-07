//
//  NHMapViewController.m
//  Pods
//
//  Created by Sergey Minakov on 28.05.15.
//
//

#import "NHMapViewController.h"

@interface NHMapViewController ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D markLocation;
@property (nonatomic, copy) NSString *markName;

@property (nonatomic, strong) NHMapViewAnnotation *mark;

@end

@implementation NHMapViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.mapView = [[MKMapView alloc] init];
    [self.mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    self.mark = [[NHMapViewAnnotation alloc] init];
}

- (void)setMarkName:(NSString*)name andLocationLat:(CLLocationDegrees)lat andLon:(CLLocationDegrees)lon {
    self.markName = name;
    self.markLocation = CLLocationCoordinate2DMake(lat, lon);
    
    self.navigationItem.title = self.markName;

    if (![self.mapView.annotations containsObject:self.mark]) {
        [self.mapView addAnnotation:self.mark];
    }
    
    self.mark.coordinate = self.markLocation;
    self.mark.title = self.markName;
}

- (void)setMapCenterWithLat:(CLLocationDegrees)lat andLon:(CLLocationDegrees)lon {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lon);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    [self.mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
}

- (void)openCurrentLocation {
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.mapView.centerCoordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    NSDictionary *options = @{};
    
    [mapItem openInMapsWithLaunchOptions:options];
}

- (void)openMarkLocation {
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.markLocation addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.markName];
    NSDictionary *options = @{};
    
    [mapItem openInMapsWithLaunchOptions:options];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[NHMapViewAnnotation class]]) {
        return ((NHMapViewAnnotation*)annotation).annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {    
    if (view.canShowCallout) {
        if ([view isKindOfClass:[NHMapViewAnnotationView class]]
            && ((NHMapViewAnnotationView*)view).useCustomAnnotation) {
            [mapView deselectAnnotation:view.annotation animated:NO];
            [((NHMapViewAnnotationView*)view) showPopover];
        }
    }
    else {
        [mapView deselectAnnotation:view.annotation animated:NO];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[NHMapViewAnnotationView class]]
        && !view.canShowCallout) {
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
