//
//  FCBookViewModel.m
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBookingService.h"
#import "FCHomeViewModel.h"
#import "BookViewController.h"
#import "AppDelegate.h"
#import "BookTripMissView.h"
#import "TripMapViewController.h"
#import "UserDataHelper.h"
#import "DigitalClockViewController.h"
#import "GoogleMapsHelper.h"
#import "FCResponse.h"
#import "NSData+CRC32.h"
#import "FCBookNotify.h"
#import "TripListenNewTripManager.h"
#import "TripTrackingManager.h"
#import "FCBookingService+Verify.h"
#import "FCBookingService+BookStatus.h"
#import "FCBookingService+PushTrip.h"
#import "FCBookingService+UpdateStatus.h"
#import "FCTrackingHelper.h"
#import "CancelReason.h"

#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

#define kBookInfo @"info"
#define kBookStatus @"command"
#define kBookEstimate @"estimate"
#define kBookExtra @"extra"
#define kBookingTimeout 25
extern NSString *DriverWantToCancelTripNotification;
extern NSDate const* _Nullable expiredReceiveTrip;
@import FirebaseAnalytics;
@interface FCBookingService ()
@property (strong, nonatomic) NSTimer* timerBookingTimeout;
@property (strong, nonatomic) ClockViewModel* bookTrackingModel;
@property (nonatomic, assign) FIRDatabaseHandle newBookingHandler;

@property (strong, nonatomic) RACDisposable *submitDataDisposable;
@property (strong, nonatomic) TripListenNewTripManager *listenNewTrip;
@property (strong, nonatomic) TripTrackingManager *tripTracking;
@property (strong, nonatomic) RACSubject *updateCommand;
@end

@implementation FCBookingService {
    BookViewController* _bookViewController;
    TripMapViewController* _tripMapViewController;
    BookTripMissView *_popupMissingBook;
    AppDelegate* _appDelegate;
    NSString* _lastestBooking; // cache last book receive
    UIAlertController* _popupClientCancel;
    UIAlertView* _alertViewAutoReceiveTrip;
    NSInteger _zoneid;
    NSTimer *autoReceiTripTimerOffMusic;
    NSTimer *autoReceiTripTimervibrate;
}

static FCBookingService* instance = nil;
+ (FCBookingService*) shareInstance {
    if (instance == nil) {
        instance = [[FCBookingService alloc] init];
        [[FireBaseTimeHelper default] startUpdate];
    }
    
    return instance;
}

+ (void) removeInstance {
    instance = nil;
}

- (void)setTripTracking:(TripTrackingManager *)tripTracking {
    _tripTracking = tripTracking;
//    NSAssert(tripTracking != nil, @"Check");
}

- (void)setBook:(FCBooking *)book {
    _book = book;
    if (!book) { return; }
    NSString *tripId = book.info.tripId;
    if (!_tripTracking && [tripId length] != 0) {
        self.tripTracking = [[TripTrackingManager alloc] init:tripId];
    }
}

- (id) init {
    self = [super init];
    if (self) {
        NSString* uid = [FIRAuth auth].currentUser.uid;
        _refDriverCurrentTrip = [[[FirebaseHelper shareInstance].ref child:TABLE_DRIVER_TRIP] child:uid];
        _refHistory = [[[FirebaseHelper shareInstance].ref child:TABLE_TRIP_HISTORY] child:uid];
        _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.updateCommand = [RACSubject new];
        self.cachedDecision = [NSMutableDictionary new];
        // call for update
        // [self apiAddListTrip];
    }
    
    return self;
}

- (void)dealloc {
    if (self.submitDataDisposable) {
        [self.submitDataDisposable dispose];
        self.submitDataDisposable = nil;
    }
}

- (RACSignal *)changePaymentMethod {
    if (_tripTracking) {
        return [_tripTracking paymentMethodSignal];
    }
    return [RACSignal empty];
}

- (void) createDigitalBookingData {
    
    // create booking data
    FCBooking* booking = [[FCBooking alloc] init];
    FCDriver* driver = [[UserDataHelper shareInstance] getCurrentUser];
    
    // booking info
    FCBookInfo* book_info = [[FCBookInfo alloc] init];
    book_info.driverFirebaseId = FIRAuth.auth.currentUser.uid;
    book_info.driverUserId = driver.user.id;
    book_info.serviceId = driver.vehicle.service;
    book_info.serviceName = driver.vehicle.serviceName;
    book_info.tripType = BookTypeDigital;
    CLLocation* lo = [GoogleMapsHelper shareInstance].currentLocation;
    book_info.startLat = lo.coordinate.latitude;
    book_info.startLon = lo.coordinate.longitude;
    book_info.timestamp = [self getCurrentTimeStamp];
    booking.info = book_info;
    self.book = booking;
    
    // zone
    [[FirebaseHelper shareInstance] getZoneByLocation:lo.coordinate
                                              handler:^(FCZone * zone) {
                                                  _zoneid = zone.id;
                                                  self.book.info.zoneId = zone.id;
                                              }];
    // start name
    @weakify(self);
    [[GoogleMapsHelper shareInstance] getAddressOfLocation:lo.coordinate
                                       withCompletionBlock:^(GMSReverseGeocodeResponse* response, NSError* error) {
                                           @strongify(self);
                                           if (!error) {
                                               GMSAddress* address = response.firstResult;
                                               self.book.info.startName = address.lines.firstObject;
                                               self.book.info.startAddress = address.lines.firstObject;
                                           }
                                           
                                           // create booking to server
                                           [self sendingBooking:booking complete:^(NSError *error) {}];
                                       }];
}

- (void) sendingBooking: (FCBooking*) book
               complete: (void (^)(NSError* error))block {
    @try {
        NSString* key = [TripListenNewTripManager generateIdTrip];
        self.tripTracking = [[TripTrackingManager alloc] init:key];
        
        // send to driver current trip
        {
            [_refDriverCurrentTrip setValue:key];
        }
        
        /*
        // send to notify trip
        {
            FCBookNotify* notify = [[FCBookNotify alloc] init];
            notify.driverId = book.info.driverFirebaseId;
            notify.requestId = book.info.driverFirebaseId;
            notify.tripId = key;
            NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[notify toDictionary]];
            [dict addEntriesFromDictionary:@{@"timestamp": @([self getCurrentTimeStamp])}];
            [self.tripTracking setDataTripNotify:key json:dict completion:^(NSError * _Nullable error) {
                
            }];
        }
         */
        
        // send to trip
        {
            NSMutableArray *commands = [NSMutableArray arrayWithArray:book.command ?: @[]];
            book.info.tripId = key;
            NSData* tripcode = [key dataUsingEncoding:NSUTF8StringEncoding];
            book.info.tripCode = [[self formatNumber:[tripcode crc32] toBase:34] uppercaseString];
            
            FCBookCommand* stt = [[FCBookCommand alloc] init];
            stt.status = BookStatusStarted;
            [commands addObject:stt];
            book.command = commands;
            NSMutableDictionary* sttData = [[NSMutableDictionary alloc] initWithDictionary:[stt toDictionary]];
            NSDictionary* time = @{@"time":@([self getCurrentTimeStamp])};
            [sttData addEntriesFromDictionary:time];
            NSString* sttKey = [NSString stringWithFormat:@"D-%ld", stt.status];
            NSDictionary* sttDict = @{sttKey:sttData};
            book.last_command = sttKey;
            // data book
            @weakify(self);
            [[FirebaseHelper shareInstance] getServerTime:^(NSTimeInterval timestamp) {
                @strongify(self);
                NSString *requestId = [NSString stringWithFormat:@"b%ld%.0f",(long)book.info.driverUserId, timestamp];
                if (book.info.requestId == nil || book.info.requestId.length == 0) {
                    book.info.requestId = requestId;
                }
                self.book.info.vehicleId = [UserDataHelper shareInstance].getCurrentUser.vehicle.id;
                NSMutableDictionary* dataBooking = [NSMutableDictionary dictionaryWithDictionary:[self.book toDictionary]];
                [dataBooking addEntriesFromDictionary:@{kBookStatus:sttDict}];
                
                // sending
                [self.tripTracking setDataToDatabase:@"" json:dataBooking update:NO completion:^(NSError * _Nullable error) {
                    block(error);
                    @strongify(self);
                    [self.tripTracking setDataToDatabase:kBookInfo json:@{@"zoneId": @(_zoneid)} update:YES];
                    [self trackingBookInfo:stt book:book];
                    [self.tripTracking setDataToDatabase:kBookInfo json:@{@"timestamp":@([self getCurrentTimeStamp])} update:YES];
                }];
            }];
            
//            [[[_refTrip child:key] child:kBookInfo] updateChildValues:@{@"timestamp":[FIRServerValue timestamp]}];
        }
    }
    @catch (NSException* e) {
    }
}

#pragma mark - Booking listener
static NSString *currentBookingId;
- (void)findTrip:(NSString *)tripId {
    if (tripId.length == 0) {
        return;
    }
    NSAssert(_listenNewTrip, @"Check Logic!!!!!");
    @weakify(self);
    [[_listenNewTrip findTrip:tripId] subscribeNext:^(FCBooking *booking) {
        @strongify(self);
        if (!booking) {
            [FIRAnalytics logEventWithName:@"book_not_found" parameters:@{@"book_id": tripId}];
            [self.listenNewTrip clearTripAllow];
            return;
        }
        
        if ([booking.info.tripId length] == 0) {
            [TripTrackingManager removeCurrentTrip:tripId];
            return;
        }
        BOOL needCheck = NO;
        if (booking.info) {
            needCheck = YES;
            if ([self isReadyForNewBook: booking]) {
                // send to driver current trip
                
                //Check Trip expire
                BOOL expire = NO;
                [FIRAnalytics logEventWithName:@"driver_ready_new_trip" parameters:@{@"book_id": tripId}];
                if (expiredReceiveTrip && [expiredReceiveTrip timeIntervalSince1970] > 0 && self.book == nil) {
                    FCBookCommand *command = [booking last];
                    if (command && command.status <= BookStatusClientCreateBook) {
                        [FIRAnalytics logEventWithName:@"driver_ready_miss_trip" parameters:@{@"book_id": tripId}];
                        NSTimeInterval remain = [expiredReceiveTrip timeIntervalSinceNow];
                        if (remain <= 0) {
                            self.book = booking;
                            
                            [self showPopupMissBook: booking];
                            @weakify(self);
                            [self updateBookStatus:BookStatusDriverMissing complete:^(BOOL success) {
                                @strongify(self);
                                [self.listenNewTrip clearTripAllow];
//                                [self processFinishedTrip:booking];
                            }];
                            self.book = nil;
                            expire = YES;
                        }
                    }
                }
                
                if (!expire) {
                    [FIRAnalytics logEventWithName:@"driver_ready_prepare_trip" parameters:@{@"book_id": tripId}];
                    {
                        [_refDriverCurrentTrip setValue:tripId];
                    }
                    
                    DLog(@"Booking -> ReadyForNewBook: %@", booking.info.tripId)
                    if ([self isNewBook:booking]) {
                        [FIRAnalytics logEventWithName:@"driver_ready_new_trip" parameters:@{@"book_id": tripId}];
                        [self onHandlerNewBook:booking];
                    }
                    else {
                        NSLog(@"Command status: exist");
                        [FIRAnalytics logEventWithName:@"driver_ready_exist_trip" parameters:@{@"book_id": tripId}];
                        [self onHandlerExistBook:booking];
                    }
                }
            }
            else {
                [FIRAnalytics logEventWithName:@"driver_ready_ignore_trip" parameters:@{@"book_id": tripId, @"status": @"busy"}];
                [self.listenNewTrip clearTripAllow];
                DLog(@"Booking -> NotReadyForNewBook: %@", booking.info.tripId);
                
                [self updateBookStatus:BookStatusDriverBusyInAnotherTrip book:booking
                              complete:^(BOOL success) {
                                  @strongify(self);
                                  [self.listenNewTrip deleteTrip:tripId];
                              }];
            }
        }
        if (!needCheck) return;
        FCBookCommand *command = [[FCBookCommand alloc] init];
        command.status = BookStatusTrackingReceiveTripAllow;
        command.time = [self getCurrentTimeStamp];
        [self trackingBookInfo:command book:booking];
        
    } error:^(NSError *error) {
        [TripTrackingManager removeCurrentTrip:tripId];
    }];
}

- (void) prepareNewTrip {
    [self removeNewBookingListener];
    if (!_listenNewTrip) {
        self.listenNewTrip = [TripListenNewTripManager new];
    }
}

- (void)deleteTracking {
    if (!_tripTracking) {
        return;
    }
    [self.tripTracking deleteTrip];
    self.tripTracking = nil;
    [_refDriverCurrentTrip removeValue];
}

- (void) listenerNewBooking {
    // remove listner first
    [self prepareNewTrip];
    @weakify(self);
    [[_listenNewTrip tripNewSignal] subscribeNext:^(NSString *tripId) {
        @strongify(self);
        if (tripId.length == 0) {
            return;
        }
        [FIRAnalytics logEventWithName:@"book_got_trip" parameters:@{@"book_id": tripId}];
        if ([currentBookingId isEqualToString:tripId]) {
            return;
        }
        currentBookingId = tripId;
        [self deleteTracking];
        [self findTrip:tripId];
    }];
}

- (void) removeNewBookingListener {
    self.listenNewTrip = nil;
//    @try {
//        if (self.newBookingHandler != 0) {
//            [_refTripAllow removeObserverWithHandle:self.newBookingHandler];
//        }
//    }
//    @catch (NSException* e) {
//
//    }
}

/**
 Listener trạng thái mới được ghi nhận từ cả 2 bên.
 Nếu trạng thái mới nhận chưa tồn tại thì xử lý. Ngược lại thì bỏ qua
 - Check status để confirm với backend
 - Check list status hiện tại
 
 @param handler : callback trạng thái mới được add đúng (như mô tả ở trên) để tiếp tục xử lý
 */
- (void) listenerBookingStatusChange: (void (^) (FCBookCommand* status)) handler {
    NSAssert(_tripTracking, @"Please check logic");
    @weakify(self);
    RACSignal *commandTrip = [_tripTracking commandSignal];
    RACSignal *updateCommand = _updateCommand;
    
    [[[RACSignal merge:@[updateCommand, commandTrip]] distinctUntilChanged] subscribeNext:^(FCBookCommand* stt) {
        @strongify(self)
        [IndicatorUtils dissmiss];
        NSString *tripId = self.book.info.tripId;
        if ([tripId length] >0) {
            if (stt.status < 14 ) {
                [[VatoDriverUpdateLocationService shared] startUpdateLocationWithTripId:tripId inTrip:NO];
            } else if ([self isInTrip:self.book]) {
                [[VatoDriverUpdateLocationService shared] startUpdateLocationWithTripId:tripId inTrip:YES];
            }
            else if ([self isFinishedTripWith:stt.status]) {
                [[VatoDriverUpdateLocationService shared] stopUpdateTripLocation];
            }
        }
        
        NSMutableArray* lst_status = [NSMutableArray arrayWithArray: self.book.command];
        if (lst_status == nil) {
            lst_status = [[NSMutableArray alloc] init];
        }
        if (stt.status == BookStatusClientCancelIntrip) {
            NSLog(@" Command status: listenerBookingStatusChange %ld", stt.status);
             [lst_status addObject:stt];
             NSArray* array = [lst_status sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
                 return obj1.status > obj2.status;
             }];
             
             self.book.command = [array copy];
             
             // callback
             handler(stt);
            return;
        }
        
        if (stt && ![self isExistStatus:stt.status]) {
            NSLog(@" Command status: listenerBookingStatusChange %ld", stt.status);
            [lst_status addObject:stt];
            NSArray* array = [lst_status sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
                return obj1.status > obj2.status;
            }];
            
            self.book.command = [array copy];
            
            // callback
            handler(stt);
        }

    }];
//    @try {
//        FIRDatabaseReference* ref = [[_refTrip child:self.book.info.tripId] child:kBookStatus];
//        [ref observeEventType:FIRDataEventTypeChildAdded
//                    withBlock:^(FIRDataSnapshot* snapshot) {
//                        if (snapshot && snapshot.value) {
//
//                            NSMutableArray* lst_status = [NSMutableArray arrayWithArray: self.book.command];
//                            if (lst_status == nil) {
//                                lst_status = [[NSMutableArray alloc] init];
//                            }
//                            FCBookCommand* stt = [[FCBookCommand alloc] initWithDictionary:snapshot.value
//                                                                                     error:nil];
//                            if (stt && ![self isExistStatus:stt.status]) {
//                                [lst_status addObject:stt];
//                                NSArray* array = [lst_status sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
//                                    return obj1.time > obj2.time;
//                                }];
//
//                                self.book.command = [array copy];
//
//                                // callback
//                                handler(stt);
//                            }
//                        }
//                    }];
//    }
//    @catch (NSException* e) {
//    }
}




#pragma mark - Booking Handler
- (void) onHandlerNewBook: (FCBooking*) book {
    [FIRAnalytics logEventWithName:@"driver_handler_new_trip_method" parameters:@{}];
    FCBookInfo* request = book.info;
    if (!request) {
        return;
    }
    
    if (![self isBookingAvailable:book]) {
        if ([self isFinishedTrip:book]) {
            [self processFinishedTrip:book];
        }
        else {
            [self updateBookStatus:BookStatusDriverMissing
                              book:book
                          complete:nil];
        }
        
        return;
    }
    
    // cache book info
    OnlineStatus driverStatus = self.homeViewModel.onlineStatus.status;
    if (driverStatus == DRIVER_READY) {
        // cache book
        self.book = book;
        if (self.book.info.zoneId == 0) {
            self.book.info.zoneId = _zoneid;
        }
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (_bookViewController || (state == UIApplicationStateBackground || state == UIApplicationStateInactive)) {
            [self playsound:@"tripbook"];
        }
        
        self.timerBookingTimeout = [NSTimer scheduledTimerWithTimeInterval:kBookingTimeout
                                                                    target:self
                                                                  selector:@selector(onBookTimeout:)
                                                                  userInfo:book
                                                                   repeats:NO];
        
        // Track booking info for first command
        if (book.command.count > 0) {
            __weak FCBookCommand *command = (FCBookCommand*)book.command[0];
            
            if (command && command.status == BookStatusClientCreateBook) {
                [self trackingBookInfo:book.command[0] book:book];
                [self.tripTracking setDataToDatabase:kBookInfo json:@{@"vehicleId":@([UserDataHelper shareInstance].getCurrentUser.vehicle.id)} update:YES];
            }
        }
        
        // Track booking info for consecutive commands
        [self listenerBookingStatusChange:^(FCBookCommand *status) {
            [self trackingBookInfo:status
                              book:book];
            
            [self onHandlerNewBookStatus:status
                                    book:book];
            
        }];
        
        // update driver busy
        [[FirebaseHelper shareInstance] driverBusy];
        
        // show booking confirm view
        [self showBookAlertView];
    }
}

- (void) onHandlerExistBook: (FCBooking*) book {
    [FIRAnalytics logEventWithName:@"driver_handler_exist_trip_method" parameters:@{}];
    if ([self isInTrip:book]) {
        // cache book
        self.book = book;
        if (self.book.info.zoneId == 0) {
            self.book.info.zoneId = _zoneid;
        }
        
        if (book.info.tripType == BookTypeFixed) {
            [self showTripMapView];
        }
        else if (book.info.tripType == BookTypeOneTouch) {
            [self showTripMapView];
        } else if (book.info.tripType == BookTypeDigital) {
            if (book.last.status == BookStatusClientAgreed || book.last.status == BookStatusDriverAccepted) {
                [self showTripMapView];
            } else {
                [self showDigitalClockTrip];
            }
            
        }
        @weakify(self);
        [self listenerBookingStatusChange:^(FCBookCommand *status) {
            @strongify(self);
            [self trackingBookInfo:status
                              book:book];
            
            [self onHandlerNewBookStatus:status
                                    book:book];
        }];
        
        // resume tracking
        FCBookCommand* currCmd = [book last];
        [self trackingBookInfo:currCmd
                          book:book];
    }
    else if ([self isFinishedTrip: book]) {
        self.book = book;
        [self processFinishedTrip: book];
    }
}

- (void)checkCanMoveHomeWhenDriverCancel: (FCBooking*) book {
    NSString *tripId = book.info.tripId;
    if ([tripId length] == 0) {
        return;
    }
    if ([_cachedDecision objectForKey:tripId] == nil) {
        return;
    }
    NSNumber *value = [NSNumber castFrom:[_cachedDecision objectForKey:tripId]];
    BOOL remove = [value boolValue] == NO;
    if (!remove) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:DriverWantToCancelTripNotification object:nil];
}

- (void) onHandlerNewBookStatus: (FCBookCommand*) newStatus
                           book: (FCBooking*) book {
    NSInteger statusCommand = newStatus.status;
    [FIRAnalytics logEventWithName:@"driver_handler_command_trip_method" parameters:@{@"status": @(statusCommand)}];
    NSLog(@"Command status: onHandlerNewBookStatus");
    if ([self isFinishedTripWith:newStatus.status]) {
        
        NSLog(@"Command status: finish");
        if ([self isAdminCanceled: book] || [self isClientCanceled: book]) {
            // hide any alert view on tripmap if have
            if (_tripMapViewController) {
                [_tripMapViewController hideAlertView:^{
                    [self notifyClientCancel];
                }];
            }
            else {
                [self notifyClientCancel];
            }
        }
        else if ([self isDriverCanceled: book]) {
            [self checkCanMoveHomeWhenDriverCancel:book];
            NSLog(@"Command status: Cancel");
        } else if ([self isBookStatusCompleted:book]) {
            if (_tripMapViewController) {
                [_tripMapViewController hideAlertView:^{
                    [_tripMapViewController endTrip];
                }];
            } else {
                [_tripMapViewController endTrip];
            }
        }
        
        // driver online
        [[FirebaseHelper shareInstance] driverReady];
        
        // stop timer
        [self.timerBookingTimeout invalidate];
        
        // Recheck array command ready update
        NSMutableArray *commands = [NSMutableArray arrayWithArray:book.command ?: @[]];
        if (newStatus && ![commands containsObject:newStatus]) {
            [commands addObject:newStatus];
            book.command = commands;
        }
        
        // check finished to delete trip
        NSLog(@"Command status: finish");
        [self processFinishedTrip: book];
    }
    else if (newStatus.status == BookStatusDriverAccepted ||  [self isInTrip: book]) {
        // stop timer
        NSLog(@"Command status: Intrip");
        [self.timerBookingTimeout invalidate];
        
//        if (book.info.tripType == BookTypeDigital) {
//            [self showDigitalClockTrip];
//        }
//        else {
//            [self showTripMapView];
//        }
        [self showTripMapView];
        [self hideBookAlertView];
        
        // api check with backend
        if (newStatus.status == BookStatusDriverAccepted
            || newStatus.status == BookStatusDeliveryReceivePackageSuccess) {
            [self apiCheckConnected: book];
        }
    }
}

/**
 Hàm kiểm tra xem đang xử lý booking nào đó trước khi nhận book mới không.
 Ví dụ trong trường hợp nhiều book tới đồng thời -> chỉ ưu tiên xử lý 1 book duy nhất
 
 @param newBook : Booking mới nhận
 @return: YES nếu đang không xử lý booking nào.
 : NO nếu đang xử lý một booking khác và chưa hoàn tất
 */
- (BOOL) isReadyForNewBook: (FCBooking*) book {
    if (self.book && ![self isFinishedTrip:self.book] && ![self.book.info.tripId isEqualToString: book.info.tripId])
        return NO;
    
    return YES;
}

/**
 Hàm lấy trạng thái cuối cùng được add vào list status
 Trang thái cuối cùng là trạng thái có time lớn nhất
 
 @param book: booking cần check status
 @return FCBookCommand nếu tôn tại list status, ngược lại return nil
 */
//- (FCBookCommand*) getLastBookStatus {
//    return [self getLastBookStatus:self.book];
//}
//
//- (FCBookCommand*) getLastBookStatus: (FCBooking*) book {
//    if (book.command.count == 0) {
//        return nil;
//    }
//
//    if (book.command.count == 1) {
//        return book.command.firstObject;
//    }
//
//    NSArray* array = [book.command sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
//        return obj1.status > obj2.status;
//    }];
//    FCBookCommand *last = [array objectAtIndex:array.count - 1];
//    return last;
//}


// yes: is auto receiveTrip and enough money
- (BOOL) checkAutoReceiveTrip {
    BOOL canAcceptBook = YES;
    FCBookExtra *extra = self.book.extra;
    if (/*driverAmount < amount &&*/ !extra.satisfied) {
        //            requireAmount = amount;
        canAcceptBook = NO;
    } else {
        canAcceptBook = YES;
    }
    
    if (AutoReceiveTripManager.shared.flagAutoReceiveTripManager == true
        && canAcceptBook ) {
        [self playAudioAutoReceiveTrip];
        [IndicatorUtils showWithMessage:@"Đang kết nối ..."];
        [self updateBookStatus:BookStatusDriverAccepted complete:^(BOOL success) {
            if (!success) {
                [self showAcceptedFailed];
            }
            [IndicatorUtils dissmiss];
        }];
        return YES;
        
    }
    return NO;
}


- (void)playAudioAutoReceiveTrip {
    [self playsound:@"tripbook" withVolume:1.0f isLoop:YES];
    [self vibrateDevice];
    autoReceiTripTimerOffMusic = [NSTimer scheduledTimerWithTimeInterval:60 repeats:NO block:^(NSTimer * timer) {
        [self stopSound];
        [self stopTimerAutoReceiveTrip];
    }];
    
    autoReceiTripTimervibrate = [NSTimer scheduledTimerWithTimeInterval:2 repeats:true block:^(NSTimer * timer) {
        [self vibrateDevice];
    }];
    
    _alertViewAutoReceiveTrip = [UIAlertView showWithTitle:@"Thông báo" message:@"Bạn đã nhận được một chuyến đi." cancelButtonTitle:@"Tiếp tục" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self stopSound];
        [self stopTimerAutoReceiveTrip];
    }];
}

- (void)stopTimerAutoReceiveTrip {
    [autoReceiTripTimerOffMusic invalidate];
    autoReceiTripTimerOffMusic = nil;
    [autoReceiTripTimervibrate invalidate];
    autoReceiTripTimervibrate = nil;
}

#pragma mark -
- (void) scheduleToRemoveTrip: (NSTimer*) timer {
    NSLog(@"Command status: Remove Trip");
    NSString* bookingId = timer.userInfo;
    if ([self.book.info.tripId isEqualToString:bookingId]) {
        self.book = nil;
    }
    if (_tripTracking && [_tripTracking.currentTripId isEqualToString:bookingId]) {
        [self deleteTracking];
    }
}

- (void) removeBooking: (NSString*) bookingId {
    [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(scheduleToRemoveTrip:)
                                   userInfo:bookingId
                                    repeats:NO];
}

- (void) onBookTimeout: (NSTimer *) timer {
    FCBooking* book = (FCBooking*) [timer userInfo];
    if (book) {
        [self updateBookStatus:BookStatusDriverMissing complete:^(BOOL success) {}];
    }
}

- (void) updateLastestBookingInfo: (FCBooking*) booking
                            block: (void (^)(NSError * error))block {
//    NSAssert(_tripTracking, @"Check logic");
    if (!_tripTracking) {
        self.tripTracking = [[TripTrackingManager alloc] init:booking.info.tripId];
    }
    NSDictionary *dic = [booking.info toDictionary];
    if (!_tripTracking) {
        if (block) block(nil);
        return;
    }
    [_tripTracking setDataToDatabase:kBookInfo json:dic update:YES completion:^(NSError * _Nullable error) {
        if (block) block(nil);
    }];
}

#pragma mark - Booking Amount Require

#pragma mark - Book Tracking

- (NSDictionary *) trackingBookInfo: (FCBookCommand*) forStatus
                     book: (FCBooking*) book {
    @try {

        NSString* status = [NSString stringWithFormat:@"%ld", (long) forStatus.status];
        CLLocation* lo = [[GoogleMapsHelper shareInstance] currentLocation];
        if (!lo) {
            lo = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        }
        
        FCBookTracking* tracking = [[FCBookTracking alloc] init];
        tracking.command = forStatus.status;
        tracking.d_location = [[FCLocation alloc] initWithLat:lo.coordinate.latitude lon:lo.coordinate.longitude];
        tracking.d_localTime = [self getTimeString:[self getCurrentTimeStamp] withFormat:@"yyyyMMdd HH:mm:ss"];
        
        // info when receiver client
        if (forStatus.status == BookStatusDriverAccepted) {
            self.bookTrackingModel = [[ClockViewModel alloc] initClockForBook:book];
            [self.bookTrackingModel startClock];
        }
        else if (forStatus.status == BookStatusStarted) {
            // write info receiver client
            if (self.bookTrackingModel) {
                tracking.d_distance = [NSNumber numberWithInteger:self.bookTrackingModel.clock.totalDistance];
                tracking.d_duration = [NSNumber numberWithInteger:self.bookTrackingModel.clock.totalTime];
                tracking.polyline = self.bookTrackingModel.clock.polyline;
                
                // reset book tracking
                [self.bookTrackingModel stopClock];
                self.bookTrackingModel = nil;
            }
            else {
                FCBookTracking* track = nil;
                for (FCBookTracking* t in book.tracking) {
                    if (t.command == forStatus.status) {
                        track = t;
                        break;
                    }
                }
                
                if (track) {
                    tracking.command = track.command;
                    tracking.d_timestamp = track.d_timestamp;
                    tracking.d_localTime = track.d_localTime;
                    tracking.d_distance = track.d_distance;
                    tracking.d_duration = track.d_duration;
                    tracking.polyline = track.polyline;
                }
                else {
                    FCDigitalClockTrip* clock = [ClockViewModel getLastClock:book.info.tripId];
                    if (clock) {
                        tracking.d_distance = [NSNumber numberWithInteger:clock.totalDistance];
                        tracking.d_duration = [NSNumber numberWithInteger:clock.totalTime];
                        tracking.polyline = clock.polyline;
                    }
                }
            }
            
            // restart book tracking
            self.bookTrackingModel = [[ClockViewModel alloc] initClockForBook:book];
            [self.bookTrackingModel startClock];
        }
        else if ([self isFinishedTrip: book]) {
            // write info finished trip
            if (self.bookTrackingModel) {
                tracking.d_distance = [NSNumber numberWithInteger:self.bookTrackingModel.clock.totalDistance];
                tracking.d_duration = [NSNumber numberWithInteger:self.bookTrackingModel.clock.totalTime];
                tracking.polyline = self.bookTrackingModel.clock.polyline;
            }
            else {
                FCDigitalClockTrip* clock = [ClockViewModel getLastClock:book.info.tripId];
                if (clock) {
                    tracking.d_distance = [NSNumber numberWithInteger:clock.totalDistance];
                    tracking.d_duration = [NSNumber numberWithInteger:clock.totalTime];
                    tracking.polyline = clock.polyline;
                }
            }
            
            // restart book tracking
            [self.bookTrackingModel stopClock];
            self.bookTrackingModel = nil;
        }
        
        if (!tracking.polyline) {
            tracking.polyline = [[VatoDriverUpdateLocationService shared] polylineInTrip];
        }
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[tracking toDictionary]];
        [dict addEntriesFromDictionary:@{@"d_timestamp": @([self getCurrentTimeStamp])}];
        NSAssert(_tripTracking, @"Check logic");
        NSLog(@"!!!!Log Trip Server : %@", dict);
        if ([forStatus isDriverStatus] == false) {
            [_tripTracking setDataToDatabase:[NSString stringWithFormat:@"%@/%@",kBookTracking, status] json:dict update:YES];
        }
        
        NSMutableArray* list;
        if (book.tracking.count > 0) {
            list = [NSMutableArray arrayWithArray:book.tracking];
        }
        else {
            list = [[NSMutableArray alloc] init];
        }
        [list addObject:tracking];
        
        book.tracking = [list copy];
        
        if (forStatus.status == BookStatusClientTimeout ||
            forStatus.status == BookStatusDriverDontEnoughMoney ||
            forStatus.status == BookStatusDriverBusyInAnotherTrip) {
            // reset book tracking
            [self.bookTrackingModel stopClock];
            self.bookTrackingModel = nil;
        }
        return dict;
    }
    @catch (NSException* e) {
    }
    @finally {}
    return [NSDictionary new];
}

- (void) trackingEstimateReceiveDis: (NSInteger) dis
                         receiveDur: (NSInteger) dur {
    @try {
        NSDictionary* value = @{@"receiveDuration": @(dur),
                                @"receiveDistance": @(dis)};
        
        if (self.book.info.tripType == BookTypeFixed) {
            value = @{@"receiveDuration": @(dur),
                      @"receiveDistance": @(dis),
                      @"intripDuration": @(self.book.info.duration),
                      @"intripDistance": @(self.book.info.distance)};
        }
        
        self.book.estimate = [[FCBookEstimate alloc] initWithDictionary:value
                                                                  error:nil];
        NSAssert(_tripTracking, @"Please check logic");
        [_tripTracking setDataToDatabase:kBookEstimate json:value update:YES];
        
//        [ref updateChildValues:value];
        [FCTrackingHelper trackEvent:@"Driver_iOS_Estimate" value:value];
        
    }
    @catch (NSException* e) {}
    @finally {}
}

- (void) saveBookingDataToStorage:(FCBooking*) _book {
    if (self.submitDataDisposable) {
        [self.submitDataDisposable dispose];
        self.submitDataDisposable = nil;
    }
    
    @weakify(self);
    RACSignal *loadTrip = [self bookingData:_book];
    NSDictionary *backup = [_tripTracking backup];
    
    self.submitDataDisposable = [loadTrip subscribeNext:^(id value) {
        DLog(@"Done");
        @strongify(self);
        
        /* Condition validation: Incase we could not get the latest data from Firebase, revert to current */
        NSDictionary *temp = [NSDictionary castFrom:value];
        
        FCBooking *book = [[FCBooking alloc] initWithDictionary:temp error:nil];
        if (book == nil) {
            book = _book;
        }
        
        if (!value) {
            temp = [book toDictionary];
        }
        
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary: temp ?: @{}];
        __weak NSDictionary *object = [NSDictionary castFrom:[info objectForKey:@"tracking"]];  //info[@"tracking"];
        
        // Override duration
        if (object) {
            __weak NSDictionary *trackingInfo = object;
            __autoreleasing NSMutableArray<FCBookTracking*> *trackings = [NSMutableArray arrayWithCapacity:trackingInfo.count];
            
            for (__weak NSDictionary *item in trackingInfo.allValues) {
                FCBookTracking *tracking = [[FCBookTracking alloc] initWithDictionary:item error:nil];
                [trackings addObject:tracking];
            }
            
            // Sort trackings
            [trackings sortUsingComparator:^NSComparisonResult(FCBookTracking *obj1, FCBookTracking *obj2) {
                return obj1.d_timestamp > obj2.d_timestamp;
            }];
            
            // Re-calculate durations
            for (NSInteger i = 1; i < trackings.count; i++) {
                __weak FCBookTracking *tracking = trackings[i];
                
                if (tracking.command == BookStatusStarted || [self isFinishedTripWith:tracking.command]) {
                    tracking.d_duration = @(round((tracking.d_timestamp - trackings[i - 1].d_timestamp) / 1000));
                }
            }
            
            // Re-construct trackings info
            __autoreleasing NSMutableDictionary *newTrackingInfo = [NSMutableDictionary dictionaryWithCapacity:trackingInfo.count];
            for (__weak FCBookTracking *tracking in trackings) {
                __autoreleasing NSString *key = [NSString stringWithFormat:@"%ld", (long)tracking.command];
                newTrackingInfo[key] = [tracking toDictionary];
            }
            info[@"tracking"] = newTrackingInfo;
            book.tracking = trackings;
        }
        
        // Recheck correct estimate
        if (![book validEstimate]) {
            NSDictionary *estimateJson = [NSDictionary castFrom:[backup objectForKey:kBookEstimate]] ?: @{};
            // Try resend
            [self.tripTracking setDataToDatabase:kBookEstimate json:estimateJson update:YES];
            info[kBookEstimate] = estimateJson;
        }
        
        // Execute old business
        NSError *err;
        NSData *data = [NSJSONSerialization dataWithJSONObject:info
                                                       options:0
                                                         error:&err];
        
        long long time = [self getCurrentTimeStamp];
        if (self.book.info.timestamp) {
            time = self.book.info.timestamp;
        }
        
        // Submit to firebase storage
        NSString* date = [self getTimeString:time
                                  withFormat:@"yyyy-MM-dd"];
        NSString* path = [NSString stringWithFormat:@"booking/%@/%@/%@.txt", date, book.info.driverFirebaseId, book.info.tripId];
        [[FirebaseHelper shareInstance] uploadData:data
                                          withPath:path
                                           handler:nil];
        
        // Submit to backend
        [self validatePayment:book];
    }];
}

- (RACSignal *) bookingData: (FCBooking*) book {
    if (!_tripTracking) {
        self.book = book;
    }
    NSAssert(_tripTracking, @"Check logic");
    return [_tripTracking getTripInfo];
}

#pragma mark - Book Extra
- (void) updateBookExtra: (FCRouter*) router {
    NSAssert(_tripTracking, @"Check logic");
    self.book.extra.polylineReceive = router.polylineEncode;
    [self setDataToDatabase:kBookExtra json:@{@"polylineReceive": router.polylineEncode ?: @""} update:YES];
}

- (void)setDataToDatabase:(NSString *)path json:(NSDictionary *)json update:(BOOL)update {
    [_tripTracking setDataToDatabase:path json:json update:update];
}

#pragma mark - Layout Handler
- (void) showBookAlertView {
    if (!self.book) {
        return;
    }
    
    [self hidePopupMissBook];
    
    // hide first
    [self hidePopupClientCancel:^{
        [self hideTripMapView:^(BOOL complete) {
            [self hideBookAlertView:^{
                [self onShowBookAlert];
            }];
        }];
    }];
}

- (void) onShowBookAlert {
    if ([self checkAutoReceiveTrip]) {
        return;
    }
    _bookViewController = [BookViewController createVC];
    //    [_bookViewController ac]
    [_bookViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [_bookViewController topLayoutGuide];
    [[_appDelegate visibleViewController:_appDelegate.window.rootViewController] presentViewController:_bookViewController animated:YES completion:^{
        
    }];
}

- (void) hideBookAlertView {
    [self hideBookAlertView:nil];
}

- (void) hideBookAlertView: (void (^) (void)) completed {
    if (_bookViewController && [_bookViewController presentingViewController] != nil) {
        [_bookViewController hideAnyPopup:^{
            [_bookViewController dismissViewControllerAnimated:YES completion:^{
                _bookViewController = nil;
                if (completed) {
                    completed();
                }
            }];
        }];
    }
    else if (completed) {
        _bookViewController = nil;
        completed();
    }
}

- (void)showPopupMissBook: (FCBooking *) copyBook {
    [self hidePopupMissBook];
    
    _popupMissingBook = [[[NSBundle mainBundle] loadNibNamed:@"BookTripMissView" owner:self options:nil] objectAtIndex:0];
    [_popupMissingBook loadData: (copyBook ?: self.book).info];
    [_popupMissingBook setFrame:_appDelegate.window.rootViewController.view.bounds];
    [_appDelegate.window addSubview:_popupMissingBook];
}

- (void)hidePopupMissBook {
    if (_popupMissingBook) {
        [_popupMissingBook removeFromSuperview];
        _popupMissingBook = nil;
    }
}

- (void) showTripMapView {
    NSLog(@"Command status: showTripMapView");
    if (_bookViewController) {
        [_bookViewController dismissViewControllerAnimated:NO completion:^{
            _bookViewController = nil;
            
            [self loadTripMapView];
        }];
    }
    else {
        [self loadTripMapView];
    }
}

- (void) loadTripMapView {
    if (_tripMapViewController) {
        return;
    }
    _tripMapViewController = [[TripMapViewController alloc] init];
    NSAssert(self.book, @"No Booking!!!!");
    if (self.book.info.tripType == BookTypeOneTouch) {
        self.book.info.tripType = BookTypeFixed;
    }
    [_tripMapViewController setBooking:self.book];
    [_tripMapViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    UIViewController* visibleVC = [_appDelegate visibleViewController:_appDelegate.window.rootViewController];
//    [visibleVC setModalPresentationStyle:UIModalPresentationFullScreen];
    [visibleVC presentViewController:_tripMapViewController animated:YES completion:^{
        [IndicatorUtils dissmiss];
    }];
}

- (void) hideTripMapView: (void (^)(BOOL complete)) completed {
    if (_tripMapViewController && [_tripMapViewController presentingViewController] != nil) {
        [_tripMapViewController dismissChat];
        [_tripMapViewController dismissViewControllerAnimated:YES completion:^{
            _tripMapViewController = nil;
            _popupClientCancel = nil;
            if (completed) {
                completed(TRUE);
            }
        }];
    }
    else if (completed) {
        _tripMapViewController = nil;
        completed(TRUE);
    }
}

- (void) showDigitalClockTrip {
    FCDigitalClockTrip *clock = [[UserDataHelper shareInstance] getLastDigitalClockTrip:self.book];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[_appDelegate visibleViewController:_appDelegate.window.rootViewController] isKindOfClass: [DigitalClockViewController class]]) {
            return;
        }
        DigitalClockViewController *vc = [[DigitalClockViewController alloc] initWithNibName:@"DigitalClockViewController" bundle:nil];
        [vc setClockTrip:clock];
        [vc setBooking:self.book];
        [vc setModalPresentationStyle:UIModalPresentationFullScreen];
        [[_appDelegate visibleViewController:_appDelegate.window.rootViewController] presentViewController:vc
                                                                                                  animated:YES
                                                                                                completion:^{
                                                                                                    
                                                                                                }];
    });
}

- (void) notifyClientCancel {
    // stop timer countdown
    [_bookViewController stopTimer];
    
    if (_popupMissingBook) {
        return;
    }
    @weakify(self);
    void(^Completion)(void)  = ^{
        @strongify(self);
        if (_alertViewAutoReceiveTrip != nil) {
            [_alertViewAutoReceiveTrip dismissWithClickedButtonIndex:-1 animated:NO];
            _alertViewAutoReceiveTrip = nil;
            [self stopTimerAutoReceiveTrip];
        }
        
        UIViewController* vc = [_appDelegate visibleViewController:_appDelegate.window.rootViewController];
        if (![vc isKindOfClass:[BookViewController class]] && ![vc isKindOfClass:[TripMapViewController class]]) {
            return;
        }
        
        
        [self playsound:@"cancel"];
        NSString *message = [NSString stringWithFormat:@"Khách hàng đã huỷ chuyến đi này. Vui lòng trở về màn hình chính để tiếp tục nhận chuyến đi mới."];
        _popupClientCancel = [UIAlertController showAlertInViewController:vc
                                                                withTitle:@"Khách hàng huỷ chuyến"
                                                                  message:message
                                                        cancelButtonTitle:@"Đóng"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil
                                                                 tapBlock: ^(UIAlertController* controller, UIAlertAction* action, NSInteger buttonIndex) {
                                  // if client cancel in book -> hide first
                                  [self hideBookAlertView];
                                  
                                  [self hideTripMapView: nil];
                                  
                                  _popupClientCancel = nil;
                              }];
    };
    if (_tripMapViewController) {
        [_tripMapViewController dismissPackageVC:Completion];
    } else {
        Completion();
    }
    
}

- (void) hidePopupClientCancel: (void (^ __nullable)(void))completion {
    if (_popupClientCancel && [_popupClientCancel presentingViewController] != nil) {
        [_popupClientCancel dismissViewControllerAnimated:YES
                                               completion:^{
                                                   _popupClientCancel = nil;
                                                   if (completion) {
                                                       completion ();
                                                   }
                                               }];
    }
    else if (completion) {
        _popupClientCancel = nil;
        completion ();
    }
}

- (void) showAcceptedFailed {
    UIViewController* vc = [_appDelegate visibleViewController:_appDelegate.window.rootViewController];
    [UIAlertController showAlertInViewController:vc
                                       withTitle:@"Thông báo"
                                         message:@"Nhận chuyến thất bại, khách hàng đã huỷ chuyến đi này, bạn vui lòng trở lại màn hình chính để tiếp tục nhận chuyến mới"
                               cancelButtonTitle:@"Đồng ý"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            [vc dismissViewControllerAnimated:YES
                                                                   completion:nil];
                                        }];
}

/*
 * Kiểm tra với backend chuyến đi đã kết thúc
 * - OK : Thoát khỏi chuyến đi -> xoá booking
 */
- (void) processFinishedTrip: (FCBooking*) book {
    [_cachedDecision removeAllObjects];
    if ([_lastestBooking isEqualToString:book.info.tripId]) {
        return;
    }
    if (self.tripTracking) {
        [self.tripTracking clearTripAllow];
    }
    _lastestBooking = book.info.tripId;
    
    // cache
    [self saveBookingDataToStorage:book];
}

- (void)validatePayment:(FCBooking *)book {
    if (book.info.payment == PaymentMethodVATOPay && [self isTripCompleted:book]) {
        [self apiCheckTripFare:book complete:^(BOOL allowPayment) {
            if (allowPayment) {
                [self apiCheckFinished:book];
            } else {
                [self notifyCannotPaymentByWallet];
                book.info.payment = PaymentMethodCash;
                [self apiCheckFinished:book];
                
                if (_tripMapViewController) {
                    [_tripMapViewController.receiptView updatePaymentMethodTitle];
                }
            }
        }];
    } else {
        [self apiCheckFinished:book];
    }
}

- (void) notifyCannotPaymentByWallet {
    UIViewController* visiableVC = [_appDelegate visibleViewController:_appDelegate.window.rootViewController];
    [UIAlertController showAlertInViewController:visiableVC
                                       withTitle:@"Số dư VATOPAY của khách không đủ"
                                         message:@"Số tiền còn lại trong VATOPAY của khách hàng không đủ để thanh toán.\n Bạn vui lòng yêu cầu khách hàng thanh toán bằng tiền mặt cho chuyến đi này."
                               cancelButtonTitle:@"Tôi đã hiểu"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            
                                        }];
}

/**
 Với chuyến đi thanh toán bằng tài khoản cần kiểm tra số dư thanh toán của khách hàng trước khi tiến hành thanh toán
 */
- (void) apiCheckTripFare: (FCBooking*) book complete: (void (^)(BOOL allowPayment)) block {
    [IndicatorUtils show];
    NSInteger bookPrice = [book.info getBookPrice];
    NSInteger clientPay = bookPrice + book.info.additionPrice;
    NSInteger clientPromotion = book.info.fareClientSupport;
    
    NSDictionary *params = @{@"clientId": @(book.info.clientUserId),
                             @"amount":@(clientPay),
                             @"tripId":book.info.tripId,
                             @"tripCode":book.info.tripCode,
                             @"clientSupport":@(clientPromotion)};
    [[APIHelper shareInstance] post:API_CHECK_TRIP_FARE body:params complete:^(FCResponse *response, NSError *e) {
        [IndicatorUtils dissmiss];
        if (response.status == APIStatusOK) {
            block([(NSNumber*) response.data boolValue] == TRUE);
        }
        else {
            if ([response.message containsString:@"FareCapturedException"]) {
                // case đã thu tiền rồi => không thu lại nữa
                block(TRUE);
            }
            else {
                block(FALSE);
            }
        }
    }];
}

- (void) updateInfoReceiveImages:(NSArray*) receiveImages {
    [self.book.info updateInfoReceiveImages: receiveImages];
}

- (void) updateInfoDeliverImages:(NSArray*) deliverImages {
    [self.book.info updateInfoDeliverImages: deliverImages];
}

- (void) updateInfoDeliverFailImages:(NSArray*) deliverFailImages {
    self.book.info.delivery_fail_images = deliverFailImages;
    self.book.info.deliveryFailImages = deliverFailImages;
}

- (void) updateEndReason:(NSDictionary*) endReason {
    self.book.info.end_reason_id = [endReason[@"end_reason_id"] integerValue];
    self.book.info.end_reason_value = endReason[@"end_reason_value"];
}

- (void) updateCancelReason:(CancelReason*) cancelReason {
    self.book.info.driver_cancel_intrip = cancelReason;
}

- (RACSignal *)checkWaitingStatus:(BookStatus)status {
    NSAssert(_tripTracking, @"Check logic");
    for (FCBookCommand *command in self.book.command) {
        if (command.status == status) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:@(YES)];
                [subscriber sendCompleted];
                return nil;
            }];
        }
    }
    
    return [[_tripTracking bookingSignal] map:^NSNumber *(FCBooking *value) {
        if (!value) { return  @(NO); }
        NSArray *commands = value.command;
        for (FCBookCommand *command in commands) {
            if (command.status == status) {
                return @(YES);
            }
        }
        return @(NO);
    }];
}


- (RACSignal *)checkChangeBookInfo {
    return [[_tripTracking bookingSignal] map:^FCBookInfo *(FCBooking *value) {
        return value.info;
    }];
}

- (RACSignal *)loadCurrentTrip {
    @weakify(self);
    return [[[[TripTrackingManager loadCurrentTrip] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] flattenMap:^RACStream *(NSString *tripId) {
        if ([tripId length] == 0) {
            NSError *e = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey: @"No key"}];
            return [RACSignal error:e];
        }
        return [RACSignal return:tripId];
    }] doNext:^(NSString *tripId) {
        @strongify(self);
        [self prepareNewTrip];
        [self findTrip:tripId];
    }];
}

- (void)recheckValidateEstimate {
    if (![self.book validEstimate]) {
        NSDictionary *estimateJson = [self getEstimateBackup];
        // Try resend
        if (estimateJson != nil) {
            [self.tripTracking setDataToDatabase:kBookEstimate json:estimateJson update:YES];
        }
    }
}

- (NSDictionary *)getEstimateBackup {
    NSDictionary *backup = [_tripTracking backup];
    if (![self.book validEstimate]) {
        NSDictionary *estimateJson = [NSDictionary castFrom:[backup objectForKey:kBookEstimate]];
        [FIRAnalytics logEventWithName:@"driver_ios_request_get_estimate_backup" parameters:@{@"response": estimateJson ?: @{}, @"tripId": self.book.info.tripId ?: @""}];
        return estimateJson;
    }
    return nil;
}
@end
