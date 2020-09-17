//
//  FCBookingService+History.m
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService+History.h"
#import "FCBookingService+PushTrip.h"

@implementation FCBookingService (History)
#pragma mark - Trip History

/**
 * Trong trường hợp gọi api check finished trip không thành công thì save trip vào History để xư lý sau
 * Nếu save xong thì xoá Booking trong trip đi
 */

- (void) saveBookToHistory: (FCBooking*) booking {
    
    @try {
        [[self.refHistory child:booking.info.tripId] setValue:[self getBookingBody:booking] withCompletionBlock:^(NSError * error, FIRDatabaseReference * ref) {
            if (!error) {
                [self removeBooking:booking.info.tripId];
            }
        }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void) getListTripHistory: (void (^) (NSMutableArray* list)) callback {
    [FIRAnalytics logEventWithName:@"driver_load_trip_history"
                        parameters:@{}];
    @try {
        [self.refHistory observeSingleEventOfType:FIRDataEventTypeValue
                                    withBlock:^(FIRDataSnapshot * snapshot) {
                                        if (snapshot && snapshot.value) {
                                            NSMutableArray* list = [[NSMutableArray alloc] init];
                                            for (FIRDataSnapshot* s in snapshot.children) {
                                                if (s.value) {
                                                    [list addObject:s.value];
                                                }
                                            }
                                            [FIRAnalytics logEventWithName:@"driver_load_trip_history_success"
                                                                parameters:@{@"value": [list componentsJoinedByString:@","]}];
                                            callback(list);
                                        }
                                    }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
        [FIRAnalytics logEventWithName:@"driver_load_trip_history_fail"
                            parameters:@{@"reason": e.reason ?: @""}];
    }
}

- (void) removeTripHistory {
    [FIRAnalytics logEventWithName:@"driver_remove_trip_history"
                        parameters:@{}];
    @try {
        [self.refHistory removeValue];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
        [FIRAnalytics logEventWithName:@"driver_remove_trip_history_fail"
                            parameters:@{@"reason": e.reason ?: @""}];
    }
}
@end
