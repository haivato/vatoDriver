//
//  FCGGMapView.m
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCGGMapView.h"
#import "GoogleMapsHelper.h"

#define CLCOORDINATES_EQUAL( coord1, coord2 ) (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)

@interface FCGGMapView () <CAAnimationDelegate>
@property(strong, nonatomic) CAShapeLayer* polylineAnimLayer;
@end


@implementation FCGGMapView {
    void (^_geocodingCallback)(FCPlace* place);
    void (^_infoWindowCallback)(GMSMarker* marker);
    void (^_cameraChangedCallback)(GMSCameraPosition* pos);
    FCButton* _locationBtn;
    CGFloat _zoom;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    _zoom = MAP_ZOOM_LEVEL;
    [self initGoogleMap];
}


- (void) initGoogleMap {
    NSURL *nightURL = [[NSBundle mainBundle] URLForResource:@"custom-map"
                                              withExtension:@"json"];
    GMSMapStyle* mapStyle = [GMSMapStyle styleWithContentsOfFileURL:nightURL error:NULL];
    self.mapStyle = mapStyle;
    self.settings.rotateGestures = NO;
    self.myLocationEnabled = YES;
    self.delegate = self;
    [self setMinZoom:kMinZoom maxZoom:kMaxZoom];
}

- (void) setGeocodingCallback:(void (^)(FCPlace *))callback {
    _geocodingCallback = callback;
}

- (void)setInfoWindowCallback:(void (^)(GMSMarker*))callback {
    _infoWindowCallback = callback;
}

- (void) setCameraChangedCallback:(void (^)(GMSCameraPosition *))callback {
    _cameraChangedCallback = callback;
}

- (void) addLocationButton : (FCButton*) btn {
    _locationBtn = btn;
    [_locationBtn addTarget:self
                     action:@selector(locationClicked:)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void) updateLogoGoogle: (CGFloat) y {
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(y, 0.0, y, 0.0);
    self.padding = mapInsets;
}

- (void)locationClicked:(id)sender {
    CLLocation* curr = [GoogleMapsHelper shareInstance].currentLocation;
    if (curr) {
        [self animationCameraTo:curr];
    }
    
}

- (void) moveCameraToCurrentLocation {
    CLLocation* curr = [GoogleMapsHelper shareInstance].currentLocation;
    if (curr)
        [self moveCameraTo:curr];
}

- (void) animationCameraTo: (CLLocation*) location {
    if (self.polyline) {
        [self animationCameraToBoundPolyline];
    }
    else {
        [self animateToLocation:location.coordinate];
//        [self animateToCameraPosition:[GMSCameraPosition cameraWithTarget:location.coordinate
//                                                                     zoom:_zoom]];
    }
}


- (void) moveCameraTo: (CLLocation*) location {
    if (self.polyline) {
        [self animationCameraToBoundPolyline];
    }
    else {
        self.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:_zoom];
    }
}

- (void) moveCameraTo: (CLLocation*) location
                 zoom: (CGFloat) zoomlvl {
    _zoom = zoomlvl;
    [self moveCameraTo:location];
}

- (void) animationCameraToBoundPolyline {
    NSInteger screenW = [UIScreen mainScreen].bounds.size.width;
    NSInteger screenH = [UIScreen mainScreen].bounds.size.height;
    NSInteger w = screenW / 5;
    NSInteger top = (screenH - (screenW - w*2)) / 2;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:self.polyline.path];
    [self animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                              withEdgeInsets:UIEdgeInsetsMake(top, w, top, w)]];
    _polylineBounds = bounds;
}

#pragma mark - Button Location
- (void) showButton {
    if (_locationBtn && _locationBtn.hidden) {
        _locationBtn.hidden = NO;
        _locationBtn.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
        [UIView animateWithDuration:0.2f
                         animations:^{
                             _locationBtn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void) hideButton {
    if (_locationBtn) {
        _locationBtn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [UIView animateWithDuration:0.2f
                         animations:^{
                             _locationBtn.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
                         }
                         completion:^(BOOL finished) {
                             _locationBtn.hidden = YES;
                         }];
    }
}

#pragma mark - Marker
- (void) addMarker: (UIImage*) icon location: (CLLocationCoordinate2D) location {
    GMSMarker* marker = [[GMSMarker alloc] init];
    marker.icon = icon;
    marker.map = self;
    marker.position = location;
}

#pragma mark - Polyline
- (void) removePolyline {
    self.polyline.map = nil;
    self.polyline = nil;
}

- (void) drawPolyline: (NSString*) decode {
    if ([decode length] == 0) {
        return;
    }
    [self removePolyline];
    
    GMSPath* path = [GMSPath pathFromEncodedPath:decode];
    self.polyline = [GMSPolyline polylineWithPath:path];
    self.polyline.strokeColor = [UIColor orangeColor];
    self.polyline.strokeWidth = 2.5f;
    self.polyline.map = self;
    
    // zoom bound camera
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    [self zommMapToBound:bounds];
}

- (void) zommMapToBound: (GMSCoordinateBounds*) bounds {
    NSInteger w = [UIScreen mainScreen].bounds.size.width;
    [self animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                              withEdgeInsets:UIEdgeInsetsMake(w/4, w/4, w/8, w/4)]];
}

#pragma mark - Map Delegate

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if (_infoWindowCallback) {
        _infoWindowCallback(marker);
    }
    return YES;
}

- (UIView*) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    return nil;
}

- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
}

- (void) mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (_cameraChangedCallback) {
        _cameraChangedCallback(position);
    }
}

- (void) mapView:(GMSMapView*)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if (_geocodingCallback) {
        
//        _geocodingCallback(nil); // for reset first
//        [[GoogleMapsHelper shareInstance] getFCPlaceByLocation:[[CLLocation alloc] initWithLatitude:position.target.latitude longitude:position.target.longitude] block:^(FCPlace * place) {
//            if (_geocodingCallback)
//                _geocodingCallback(place);
//        }];
    }
    
    // show /hide button location
    if ([self mapTargetNearByMyLocation:position]) {
        [self hideButton];
    }
    else {
        [self showButton];
    }
}

- (BOOL) mapTargetNearByMyLocation: (GMSCameraPosition*) position {
    
    if (self.polyline) {
        CLLocationCoordinate2D north = _polylineBounds.northEast;
        CLLocationCoordinate2D sourth = _polylineBounds.southWest;
        
        BOOL res = [self.projection containsCoordinate:north] &&
                   [self.projection containsCoordinate:sourth];
        
        return res;
    }
    
    CLLocation* pos = [[CLLocation alloc] initWithLatitude:position.target.latitude
                                                 longitude:position.target.longitude];
    CLLocation* curr = [GoogleMapsHelper shareInstance].currentLocation;
    CGFloat dis = [pos distanceFromLocation:curr];
    
    return dis > 0 && dis < 10.0f; // < 10m
}

#pragma mark - Polyline animation
- (void) startPolylineAnimation {
    if (self.polylineAnimLayer) {
        [self.polylineAnimLayer removeFromSuperlayer];
        self.polylineAnimLayer = nil;
    }

    self.polylineAnimLayer = [self layerFromGMSMutablePath:self.polyline.path];
    [self.layer addSublayer:self.polylineAnimLayer];
    [self animatePath:self.polylineAnimLayer];
}

- (CAShapeLayer*)layerFromGMSMutablePath:(GMSPath*) path {
    UIBezierPath *breizerPath = [UIBezierPath bezierPath];
    
    CLLocationCoordinate2D firstCoordinate = [path coordinateAtIndex:0];
    [breizerPath moveToPoint:[self.projection pointForCoordinate:firstCoordinate]];
    
    for(int i=1; i<path.count; i++){
        CLLocationCoordinate2D coordinate = [path coordinateAtIndex:i];
        [breizerPath addLineToPoint:[self.projection pointForCoordinate:coordinate]];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [[breizerPath bezierPathByReversingPath] CGPath];
    shapeLayer.strokeColor = [[UIColor orangeColor] CGColor];
    shapeLayer.lineWidth = 2.5;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.cornerRadius = 5;
    
    return shapeLayer;
}

- (void)animatePath:(CAShapeLayer *)layer {
    self.polyline.map = nil;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.5f;
    pathAnimation.delegate = self;
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [layer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self startPolylineAnimation];
}

@end
