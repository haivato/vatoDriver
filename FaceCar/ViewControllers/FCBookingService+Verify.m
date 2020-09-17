//
//  FCBookingService+Verify.m
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService+Verify.h"
#import "GoogleMapsHelper.h"
#import "FCBookingService+BookStatus.h"

@implementation FCBookingService (Verify)
#pragma mark - Backend verify
- (NSDictionary*) getTripStatusDict: (FCBooking*) book {
    if ([self isTripCompleted: book]) {
        return @{@"status":@(TripStatusCompleted)};
    }
    else if ([self isClientCanceled: book]) {
        return @{@"status":@(TripStatusClientCanceled)};
    }
    else if ([self isDriverCanceled: book]) {
        return @{@"status":@(TripStatusDriverCanceled)};
    }
    else if ([self isAdminCanceled: book]) {
        return @{@"status":@(TripStatusAdminCanceled)};
    }
    else if ([self isTripStarted: book] || [self isInTrip: book]) {
        return @{@"status":@(TripStatusStarted)};
    }
    
    return nil;
}

- (NSDictionary*) getTripStatusDetailDict: (FCBooking*) book {
    if (!book) { return  @{}; }
    FCBookCommand *last = [book last];
    if (!last) { return  @{}; }
    return @{ @"statusDetail": @(last.status) };
}

/**
 Đánh giá chuyến đi có nghi ngờ không chính xác hay không
 
 @return Kết quả là giá trị @TripEvaluate value
 */
- (NSDictionary*) getTripEvalution: (FCBooking*) book {
    FCBookInfo* info = book.info;
    FCBookingRule* rule = [FirebaseHelper shareInstance].appConfigure.booking_rule_checking;
    if (rule && info) {
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        // kiểm tra book cùng từ 1 tài khoản
        if (info.clientUserId == info.driverUserId) {
            [array addObject:@(TripEvaluateSuspectSameAccount)];
        }
        
        // kiểm tra tổng thời gian đi và khoảng cách đi thực tế
        NSInteger totalDis = 0;
        NSInteger totalDur = 0;
        if (info.tripType == BookTypeDigital) {
            totalDis = info.distance;
            totalDur = info.duration;
        }
        else {
            for (FCBookTracking* track in book.tracking) {
                if (track.command == BookStatusCompleted) {
                    totalDis += [track.d_distance integerValue];
                    totalDur += [track.d_duration integerValue];
                }
            }
        }
        if (totalDis <= rule.distance) {
            [array addObject:@(TripEvaluateSuspectDistance)];
        }
        if (totalDur <= rule.duration * 60) {
            [array addObject:@(TripEvaluateSuspectDuration)];
        }
        
        
        // kiểm tra độ chênh lệch khoảng cách, thời gian đi thực tế so với dự tính
        // độ chênh lệch không được quá cấu hình cho phép (tính = %)
        if (info.tripType == BookTypeFixed) {
            
            // Nếu điểm bắt đầu và kết thúc đều trong bán kính cho phép thì ko cần tính đến điều kiện độ lệch khoảng cách nữa
            // Ngược lại, hoặc điểm bắt đầu, hoặc điểm kết thúc nằm ngoài bán kính cho phép thì tính đến điều kiện khoảng cách
            BOOL startOutOfRange = [self isStartLocationOutOfRange:book];
            BOOL endOutOfRange = [self isEndLocationOutOfRange:book];
            if (startOutOfRange || endOutOfRange) {
                NSInteger totalEstimateDistance = book.estimate.intripDistance; //book.estimate.receiveDistance + book.estimate.intripDistance;
                if (totalEstimateDistance > 0 && totalEstimateDistance > totalDis) {
                    CGFloat detal = (totalEstimateDistance - totalDis) / (totalEstimateDistance * 1.0f);
                    if (detal > 0 && detal * 100 > rule.delta_distance) {
                        [array addObject:@(TripEvaluateSuspectDetalDistance)];
                        
                        if (startOutOfRange) {
                            [array addObject:@(TripEvaluateSuspectStartLocationOutOfRange)];
                        }
                        
                        if (endOutOfRange) {
                            [array addObject:@(TripEvaluateSuspectEndLocationOutOfRange)];
                        }
                    }
                }
            }
            
            NSInteger totalEstimateDuration = book.estimate.intripDuration; //book.estimate.receiveDuration + book.estimate.intripDuration;
            if (totalEstimateDuration > 0  && totalEstimateDuration > totalDur) {
                CGFloat detal = (totalEstimateDuration - totalDur) / (totalEstimateDuration * 1.0f);
                if (detal > 0 && detal * 100 > rule.delta_duration) {
                    [array addObject:@(TripEvaluateSuspectDetalDuration)];
                }
            }
        }
        
        // kiểm tra vị trí book thực tế
        if (book.tracking.count > 0) {
            CLLocation* clientLocation = nil;
            CLLocation* driverLocation = nil;
            for (FCBookTracking* track in book.tracking) {
                if (track.command == BookStatusClientCreateBook || track.command == BookStatusDriverAccepted) {
                    if (track.c_location) {
                        clientLocation = [[CLLocation alloc] initWithLatitude:track.c_location.lat longitude:track.c_location.lon];
                    }
                    if (track.d_location) {
                        driverLocation = [[CLLocation alloc] initWithLatitude:track.d_location.lat longitude:track.d_location.lon];
                    }
                }
            }
            
            if (clientLocation && driverLocation) {
                NSInteger distance = [clientLocation distanceFromLocation:driverLocation];
                if (distance < rule.distance_receive) {
                    if (![array containsObject:@(TripEvaluateSuspectSameLocation)]) {
                        [array addObject:@(TripEvaluateSuspectSameLocation)];
                    }
                }
            }
        }
        
        if (array.count > 0) {
            return @{@"evaluate":array};;
        }
    }
    
    return nil;
}

- (BOOL) isStartLocationOutOfRange: (FCBooking*) book {
    FCBookingRule* rule = [FirebaseHelper shareInstance].appConfigure.booking_rule_checking;
    for (FCBookTracking* track in book.tracking) {
        if (track.command == BookStatusStarted) {
            CLLocation* actual = [[CLLocation alloc] initWithLatitude:track.d_location.lat longitude:track.d_location.lon];
            CLLocation* require = [[CLLocation alloc] initWithLatitude:book.info.startLat longitude:book.info.startLon];
            double dis = [actual distanceFromLocation:require];
            return dis > rule.start_radius;
        }
    }
    return NO;
}

- (BOOL) isEndLocationOutOfRange: (FCBooking*) book {
    FCBookingRule* rule = [FirebaseHelper shareInstance].appConfigure.booking_rule_checking;
    CLLocation* require = [[CLLocation alloc] initWithLatitude:book.info.endLat longitude:book.info.endLon];
    CLLocation* actual = nil;
    
    for (FCBookTracking* track in book.tracking) {
        if (track.command == BookStatusCompleted) {
            actual = [[CLLocation alloc] initWithLatitude:track.d_location.lat longitude:track.d_location.lon];
            break;
        }
    }
    
    if (actual == nil) {
        actual = [GoogleMapsHelper shareInstance].currentLocation;
    }
    
    if (actual) {
        double dis = [actual distanceFromLocation:require];
        return dis > rule.end_radius;
    }
    
    return NO;
}
@end
