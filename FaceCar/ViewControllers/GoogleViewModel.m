//
//  GoogleViewModel.m
//  FaceCar
//
//  Created by facecar on 5/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "GoogleViewModel.h"
#import "FCPlaceHistory.h"
#import "GoogleMapsHelper.h"

@implementation GoogleViewModel {
    FCGGMapView* _mapview;
    long long _lastimeRequest;
    NSTimer* _requestTimeout;
    NSString* _currentTextSearching;
    NSError* _googlePlaceError;
}

- (id) init:(FCGGMapView*) mapview {
    self = [super init];
    if (self) {
        _mapview = mapview;
        _lastimeRequest = [self getCurrentTimeStamp];
        self.listHistory = [[NSMutableArray alloc] init];
        self.filter = [[GMSAutocompleteFilter alloc] init];
        self.filter.country = @"VN";
        [self getHistoryPlace];
    }
    
    return self;
}

- (void) onTimeoutWaiting {
    DLog(@"Request timeout .....");
    
    [self queryPlace:_currentTextSearching];
}

- (void) queryPlace: (NSString*) searchText {
    if (searchText.length == 0) {
        self.listPlace = nil;
        [self getHistoryPlace];
        return;
    }
    _currentTextSearching = searchText;
    long long currentTime = [self getCurrentTimeStamp];
    long long duration = currentTime - _lastimeRequest;
    if (duration < 1500) {
        
        if (_requestTimeout) {
            [_requestTimeout invalidate];
        }
        _requestTimeout = [NSTimer scheduledTimerWithTimeInterval:1.5f
                                                           target:self
                                                         selector:@selector(onTimeoutWaiting)
                                                         userInfo:nil
                                                          repeats:NO];
        return;
    }
    if (_requestTimeout) {
        [_requestTimeout invalidate];
    }
    _lastimeRequest = currentTime;
    
    [self queryPlaceByAPIService:searchText];
    
    // if Google API SDK for mobile error
    // then call API service
    //    if (_googlePlaceError) {
    //        [self queryPlaceByAPIService:searchText];
    //    }
    //    else {
    //        [self queryPlaceBySDK:searchText];
    //    }
}

- (void) queryPlaceBySDK: (NSString*) searchText {
    GMSCoordinateBounds* bounds = [[GMSCoordinateBounds alloc] initWithRegion:_mapview.projection.visibleRegion];
    GMSPlacesClient* client = [GMSPlacesClient sharedClient];
    [client autocompleteQuery:searchText
                       bounds:bounds
                       filter:self.filter
                     callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
                         if (error) {
                             _googlePlaceError = error;
                         }
                         else {
                             self.listPlace = results;
                             if (self.listPlace.count > 0) {
                                 [self.listHistory removeAllObjects];
                             }
                             else {
                                 [self getHistoryPlace];
                             }
                         }
                     }];
}

- (void) didSelectedPlace:(NSIndexPath*) indexpath {
    if (self.listPlace.count > indexpath.row) {
        [self didSelectPlace:indexpath];
    }
    else if (self.listHistory.count > indexpath.row) {
        [self didSelectHistory:indexpath];
    }
}

- (void) didSelectPlace:(NSIndexPath*) indexpath {
    
    id data = [self.listPlace objectAtIndex:indexpath.row];
    NSString* placeId = @"";
    NSString* placeName = @"";
    if ([data isKindOfClass:[FCPlace class]]) {
        if (((FCPlace*)data).location) {
            self.place = data;
            [self saveHistory:data];
            return;
        }
        
        placeId = ((FCPlace*)data).placeId;
        placeName = ((FCPlace*)data).name;
    }
    
    if (placeId.length == 0) {
        return;
    }
    
    [self getPlaceDetail:placeId
                callback:^(FCPlace* place) {
                    if (placeName.length > 0) {
                        place.name = placeName;
                    }
                    self.place = place;
                }];
    
    [self saveHistory:data];
}

- (void) didSelectHistory:(NSIndexPath*) indexpath {
    FCPlaceHistory* his = [self.listHistory objectAtIndex:indexpath.row];
    if (his.location) {
        FCPlace* place = [[FCPlace alloc] init];
        place.name = his.name;
        place.address = his.address;
        place.location = his.location;
        place.zoneId = his.zoneId;
        self.place = place;
        
        [self saveHistory:place];
    }
    else {
        [self getPlaceDetail:his.placeId
                    callback:^(FCPlace* place) {
                        if (his.name.length > 0) {
                            place.name = his.name;
                        }
                        self.place = place;
                        [self saveHistory:place];
                    }];
    }
}

- (void) saveHistory:(id) data {
    FCPlaceHistory* his = [[FCPlaceHistory alloc] init];
    if ([data isKindOfClass:[GMSAutocompletePrediction class]]) {
        his.placeId = ((GMSAutocompletePrediction*)data).placeID;
        his.name = ((GMSAutocompletePrediction*)data).attributedPrimaryText.string;
        his.address = ((GMSAutocompletePrediction*)data).attributedSecondaryText.string;
    }
    else if ([data isKindOfClass:[FCGGPlace class]]) {
        his.placeId = ((FCGGPlace*)data).place_id;
        his.name = ((FCGGPlace*)data).name;
        his.address = ((FCGGPlace*)data).address;
    }
    else if ([data isKindOfClass:[FCPlace class]]) {
        his.name = ((FCPlace*)data).name;
        his.address = ((FCPlace*)data).address;
        his.location = ((FCPlace*)data).location;
        his.zoneId = ((FCPlace*)data).zoneId;
        his.placeId = ((FCPlace*)data).placeId;
    }
    
    FIRDatabaseReference* ref = [[[FIRDatabase database].reference child:TABLE_PLACE_HIS] child:[FIRAuth auth].currentUser.uid];
    [ref keepSynced:YES];
    
    // check exist place then remove first
    {
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                for (FIRDataSnapshot* snap in snapshot.children) {
                    @try {
                        FCPlaceHistory* place = [[FCPlaceHistory alloc] initWithDictionary:snap.value error:nil];
                        if (place.placeId.length > 0 && [place.placeId isEqualToString:his.placeId]) {
                            [snap.ref removeValue];
                        }
                        else if ([place.name isEqualToString:his.name]) {
                            [snap.ref removeValue];
                        }
                    }
                    @catch(NSException* e) {
                        
                    }
                }
            }
            
            // add new place to history
            {
                NSString* key = ref.childByAutoId.key;
                NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[his toDictionary]];
                [dict addEntriesFromDictionary:@{@"timestamp": [FIRServerValue timestamp]}];
                [[ref child:key] setValue:dict];
            }
        }];
    }
}

- (void) getHistoryPlace {
    @try {
        FIRDatabaseQuery* ref = [[[[FIRDatabase database].reference
                                   child:TABLE_PLACE_HIS]
                                  child:[FIRAuth auth].currentUser.uid]
                                 queryLimitedToLast:5];
        [ref keepSynced:TRUE];
        [ref observeSingleEventOfType:FIRDataEventTypeValue
       andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot * _Nonnull snapshot, NSString * _Nullable prevKey) {
           
           [self.listHistory removeAllObjects];
           NSMutableArray* list = [[NSMutableArray alloc] init];
           for (FIRDataSnapshot* s in snapshot.children) {
               NSError* err;
               FCPlaceHistory* his = [[FCPlaceHistory alloc] initWithDictionary:s.value error:&err];
               if (his) {
                   [list insertObject:his atIndex:0];
               }
           }
           
           self.listHistory = list;
           
           // clear place list
           if (self.listHistory.count > 0) {
               self.listPlace = nil;
           }
       }
                      withCancelBlock:^(NSError * _Nonnull error) {
                          
                      }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

#pragma mark - API Google service
- (void) queryPlaceByAPIService: (NSString*) textsearch {
    [[GoogleMapsHelper shareInstance] apiSearchPlace:textsearch
                                              inMaps:_mapview
                                             handler:^(NSMutableArray * list) {
                                                 // callback
                                                 self.listPlace = list;
                                                 if (self.listPlace.count > 0) {
                                                     [self.listHistory removeAllObjects];
                                                 }
                                             }];
}

- (void) getPlaceDetail: (NSString*) placeId
               callback: (void (^)(FCPlace * fcPlace)) block {
    [[GoogleMapsHelper shareInstance] apiGetPlaceDetail:placeId
                                               callback:^(FCPlace *fcPlace) {
                                                   if (block) {
                                                       block(fcPlace);
                                                   }
                                               }];
}

@end
