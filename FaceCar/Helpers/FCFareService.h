//
//  FCFareService.h
//  FaceCar
//
//  Created by facecar on 7/11/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCFareModifier.h"
#import "FCFarePredicate.h"
#import "FCFareManifest.h"
#import "FCBooking.h"


@interface FCFareService : NSObject

+ (FCFareService*) shareInstance;

- (void) getListFareManifest: (FCBooking*) trip
                   completed: (void (^)(NSMutableDictionary*)) block;

- (void) getListFareModifier: (FCBooking*) forTrip
                    complete: (void (^)(NSMutableDictionary*)) block;

- (void) getFareModifier: (FCBooking*) trip
                complete: (void (^)(FCFareModifier*)) block;
- (FCFareModifier*) getFareModifier: (FCBooking*) trip
                            service: (NSInteger) service
                       listModifier: (NSMutableArray*)listModifier
                      listPredicate: (NSMutableArray*)listPredicate
                          timestamp: (long long) timestamp;

+ (NSMutableArray*) getFareAddition: (NSInteger) originFare
                       additionFare: (NSInteger) additionalFare
                           modifier: (FCFareModifier*) fareModifier;

@end
