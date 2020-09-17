//
//  FCBookingService+UpdateStatus.m
//  FC
//
//  Created by Dung Vu on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FCBookingService+UpdateStatus.h"
#import "FCBookingService+BookStatus.h"
#import "TripTrackingManager.h"
#import "TripListenNewTripManager.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
#import "BookViewController.h"
NSString *DriverWantToCancelTripNotification = @"DriverWantToCancelTripNotification";
@import FirebaseAnalytics;
@interface FCBookingService (Checking)
@property (strong, nonatomic) TripTrackingManager *tripTracking;
@property (strong, nonatomic) RACSubject *updateCommand;
@end

@implementation FCBookingService (UpdateStatus)
- (void) updateBookStatus: (NSInteger) status
                 complete: (void (^) (BOOL success)) complete {
    [self updateBookStatus:status
                      book:self.book
                  complete:complete];
}

- (void) updateBookStatus: (NSInteger) status
                     book: (FCBooking*) book
                 complete: (void (^) (BOOL success)) complete {
    // Nếu trạng thái đã tồn tại rồi -> BỎ QUA
    if ([self isExistStatus:status]) {
        if (complete) { complete(YES); }
        return;
    }
    
    // Nếu trạng thái ghi vào không phải là NEW BOOK và currentData bị null (nghĩa là book đã bị xoá) -> BỎ QUA
    if (!book.command) {
        if (book.info.tripType == BookTypeDigital) {
            if (status != BookStatusStarted) {
                if (complete) { complete(YES); }
                return;
            }
        }
        else {
            if (status != BookStatusClientCreateBook) {
                if (complete) { complete(YES); }
                return;
            }
        }
    }
    
    // Tài xế chấp nhận -> nếu khách đã huỷ trước đó -> BỎ QUA
    if (status == BookStatusDriverAccepted) {
        if ([self isClientCanceled:book]) {
            if (complete) { complete(YES); }
            return;
        }
    }
    
    // Tài xế hết thơi gian nhận chuyến -> nếu đã vào chuyến đi thành công || khách đã huỷ -> BỎ QUA
    if (status == BookStatusDriverMissing) {
        if ([self isInTrip:book] || [self isFinishedTrip:book]) {
            if (complete) { complete(YES); }
            return;
        }
    }
    
    // Nếu khách huỷ trong khi book -> kiểm tra nếu đã vào chuyến rồi -> BỎ QUA
    if (status == BookStatusClientTimeout || status == BookStatusClientCancelInBook) {
        if ([self isTripStarted:book] || [self isInTrip:book]) {
            if (complete) { complete(YES); }
            return;
        }
    }
    
    // Nếu khách huỷ trong chuyến đi -> kiểm tra nếu đã bắt đầu rồi hoặc đã kết thúc rồi -> BỎ QUA
    if (status == BookStatusClientCancelIntrip) {
        if ([self isTripStarted:book] || [self isFinishedTrip:book]) {
            if (complete) { complete(YES); }
            return;
        }
    }
    
    // Nếu tài xế báo đang bận xử lý một booking khác -> kiểm tra xem book này đã ở trạng thái kết thúc rồi -> BỎ QUA
    if (status == BookStatusDriverBusyInAnotherTrip) {
        if ([self isFinishedTrip:book] || [self isInTrip:book]) {
            if (complete) { complete(YES); }
            return;
        }
    }
    
    if (status == BookStatusDriverCancelIntrip) {
        if ([self isTripStarted:book] || [self isFinishedTrip:book]) {
            if (complete) { complete(YES); }
            return;
        }
    }
    // Cập nhật status mới
    [self processUpdateStatus:status book:book complete:complete];
}

- (NSString *)methodName:(NSInteger)type {
    switch (type) {
        case PaymentMethodCash:
            return @"CASH";
        case PaymentMethodVATOPay:
            return @"WALLET";
        case PaymentMethodVisa:
            return @"VISA";
        case PaymentMethodMastercard:
            return @"MASTER";
        case PaymentMethodATM:
            return @"ATM";
        case PaymentMethodMomo:
            return @"MOMO";
        case PaymentMethodZaloPay:
            return @"ZALOPAY";
        default:
            return nil;
    }
}

- (NSString *)methodDescription:(NSInteger)type {
    switch (type) {
        case PaymentMethodCash:
            return @"Tiền mặt";
        case PaymentMethodVATOPay:
            return @"VATOPay";
        case PaymentMethodVisa:
            return @"Thẻ visa/master";
        case PaymentMethodMastercard:
            return @"Thẻ visa/master";
        case PaymentMethodATM:
            return @"Thẻ ATM";
        case PaymentMethodMomo:
            return @"Momo";
        case PaymentMethodZaloPay:
            return @"ZaloPay";
        default:
            return nil;
    }
}


- (void) processUpdateStatus: (NSInteger) status
                        book: (FCBooking*) book
                    complete: (void (^) (BOOL success)) complete
{
    
    // status
    FCBookCommand* stt = [[FCBookCommand alloc] init];
    stt.status = status;
    stt.time = [self getCurrentTimeStamp];
    NSString *tripId = book.info.tripId ?: @"";
    [FIRAnalytics logEventWithName:@"driver_update_command_trip"
                        parameters:@{@"book_id": tripId,
                                     @"command": @(status).stringValue }];
    @weakify(self);
    void(^CompleteUpdate)(void) = ^{
        if (complete) { complete(YES); }
    };
    
    void(^removeTrip)(void) = ^{
        [TripListenNewTripManager setDataTripNotify:book.info.tripId json:@{} completion:^(NSError * _Nullable error) {
            if (error) {
                NSAssert(NO, [error localizedDescription]);
            }
        }];
    };
    
    void(^BlockSuccess)(void) = ^{
        @strongify(self);
        [FIRAnalytics logEventWithName:@"driver_update_command_success"
                            parameters:@{@"book_id": tripId,
                                         @"command": @(status).stringValue }];
        [self.updateCommand sendNext:stt];
        CompleteUpdate();
        if (status == 14) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                removeTrip();
            });
        }
    };
    
    // New flow: Update api -> agree, cancel, ignore
    BOOL(^CheckCallApi)(NSInteger) = ^BOOL(NSInteger s) {
        return s == BookStatusDriverAccepted || s == BookStatusDriverCancelInBook || s == BookStatusDriverMissing;
    };
    
    BOOL callAPI = CheckCallApi(status);
    void(^BlockError)(NSError *) = ^(NSError *error){
        @strongify(self);
        CompleteUpdate();
        NSString *message = error.localizedDescription ?: @"";
        [FIRAnalytics logEventWithName:@"driver_update_command_fail"
                            parameters:@{@"book_id": tripId,
                                         @"command": @(status).stringValue,
                                         @"reason": message }];
        if (callAPI) {
            [IndicatorUtils dissmiss];
            [self processFinishedTrip:book];
            removeTrip();
            [[self class] updateDriverStatus:DRIVER_READY funcName:[NSString stringWithFormat:@"%s line: %d",__FUNCTION__, __LINE__]];
            
            UIViewController *(^TopControllerVC)(void) = ^UIViewController *{
                UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                UIViewController *resultVC = [UIApplication topViewControllerWithController:rootVC];
                return resultVC;
            };
            
            void(^showAlert)(void) = ^{
                UIViewController *topVC = TopControllerVC();
                if (!topVC) {
                    return;
                }
                [UIAlertController showInViewController:topVC
                                              withTitle:@"Thông báo"
                                                message:[error localizedDescription]
                                         preferredStyle:UIAlertControllerStyleAlert
                                      cancelButtonTitle:@"OK"
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:@[]
                     popoverPresentationControllerBlock:nil tapBlock:nil];
            };
            
            BookViewController *bookVC = [BookViewController castFrom:TopControllerVC()];
            if (bookVC) {
                [bookVC dismissViewControllerAnimated:YES completion:showAlert];
            } else {
                showAlert();
            }
        } else {
            if (status != BookStatusDriverAccepted) {
                [self.updateCommand sendNext:stt];
            }
        }
    };
    
    if (callAPI) {
        NSString *path = [NSString stringWithFormat:@"trip/%@/confirmations", tripId];
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params addEntriesFromDictionary:@{@"status" : @(status)}];
        CLLocation *location = [[VatoLocationManager shared] location];
        CLLocationCoordinate2D coordinate = location.coordinate;
        NSDictionary *l = @{@"location": @{ @"lat": @(coordinate.latitude),
                                            @"lon": @(coordinate.longitude)} };
        [params addEntriesFromDictionary:l];
        BOOL isAutoAcceptTrip = [[AutoReceiveTripManager shared] flagAutoReceiveTripManager];
        NSDictionary *isAutoAccept = @{@"isAutoAcceptTrip": @(isAutoAcceptTrip)};
        [params addEntriesFromDictionary:isAutoAccept];
        
        [self request:path method:@"POST"
               header:nil
               params:params
             complete:^(NSDictionary *r, NSError *e) {
            if (e) {
                BlockError(e);
                return;
            }
            NSError *err;
            FCResponse *res = [[FCResponse alloc] initWithDictionary:r ?: @{} error:&err];
            if (err) {
                BlockError(err);
                return;
            }
            
            if (res.status != 200) {
                err = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey: res.message ?: @""}];
                BlockError(err);
                return;
            }
            BlockSuccess();
        }];
        return;
    }
    
    
    BOOL needCheck;
    if (book.info.serviceId == 128) {
        needCheck = status == BookStatusDeliveryReceivePackageSuccess;
    } else {
        needCheck = status == BookStatusStarted && book.info.serviceId < 512;
    }
    
    // Check payment method
    if (needCheck && book.info.payment != PaymentMethodCash) {
        [self requestChargeMethod:tripId
                           method:book.info.payment
                           status:status
                     moveToInTrip:YES
                         complete:complete];
        return;
    }
    
    // Check cancel trip
    
    
    // Old flow
    NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithDictionary:[stt toDictionary]];
    NSString *key = [NSString stringWithFormat:@"D-%ld", (long)status];
    NSString *path = [NSString stringWithFormat:@"command/%@",key];
    // tracking
    NSDictionary* dictTracking = [self trackingBookInfo:stt book:book];
    NSString *pathTracking = [NSString stringWithFormat:@"%@/%ld", kBookTracking, (long)stt.status];
    [[[self.tripTracking updateMutipleValue:@{path: data,
                                              @"": @{@"last_command": key},
                                              pathTracking: dictTracking}
                                     update:YES] timeout:TIME_OUT_UPDATE_STATUS onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        BlockSuccess();
    } error:^(NSError *error) {
        BlockError(error);
    }];
}

- (NSString *)pathConfirm:(NSString *)tripId {
    NSString *path = [NSString stringWithFormat:@"trip/%@/pickup-confirmations", tripId];
    return path;
}

- (NSDictionary *)paramsConfirm:(PaymentMethod)method
                         status:(NSInteger)status
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    BOOL isAutoAcceptTrip = [[AutoReceiveTripManager shared] flagAutoReceiveTripManager];
    [params addEntriesFromDictionary:@{@"status" : @(status),
                                       @"auto_accept": @(isAutoAcceptTrip)}];
    CLLocation *location = [[VatoLocationManager shared] location];
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSString *geohash = [GeohashObj encodeWithLatitude:coordinate.latitude
                                             longitude:coordinate.longitude
                                                length:7];
    
    NSDictionary *l = @{@"location": @{ @"geohash" : geohash ?: @"",
                                        @"lat": @(coordinate.latitude),
                                        @"lon": @(coordinate.longitude)}};
    [params addEntriesFromDictionary:l];
    NSString *methodName = [self methodName:method];
    if (methodName) {
        [params addEntriesFromDictionary:@{ @"payment_method": methodName}];
    }
    
    return params;
}


- (void)requestChargeMethod:(NSString *)tripId
                     method:(PaymentMethod)method
                     status:(NSInteger)status
               moveToInTrip:(BOOL) inTrip
                   complete: (void (^)(BOOL success))complete
{
    NSString *path = [self pathConfirm:tripId];
    NSDictionary *params;
    BOOL accept = NO;
    if ([self.cachedDecision objectForKey:tripId] != nil) {
        accept = YES;
        params = [self paramsConfirm:PaymentMethodCash status:status];
    } else {
        params = [self paramsConfirm:method status:status];
    }
    
    void(^Complete)(BOOL) = ^(BOOL value){
        if (complete) {
            complete(value);
        }
    };
    
    void(^BlockError)(NSError *) = ^(NSError *error){
        NSString *message;
        NSString *title;
        NSArray *buttonNames;
        if (accept) {
            title = @"Thông báo";
            message = error.localizedDescription;
            buttonNames = @[@"Đồng ý"];
        } else {
            title = [@"Thông báo thanh toán tiền mặt" uppercaseString];
            NSString *methodDes = [self methodDescription:method];
            message = [NSString stringWithFormat:@"Không thể thực hiện thanh toán qua %@ của khách hàng. Vui lòng thông báo với khách hàng thanh toán bằng tiền mặt để tiếp tục chuyến đi", methodDes ?: @""];
            buttonNames = @[@"Huỷ chuyến đi này", @"Đồng ý, thanh toán tiền mặt"];
        }
        
        
        UIViewController *(^TopControllerVC)(void) = ^UIViewController *{
            UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            UIViewController *resultVC = [UIApplication topViewControllerWithController:rootVC];
            return resultVC;
        };
        
        void(^showAlert)(void) = ^{
            UIViewController *topVC = TopControllerVC();
            if (!topVC) {
                return;
            }
            [UIAlertController showInViewController:topVC
                                          withTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert
                                  cancelButtonTitle:nil
                             destructiveButtonTitle:nil
                                  otherButtonTitles:buttonNames
                 popoverPresentationControllerBlock:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                if (accept) {
                    Complete(NO);
                    return;
                }
                
                NSString *nameAction;
                if (buttonIndex == 2) {
                    nameAction = @"driver_cancel_trip_change_method";
                    [self.cachedDecision addEntriesFromDictionary:@{tripId: @(NO)}];
                    [self requestChargeMethod:tripId
                          method:PaymentMethodCash
                          status:BookStatusDriverCancelIntrip
                    moveToInTrip:NO
                        complete:complete];
                } else {
                    nameAction = @"driver_accept_trip_change_method";
                    [self.cachedDecision addEntriesFromDictionary:@{tripId: @(YES)}];
                    Complete(NO);
                }
                
                [FIRAnalytics logEventWithName:nameAction
                                    parameters:@{@"book_id": tripId,
                             @"command": @(status).stringValue}];
            }];
        };
        
        showAlert();
    };
    [IndicatorUtils show];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self request:path method:@"POST"
           header:nil
           params:params
         complete:^(NSDictionary *response, NSError *error)
    {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [IndicatorUtils dissmiss];
        if (error) {
            BlockError(error);
            return;
        }
        NSError *err;
        FCResponse *res = [[FCResponse alloc] initWithDictionary:response ?: @{} error:&err];
        if (err) {
            BlockError(err);
            return;
        }
        
        if (res.status == 200) {
            Complete(inTrip);
        } else {
            err = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey: res.message ?: @""}];
            BlockError(err);
        }
    }];
}

- (void)request:(NSString *)path
         method:(NSString *)method
         header:(NSDictionary<NSString *, NSString *> *)header
         params:(NSDictionary *)params
       complete:(void (^) (NSDictionary *response, NSError *error))complete {
    NSString *token = [[FirebaseTokenHelper instance] token];
    [[RequesterObjc instance] requestWithToken:token
                                          path:path
                                        method:method
                                        header:header
                                        params:params
                                 trackProgress:NO
                                       handler:complete];
    
}

@end
