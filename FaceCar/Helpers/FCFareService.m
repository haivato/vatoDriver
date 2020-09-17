//
//  FCFareService.m
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCFareService.h"
#import "DateTimeUtils.h"
#import "VehicleServiceUtil.h"
#import "LocationUtil.h"

@implementation FCFareService {
    FIRDatabaseReference* _ref;
    NSMutableArray* _listFareManifest;
    NSMutableArray* _listFarePredicate;
    NSMutableArray* _listFareModifier;
}

static FCFareService* instance = nil;
+ (FCFareService*) shareInstance {
    if (instance == nil) {
        instance = [[FCFareService alloc] init];
    }
    
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        _ref = [FIRDatabase database].reference;
        _listFareManifest = [[NSMutableArray alloc] init];
        _listFareModifier = [[NSMutableArray alloc] init];
        _listFarePredicate = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) getListMasterFarePredicate: (void (^)(NSMutableArray*)) block {
    if (_listFarePredicate.count > 0) {
        block(_listFarePredicate);
        return;
    }
    
    @try {
        FIRDatabaseReference* ref = [[_ref child:TABLE_MASTER] child:TABLE_FARE_PREDICATE];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot * snapshot) {
                        if (snapshot && ![snapshot.value isKindOfClass:[NSNull class]]) {
                            if (_listFarePredicate) {
                                [_listFarePredicate removeAllObjects];
                            }
                            else {
                                _listFarePredicate = [[NSMutableArray alloc] init];
                            }
                            
                            for (FIRDataSnapshot* snap in snapshot.children) {
                                @try {
                                    FCFarePredicate* pre = [[FCFarePredicate alloc] initWithDictionary:snap.value
                                                                                                 error:nil];
                                    if (pre) {
                                        [_listFarePredicate addObject:pre];
                                    }
                                }
                                @catch (NSException* e) {
                                    DLog(@"Error: %@", e)
                                }
                            }
                            
                            if (block) {
                                block(_listFarePredicate);
                            }
                        }
                    }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void) getListMasterFareModifier: (void (^)(NSMutableArray*)) block {
    if (_listFareModifier.count > 0) {
        block(_listFareModifier);
        return;
    }
    
    @try {
        FIRDatabaseReference* ref = [[_ref child:TABLE_MASTER] child:TABLE_FARE_MODIFIER];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot * snapshot) {
                        if (snapshot && ![snapshot.value isKindOfClass:[NSNull class]]) {
                            if (_listFareModifier) {
                                [_listFareModifier removeAllObjects];
                            }
                            else {
                                _listFareModifier = [[NSMutableArray alloc] init];
                            }
                            
                            for (FIRDataSnapshot* snap in snapshot.children) {
                                @try {
                                    FCFareModifier* pre = [[FCFareModifier alloc] initWithDictionary:snap.value
                                                                                               error:nil];
                                    if (pre) {
                                        [_listFareModifier addObject:pre];
                                    }
                                }
                                @catch (NSException* e) {
                                    DLog(@"Error: %@", e)
                                }
                            }
                            
                            if (block) {
                                block(_listFareModifier);
                            }
                        }
                    }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

#pragma mark -

- (void) getListMasterFareMannifest: (void (^)(NSMutableArray*)) block {
    if (_listFareManifest.count > 0) {
        block(_listFareManifest);
        return;
    }
    
    @try {
        FIRDatabaseReference* ref = [[_ref child:TABLE_MASTER] child:TABLE_FARE_MANIFEST];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot * snapshot) {
                        if (snapshot && ![snapshot.value isKindOfClass:[NSNull class]]) {
                            if (_listFareManifest) {
                                [_listFareManifest removeAllObjects];
                            }
                            else {
                                _listFareManifest = [[NSMutableArray alloc] init];
                            }
                            
                            for (FIRDataSnapshot* snap in snapshot.children) {
                                @try {
                                    FCFareManifest* pre = [[FCFareManifest alloc] initWithDictionary:snap.value
                                                                                               error:nil];
                                    if (pre) {
                                        [_listFareManifest addObject:pre];
                                    }
                                }
                                @catch (NSException* e) {
                                    DLog(@"Error: %@", e)
                                }
                            }
                            
                            if (block) {
                                block(_listFareManifest);
                            }
                        }
                    }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void) getListFareManifest: (FCBooking*) trip
                   completed: (void (^)(NSMutableDictionary*)) block {
    [[FirebaseHelper shareInstance] getServerTime:^(NSTimeInterval timestamp) {
        [self getListFarePredicateOptional:trip timestamp:timestamp completed:^(NSMutableDictionary* predicates) {
            if (predicates.count > 0) {
                [self getListMasterFareMannifest:^(NSMutableArray * manifests) {
                    if (manifests.count > 0) {
                        NSMutableDictionary* listManifest = [[NSMutableDictionary alloc] init];
                        for (FCFarePredicate* pre in predicates.allValues) {
                            for (FCFareManifest* m in manifests) {
                                if (pre.manifestId == m.id) {
                                    [listManifest setObject:m forKey:@(m.id)];
                                    break;
                                }
                            }
                        }
                        
                        block(listManifest);
                    }
                    else {
                        block (nil);
                    }
                }];
            }
            else {
                block (nil);
            }
        }];
    }];
}

#pragma mark -

- (void) getListFarePredicateOptional: (FCBooking*) trip
                            timestamp: (long long) timestamp
                            completed: (void (^)(NSMutableDictionary*)) block {
    [self getListMasterFarePredicate:^(NSMutableArray * listFarePredicate) {
        NSArray* services = @[@1, @2, @4, @8, @16];
        NSMutableDictionary* listFarePredicateOptional = [[NSMutableDictionary alloc] init];
        for (NSNumber* service in services) {
            // type fixed trip
            {
                FCFarePredicate* farePredicate = [self getFarePredicateOptional:trip service:[service integerValue] tripType: BookTypeFixed listPredicate:listFarePredicate timestamp:timestamp];
                if (farePredicate) {
                    [listFarePredicateOptional setObject:farePredicate forKey:@(farePredicate.id)];
                }
            }
            
            // type onetouch trip
            {
                FCFarePredicate* farePredicate = [self getFarePredicateOptional:trip service:[service integerValue] tripType: BookTypeOneTouch listPredicate:listFarePredicate timestamp:timestamp];
                if (farePredicate) {
                    [listFarePredicateOptional setObject:farePredicate forKey:@(farePredicate.id)];
                }
            }
        }
        
        if (block) {
            block(listFarePredicateOptional);
        }
    }];
}


- (FCFarePredicate*) getFarePredicateOptional: (FCBooking*) trip
                                      service: (NSInteger) service
                                     tripType: (NSInteger) tripType
                                listPredicate: (NSMutableArray*)listPredicate
                                    timestamp: (long long) timestamp {
    
    NSArray* listFarePredicateOptional = [listPredicate filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL( FCFarePredicate* f, NSDictionary<NSString *,id> * _Nullable bindings) {
        // Trip type
        if (tripType == BookTypeDigital) {
            return NO;
        }
        
        if (f.tripType != 0 && f.tripType != tripType) {
            return NO;
        }
        
        // Active predicate
        if (!f.active) {
            return NO;
        }
        
        // Price
        NSInteger totalPrice = trip.info.price + trip.info.additionPrice;
        if (totalPrice > 0 && (totalPrice > f.fareMax || totalPrice < f.fareMin)) {
            return NO;
        }
        
        // Date
        long long startDate = [DateTimeUtils atStartOfDayTimestamp:f.startDate/1000];
        long long endDate = [DateTimeUtils atEndOfDayTimestamp:f.endDate/1000];
        if (startDate > timestamp || endDate < timestamp) {
            return NO;
        }
        
        // Time
        float hour = [DateTimeUtils getHour:timestamp];
        if (f.startTime > hour || f.endTime < hour) {
            return NO;
        }
        
        // Service
        NSArray* services = [VehicleServiceUtil splitService:f.service];
        if (![services containsObject:@(service)]) {
            return NO;
        }
        
        // Start location
        if (![LocationUtil inDistance:f.startDistance
                              fromLat:trip.info.startLat
                              fromLon:trip.info.startLon
                                toLat:f.startLat
                                toLon:f.startLon]) {
            return NO;
        }
        
        // End location
        if (![LocationUtil inDistance:f.endDistance
                              fromLat:trip.info.endLat
                              fromLon:trip.info.endLon
                                toLat:f.endLat
                                toLon:f.endLon]) {
            return NO;
        }
        
        return TRUE;
    }]];
    
    if (listFarePredicateOptional.count > 0) {
        FCFarePredicate* farePredicate = [[listFarePredicateOptional sortedArrayUsingComparator:^NSComparisonResult(FCFarePredicate*  obj1, FCFarePredicate* obj2) {
            return obj1.priority < obj2.priority;
        }] firstObject];
        
        return farePredicate;
    }
    
    return nil;
}

#pragma mark -

- (void) getListFareModifier: (FCBooking*) forTrip
                    complete: (void (^)(NSMutableDictionary*)) block {
    @try {
        [[FirebaseHelper shareInstance] getServerTime:^(NSTimeInterval timestamp) {
            [self getListMasterFarePredicate:^(NSMutableArray * listPredicate) {
                [self getListMasterFareModifier:^(NSMutableArray * listModifier) {
                    NSArray* services = @[@1, @2, @4, @8, @16];
                    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                    for (NSNumber* service in services) {
                        FCFareModifier* modifier = [self getFareModifier:forTrip
                                                                 service:[service integerValue]
                                                            listModifier:listModifier
                                                           listPredicate:listPredicate
                                                               timestamp:timestamp];
                        if (modifier) {
                            [dict setObject:modifier forKey:service];
                        }
                    }
                    
                    if (block) {
                        block(dict);
                    }
                }];
            }];
        }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void) getFareModifier: (FCBooking*) trip
                complete: (void (^)(FCFareModifier*)) block {
    @try {
        [[FirebaseHelper shareInstance] getServerTime:^(NSTimeInterval timestamp) {
            [self getListMasterFarePredicate:^(NSMutableArray * listPredicate) {
                [self getListMasterFareModifier:^(NSMutableArray * listModifier) {
                    block ([self getFareModifier:trip
                                         service:trip.info.serviceId
                                    listModifier:listModifier
                                   listPredicate:listPredicate
                                       timestamp:timestamp]);
                }];
            }];
        }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (FCFareModifier*) getFareModifier: (FCBooking*) trip
                            service: (NSInteger) service
                       listModifier: (NSMutableArray*)listModifier
                      listPredicate: (NSMutableArray*)listPredicate
                          timestamp: (long long) timestamp {
    
    FCFarePredicate* farePredicate = [self getFarePredicateOptional:trip
                                                            service:service
                                                           tripType:trip.info.tripType
                                                      listPredicate:listPredicate
                                                          timestamp:timestamp];
    
    NSArray* fareModifierOptional = [listModifier filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FCFareModifier* f, NSDictionary<NSString *,id> * _Nullable bindings) {
        return f.id == farePredicate.modifierId && farePredicate.active;
    }]];
    
    return [fareModifierOptional firstObject];
}

#pragma mark -
+ (NSMutableArray*) getFareAddition: (NSInteger) originFare additionFare: (NSInteger) additionalFare modifier: (FCFareModifier*) fareModifier {
    if (!fareModifier)
        return [NSMutableArray arrayWithArray:@[@(originFare), @0, @0]];
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    NSInteger newFare = originFare*1.0f;
    
    // Addition fare
    if (fareModifier.additionRatio > 0.0 || fareModifier.additionAmount > 0.0) {
        double addFare = newFare * fareModifier.additionRatio + fareModifier.additionAmount;
        if (addFare > fareModifier.additionMax) addFare = fareModifier.additionMax;
        if (addFare < fareModifier.additionMin) addFare = fareModifier.additionMin;
        newFare = newFare + addFare;
    }
    
    newFare = newFare + additionalFare;
    newFare = (NSInteger)(newFare/1000) * 1000;
    [result addObject:@(newFare)];
    
    
    // Driver support
    NSInteger driverAmount = 0;
    if (newFare <= fareModifier.driverActiveAmount) {
        driverAmount = fareModifier.driverActiveAmount - newFare;
        if (driverAmount > fareModifier.driverMax) driverAmount = fareModifier.driverMax;
        if (driverAmount < fareModifier.driverMin) driverAmount = fareModifier.driverMin;
    } else {
        if (fareModifier.driverRatio > 0.0) {
            driverAmount = newFare * fareModifier.driverRatio;
            if (driverAmount > fareModifier.driverMax) driverAmount = fareModifier.driverMax;
            if (driverAmount < fareModifier.driverMin) driverAmount = fareModifier.driverMin;
        }
    }
    
    driverAmount = (NSInteger)(driverAmount/1000) * 1000;
    [result addObject:@(driverAmount)];
    
    // Client support
    NSInteger clientAmount = 0;
    if (fareModifier.clientRatio > 0.0 || fareModifier.clientDelta > 0.0) {
        clientAmount = newFare * fareModifier.clientRatio + fareModifier.clientDelta;
        if (clientAmount < fareModifier.clientMin) clientAmount = fareModifier.clientMin;
        if (clientAmount > fareModifier.clientMax) clientAmount = fareModifier.clientMax;
    }
    clientAmount = (NSInteger)(clientAmount/1000) * 1000;
    [result addObject:@(clientAmount)];
    
    return result;
}

@end
