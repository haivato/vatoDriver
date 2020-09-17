//
//  GoogleMapsHelper.h
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCRouter.h"
#import "FCGGPlace.h"
#import <CoreLocation/CoreLocation.h>
#import "FCPlace.h"
#import <GoogleMaps/GoogleMaps.h>

@interface GoogleMapsHelper : NSObject
@property (strong, nonatomic, readonly) CLLocation * _Nullable currentLocation;
@property (strong, nonatomic, readonly) FCPlace * _Nullable currentFCLocation;
//@property (strong, nonatomic) CLLocationManager* _Nullable locationManager;

+ (GoogleMapsHelper*_Nonnull) shareInstance;

+ (BOOL) isCoordinateValid:(CLLocationCoordinate2D)coordinate;
+ (void) openMapWithStart:(CLLocationCoordinate2D) startCoordinate andEnd:(CLLocationCoordinate2D)endCoordinate;

- (void) startUpdateLocation;
- (void) stopUpdateLocation;
- (void) getAddressOfLocation:(CLLocationCoordinate2D)location
                 withCompletionBlock:(GMSReverseGeocodeCallback _Nullable )block;

- (NSString *_Nullable)encodeStringWithCoordinates:(NSArray *_Nullable)coordinates;
- (NSMutableArray*_Nullable) decodePolyline: (NSString*_Nullable) encodeStr;
- (void) googleApiGetListLocation: (CLLocationCoordinate2D) start
                            toEnd: (CLLocationCoordinate2D) end
                        completed: (void (^ _Nullable)(NSMutableArray*_Nullable, NSInteger))completed;

- (void) getDirection:(CLLocationCoordinate2D) start
                andAt:(CLLocationCoordinate2D) end
            completed:(void (^)(FCRouter*)) completed;

- (void) apiSearchPlace: (NSString*) textsearch
                 inMaps: (GMSMapView*) _mapview
                handler: (void (^)(NSMutableArray*)) block;

- (void) apiGetPlaceDetail: (NSString*) placeid
                  callback: (void (^)(FCPlace * fcPlace)) block;
@end
