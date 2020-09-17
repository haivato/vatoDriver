//
//  FCBookingService+PushTrip.m
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService+PushTrip.h"
#import "FCBookingService+Verify.h"
#import "FCBookingService+BookStatus.h"
#import "GoogleMapsHelper.h"
#import "FCBookingService+History.h"
@import FirebaseAnalytics;
@implementation FCBookingService (PushTrip)
- (void)extracted:(FCBooking *)book {
    [book.info updateInfo:book.tracking estimate:book.estimate andLocation:[GoogleMapsHelper shareInstance].currentLocation];
}

- (NSDictionary*) getBookingBody: (FCBooking*) book {
    if (![book validEstimate]) {
        NSDictionary *estimateJson = [self getEstimateBackup];
        FCBookEstimate *estimate = [[FCBookEstimate alloc] initWithDictionary:estimateJson
                                                                  error:nil];
        if (estimate != nil) {
            self.book.estimate = estimate;
        }
    }
    
    book.info.vehicleId = [UserDataHelper shareInstance].getCurrentUser.vehicle.id;
    [self extracted:book];
    
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:[book toDictionary]];
    [body removeObjectForKey:@"extra"];
    NSDictionary* status = [self getTripStatusDict:book];
    NSDictionary* statusDetail = [self getTripStatusDetailDict:book];
    DLog(@"Status Detail: %@",[statusDetail description]);
    if (status) {
        [body addEntriesFromDictionary:status];
    }
    if (statusDetail) {
        [body addEntriesFromDictionary:statusDetail];
    }
    
    if ([self isTripCompleted:book] || [self isFinishedTrip:book]) {
        NSDictionary* evalute = [self getTripEvalution: book];
        if (evalute) {
            [body addEntriesFromDictionary:evalute];
        }
    }
    return body;
}


/*
 * Kiểm tra với backend chuyến đi đã được kết nối
 */
- (void) apiCheckConnected: (FCBooking*) book {
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:[self getBookingBody:book]];
    [body addEntriesFromDictionary:[self getTripStatusDict: book]];
    [[APIHelper shareInstance] post:API_TRIP_PUSH
                               body:body
                           complete:^(FCResponse *response, NSError *e) {
                           }];
}

- (void) apiCheckFinished:(FCBooking*) book {
    NSDictionary *params = [self getBookingBody:book];
    @try {
        [FIRAnalytics logEventWithName:@"driver_remove_current_trip"
                            parameters:@{}];
        // remove driver current trip note
        [self.refDriverCurrentTrip removeValue];
    }
    @catch (NSException* e) {
        [FIRAnalytics logEventWithName:@"driver_remove_current_trip_fail"
                            parameters:@{@"reason": e.reason ?: @""}];
        DLog(@"Error: %@", e)
    }
    NSString *tripId = book.info.tripId ?: @"";
    [FIRAnalytics logEventWithName:@"driver_push_trip"
                        parameters:@{@"tripId": tripId}];
    [[APIHelper shareInstance] post:API_TRIP_PUSH
                               body:params
                           complete:^(FCResponse *response, NSError *e) {
                               if (response.status == APIStatusOK) {
                                   [FIRAnalytics logEventWithName:@"driver_push_trip_success"
                                                       parameters:@{@"tripId": tripId}];
                                   [self removeBooking: book.info.tripId];
                               }
                               else {
                                   NSString *reason = e.localizedDescription ?: @"";
                                   NSInteger status = response.status;
                                   [FIRAnalytics logEventWithName:@"driver_push_trip_fail"
                                                       parameters:@{@"tripId": tripId,
                                                                    @"api": API_TRIP_PUSH,
                                                                    @"reason": reason,
                                                                    @"status": @(status)}];
                                   [self saveBookToHistory:book];
                               }
                           }];
}


@end
