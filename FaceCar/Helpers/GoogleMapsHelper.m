//
//  GoogleMapsHelper.m
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "GoogleMapsHelper.h"
#import "FirebaseHelper.h"
#import "APIHelper.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@import GoogleMaps;

@interface GoogleMapsHelper() <CLLocationManagerDelegate, GMSMapViewDelegate>
{
    NSInteger lastTimeUpdateLocation;
    FirebaseHelper *firebase;
    NSTimer *currentTimer;
}

@property (strong, nonatomic, readonly) CLLocation *lastLocation;
@property (assign, nonatomic) CGFloat currentSpeed;
@property (assign, nonatomic) long long lastTimeUpdateLocationRapid;
@property (strong, nonatomic) CLLocation *lastLocationRapid;
@property (strong, nonatomic) CLLocation *originLocation;
@end

@implementation GoogleMapsHelper
static GoogleMapsHelper* instance = nil;
+ (GoogleMapsHelper*) shareInstance {
    if (instance == nil) {
        instance = [[GoogleMapsHelper alloc] init];
    }
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        [GMSServices provideAPIKey:GOOGLE_MAPS_KEY];
        [GMSPlacesClient provideAPIKey:GOOGLE_MAPS_KEY];
        
        firebase = [FirebaseHelper shareInstance];
        @weakify(self);
        [VatoLocationManager shared].locationChanged = ^(CLLocation * _Nullable location, NSError * _Nullable error) {
            @strongify(self);
            [self handlerLastLocation:location];
            
        };
    }
    return self;
}

- (void)startUpdateLocation
{
    _lastLocation = nil;
    _originLocation = nil;
    _lastTimeUpdateLocationRapid = [self getCurrentTimeStamp];
    _currentSpeed = 0.0f;
    
    lastTimeUpdateLocation = [self getCurrentTimeStamp];
    
    [[VatoLocationManager shared] startUpdatingLocation];
}

- (void)stopUpdateLocation
{
    [[VatoLocationManager shared] stopUpdatingLocation];
}

- (void) updateLocation
{
    [[VatoLocationManager shared] startUpdatingLocation];
}

- (void)getAddressOfLocation:(CLLocationCoordinate2D)location withCompletionBlock:(GMSReverseGeocodeCallback)block
{
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location completionHandler:block];
}

#pragma mark - Handle Loaction
- (void) handlerLastLocation: (CLLocation *)newLocation {
    if (!newLocation) return;

    if (_currentLocation == nil) {
        _currentLocation = newLocation;
    } else {
        CLLocationDistance distance = [newLocation distanceFromLocation:_currentLocation];
        if (distance >= 10) {
            _currentLocation = newLocation;
        }
    }

    [self handleRapidUpdateLocation];

    double timeStamp = [self getCurrentTimeStamp];

    if (_lastLocation != nil) {
        CLLocationDistance distanceInMeter = [newLocation distanceFromLocation:_lastLocation];
        NSInteger timeInSecond = (timeStamp - lastTimeUpdateLocation) * 1.0f / 1000;

        if (distanceInMeter > MIN_DISTANCE_UPDATE_LOCATION || timeInSecond > MIN_TIME_UPDATE_LOCATION)
        {
            [firebase setCurrentDriverLocation:newLocation];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_LOCATION object:newLocation];

            DLog(@"Current location : (%f , %f)", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
            DLog(@"Distance: %f", distanceInMeter)
            _lastLocation = newLocation;
            lastTimeUpdateLocation = timeStamp;
        }
    } else {
        [firebase setCurrentDriverLocation:newLocation];

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_LOCATION object:newLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_LOCATION_RAPIDLY object:newLocation
                                                          userInfo:@{@"distance" : [NSNumber numberWithFloat:0]}];
        _lastLocation = newLocation;
        _lastLocationRapid = newLocation;
        _originLocation = newLocation;
        lastTimeUpdateLocation = timeStamp;
    }

    if (firebase.currentDriverLocation.coordinate.latitude == 0) {
        [firebase setCurrentDriverLocation:newLocation];
    }
}


#pragma mark - CLLocationManagerDelegate
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    /* Condition validation: ignore event if there is nothing. */
    __autoreleasing CLLocation *newLocation = [locations lastObject];
    [self handlerLastLocation:newLocation];
}

- (void) handleRapidUpdateLocation
{
    if (_currentLocation == nil)
    {
        return;
    }
    
    CLLocation *location = _currentLocation;
    double timeStamp = [self getCurrentTimeStamp];
    
    if (_lastLocationRapid != nil)
    {
        CLLocationDistance distanceInMeter = [location distanceFromLocation:_lastLocationRapid];
        CGFloat timeInSecond = (timeStamp - _lastTimeUpdateLocationRapid) * 1.0f / 1000; //1.0f; //fixed 1 second
        CGFloat speed = distanceInMeter / timeInSecond;
        
//        DLog(@"Distance: %.1f, Time: %.1f, Speed: %.1f", distanceInMeter, timeInSecond, speed)
        
        
//        if (speed > DRIVER_MAX_SPEED)
//        {
////            DLog(@"Driver is running too fast, impossible!!!");
//            
//            return;
//        }
        
        _lastTimeUpdateLocationRapid = timeStamp;
        _lastLocationRapid = location;
        
        
        CGFloat dist = [location distanceFromLocation:_originLocation];
        if (dist > 30.0f)
        {
//            DLog(@"Notify update location: (%.1f, %.1f) - distance: %.1f", location.coordinate.latitude, location.coordinate.longitude, dist);
            
            _originLocation = location;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_LOCATION_RAPIDLY object:location
                                                              userInfo:@{@"distance" : [NSNumber numberWithFloat:dist]}];
            
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DLog(@"%@", error.localizedDescription);
}

+ (void)openMapWithStart:(CLLocationCoordinate2D) startCoordinate andEnd:(CLLocationCoordinate2D)endCoordinate
{
    if (![self isCoordinateValid:startCoordinate] || ![self isCoordinateValid:endCoordinate])
    {
        return;
    }
    
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]])
    {
        NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                         startCoordinate.latitude,
                                         startCoordinate.longitude,
                                         endCoordinate.latitude,
                                         endCoordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
    }
    else
    {
        NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",
                                   startCoordinate.latitude,
                                   startCoordinate.longitude,
                                   endCoordinate.latitude,
                                   endCoordinate.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: directionsURL]];
    }
}

+ (BOOL)isCoordinateValid:(CLLocationCoordinate2D)coordinate
{
    if (!CLLocationCoordinate2DIsValid(coordinate) || (coordinate.latitude == 0 && coordinate.longitude == 0))
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Polyline

- (NSString *)encodeStringWithCoordinates:(NSArray *)coordinates
{
    
    NSMutableString *encodedString = [NSMutableString string];
    int val = 0;
    int value = 0;
    CLLocationCoordinate2D prevCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    for (CLLocation *coordinateValue in coordinates) {
        CLLocationCoordinate2D coordinate = [coordinateValue coordinate];
        
        // Encode latitude
        val = round((coordinate.latitude - prevCoordinate.latitude) * 1e5);
        val = (val < 0) ? ~(val<<1) : (val <<1);
        while (val >= 0x20) {
            int value = (0x20|(val & 31)) + 63;
            [encodedString appendFormat:@"%c", value];
            val >>= 5;
        }
        [encodedString appendFormat:@"%c", val + 63];
        
        // Encode longitude
        val = round((coordinate.longitude - prevCoordinate.longitude) * 1e5);
        val = (val < 0) ? ~(val<<1) : (val <<1);
        while (val >= 0x20) {
            value = (0x20|(val & 31)) + 63;
            [encodedString appendFormat:@"%c", value];
            val >>= 5;
        }
        [encodedString appendFormat:@"%c", val + 63];
        
        prevCoordinate = coordinate;
    }
    
    return encodedString;
}

- (NSMutableArray*) decodePolyline: (NSString*) encodeStr {
    GMSPath *path =[GMSPath pathFromEncodedPath:encodeStr];
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (int i = 0; i < path.count; i ++) {
        CLLocationCoordinate2D cor = [path coordinateAtIndex:i];
        CLLocation* lo = [[CLLocation alloc] initWithLatitude:cor.latitude longitude:cor.longitude];
        [list addObject:lo];
    }
    
    return list;
}

- (void) googleApiGetListLocation: (CLLocationCoordinate2D) start
                            toEnd: (CLLocationCoordinate2D) end
                        completed: (void (^ _Nullable)(NSMutableArray*, NSInteger))completed {
    [self getDirection:start
                 andAt:end
             completed:^(FCRouter * router) {
                 if (router) {
                     completed([self decodePolyline:router.polylineEncode], router.distance);
                 }
             }];
}

#pragma mark - API Direction

- (void) getDirection:(CLLocationCoordinate2D) start
                andAt:(CLLocationCoordinate2D) end
            completed:(void (^)(FCRouter*)) completed {
    completed(nil);

//    NSString *tripId = [FCBookingService shareInstance].book.info.tripId ?: @"";
//    NSDictionary *parameters = @{@"origin": [NSString stringWithFormat:@"%f,%f", start.latitude, start.longitude],
//                                 @"destination": [NSString stringWithFormat:@"%f,%f", end.latitude, end.longitude],
//                                 @"transport": @"car"};
//
//    [[APIHelper shareInstance] get:GOOGLE_API_DIRECTION params:parameters complete:^(FCResponse *response, NSError *e) {
//        if ([response.data isKindOfClass:[NSDictionary class]]) {
//            NSDictionary* data = response.data;
//            double distance = [[data valueForKey:@"distance"] doubleValue];
//            double duration = [[data valueForKey:@"duration"] doubleValue];
//            NSString* polyline = [data valueForKey:@"overviewPolyline"];
//
//            FCRouter* router = [[FCRouter alloc] init];
//            router.duration = duration;
//            router.distance = distance;
//            router.durationText = [NSString stringWithFormat:@"%d phút", (int) (duration/60)];
//            router.polylineEncode = polyline;
//            [FIRAnalytics logEventWithName:@"driver_ios_request_direction_success" parameters:@{@"response": data ?: @{}, @"tripId": tripId}];
//            completed(router);
//        } else {
//            [FIRAnalytics logEventWithName:@"driver_ios_request_direction_fail" parameters:@{@"params": parameters ?: @{}, @"reason": e.localizedFailureReason ?: @"", @"tripId": tripId}];
//        }
//    }];
    
    /*[[FirebaseHelper shareInstance] getGoogleMapKeys:^(NSString * key) {
        NSDictionary *parameters = @{@"key": key,
                                     @"mode": @"driving",
                                     @"origin": [NSString stringWithFormat:@"%f, %f", start.latitude, start.longitude],
                                     @"destination": [NSString stringWithFormat:@"%f, %f", end.latitude, end.longitude]};
        
        DLog(@"Params: %@", parameters);
        [[APIHelper shareInstance] call:GOOGLE_API_DIRECTION
                                 method:METHOD_GET
                                 params:parameters
                                  token:nil
                         headerTokenKey:nil
                                handler:^(NSError *error, id responseObject) {
                                   @try {
                                       if (error) {
                                           [[FirebaseHelper shareInstance] resetMapKeys];
                                       }
                                       else if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject valueForKey:@"error_message"] == nil) {
                                           FCRouter* router = [[FCRouter alloc] init:responseObject];
                                           if (router.polylineEncode.length > 0) {
                                               completed(router);
                                           }
                                       }
                                       else {
                                           [[FirebaseHelper shareInstance] resetMapKeys];
                                       }
                                   }
                                   @catch (NSException* e) {
                                       [[FirebaseHelper shareInstance] resetMapKeys];
                                   }
                               }];
    }];
     */
}


#pragma mark - API Places

- (void) apiSearchPlace: (NSString*) textsearch
                 inMaps: (GMSMapView*) _mapview
                handler: (void (^)(NSMutableArray*)) block {
    
    NSDictionary *parameters = @{@"query": textsearch,
                                 @"lat": @(_mapview.camera.target.latitude),
                                 @"lon": @(_mapview.camera.target.longitude)};
    
    [[APIHelper shareInstance] get:GOOGLE_API_PLACE params:parameters complete:^(FCResponse *response, NSError *e) {
        if (response.data) {
            
            NSMutableArray* list = [[NSMutableArray alloc] init];
            for (NSDictionary* dict in response.data) {
                FCPlace* place = [[FCPlace alloc] initWithDictionary:dict error:nil];
                if (place) {
                    [list addObject:place];
                }
            }
            
            block(list);
        }
        else {
            block(nil);
        }
    }];
    
    /*
    [[FirebaseHelper shareInstance] getGoogleMapKeys:^(NSString * key) {
        @try {
            NSString *input = [textsearch stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSString* host = GOOGLE_API_PLACE;
            NSString* url = [NSString stringWithFormat:@"%@?strictbounds&components=country:vn&language=vi&input=%@&key=%@&location=%f,%f&radius=%d", host, input, key, _mapview.camera.target.latitude, _mapview.camera.target.longitude, 500000]; // 500 km
            
            
            [[APIHelper shareInstance] call:url
                                     method:METHOD_GET
                                     params:nil
                                      token:nil
                             headerTokenKey:nil
                                    handler:^(NSError *error, id response) {
                                        if (error) {
                                            [[FirebaseHelper shareInstance] resetMapKeys];
                                        }
                                        else if ([response isKindOfClass:[NSDictionary class]]) {
                                            @try {
                                                NSString* status = [response objectForKey:@"status"];
                                                if ([status isEqualToString:@"OK"]) {
                                                    NSArray* data = [response objectForKey:@"predictions"];
                                                    NSMutableArray* list = [[NSMutableArray alloc] init];
                                                    for (NSDictionary* dict in data) {
                                                        NSError* err;
                                                        FCGGPlace* place = [[FCGGPlace alloc] initWithDictionary:dict
                                                                                                           error:&err];
                                                        if (place && place.name.length > 0) {
                                                            [list addObject:place];
                                                        }
                                                    }
                                                    
                                                    if (block) {
                                                        block(list);
                                                    }
                                                }
                                                else {
                                                    [[FirebaseHelper shareInstance] resetMapKeys];
                                                }
                                            }
                                            @catch (NSException* e) {
                                                DLog(@"Error: %@", e);
                                                [[FirebaseHelper shareInstance] resetMapKeys];
                                            }
                                        }
                                        else {
                                            [[FirebaseHelper shareInstance] resetMapKeys];
                                        }
                                    }];
        }
        @catch(NSException* e) {
            DLog(@"error: %@", e);
        }
    }];
    */
}

#pragma mark - API Place Detail

- (void) apiGetPlaceDetail: (NSString*) placeid
                  callback: (void (^)(FCPlace * fcPlace)) block {
    
    NSDictionary *parameters = @{@"placeid": placeid};
    [[APIHelper shareInstance] get:GOOGLE_API_PLACE_DETAIL params:parameters complete:^(FCResponse *response, NSError *e) {
        if (response.data) {
            FCPlace* place = [[FCPlace alloc] initWithDictionary:response.data error:nil];
            block(place);
        }
        else {
            block(nil);
        }
    }];
    
    /*[[FirebaseHelper shareInstance] getGoogleMapKeys:^(NSString * key) {
        @try {
            NSDictionary *parameters = @{@"key": key,
                                         @"placeid": placeid};
            
            [[APIHelper shareInstance] call:GOOGLE_API_PLACE_DETAIL
                                     method:METHOD_GET
                                     params:parameters
                                      token:nil
                             headerTokenKey:nil
                                    handler:^(NSError *error, id response) {
                                        if (error) {
                                            [[FirebaseHelper shareInstance] resetMapKeys];
                                        }
                                        else if ([response isKindOfClass:[NSDictionary class]]) {
                                            @try {
                                                NSDictionary* reslut = [response objectForKey:@"result"];
                                                FCPlace* place = [[FCPlace alloc] init];
                                                
                                                // get address
                                                if ([reslut objectForKey:@"formatted_address"]) {
                                                    NSString* address = [reslut objectForKey:@"formatted_address"];
                                                    place.address = address;
                                                    place.name = address;
                                                }
                                                
                                                // location
                                                id loDict = [[reslut objectForKey:@"geometry"] objectForKey:@"location"];
                                                if ([loDict isKindOfClass:[NSDictionary class]]) {
                                                    FCLocation* location = [[FCLocation alloc] init];
                                                    location.lat = [[loDict objectForKey:@"lat"] doubleValue];
                                                    location.lon = [[loDict objectForKey:@"lng"] doubleValue];
                                                    place.location = location;
                                                    
                                                    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.lat, location.lon);
                                                    [[FirebaseHelper shareInstance] getZoneByLocation:coordinate
                                                                                              handler:^(FCZone * zone) {
                                                                                                  place.zoneId = zone.id;
                                                                                                  block (place);
                                                                                              }];
                                                }
                                                else {
                                                    place.zoneId = ZONE_VN;
                                                    block (place);
                                                }
                                            }
                                            @catch (NSException* e) {
                                                [[FirebaseHelper shareInstance] resetMapKeys];
                                            }
                                        }
                                        else {
                                            [[FirebaseHelper shareInstance] resetMapKeys];
                                        }
                                    }];
        }
        @catch(NSException* e) {
            DLog(@"error: %@", e);
        }
    }];*/
}


@end
