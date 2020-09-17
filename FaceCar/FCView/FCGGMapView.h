//
//  FCGGMapView.h
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#define kBtnLocationSize 40
#define kBtnLocationOffsetRight 15
#define kBtnLocationOffsetBotttom 15

@interface FCGGMapView : GMSMapView <GMSMapViewDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic) CGPoint btnLocationPosition;
@property (strong, nonatomic) GMSMarker* startMarker;
@property (strong, nonatomic) GMSMarker* endMarker;
@property (strong, nonatomic) GMSPolyline* polyline;
@property (strong, nonatomic) GMSCoordinateBounds* polylineBounds;

- (void) addMarker: (UIImage*) icon location: (CLLocationCoordinate2D) location;
- (void) drawPolyline: (NSString*) decode;

- (void) moveCameraToCurrentLocation;
- (void) moveCameraTo: (CLLocation*) location;
- (void) moveCameraTo: (CLLocation*) location
                 zoom: (CGFloat) zoomlvl;

- (void) addLocationButton:(FCButton*) button;

- (void)setGeocodingCallback:(void (^)(FCPlace*))callback;
- (void)setInfoWindowCallback:(void (^)(GMSMarker*))callback;
- (void)setCameraChangedCallback:(void (^)(GMSCameraPosition*))callback;

@end
