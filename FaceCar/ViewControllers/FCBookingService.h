//
//  FCBookViewModel.h
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCBooking.h"
#import "FCHomeViewModel.h"
#import "FCRouter.h"

@class RACSignal;
@interface FCBookingService : NSObject
@property (strong, nonatomic) FCBooking* book;
@property (strong, nonatomic) FIRDatabaseReference* refDriverCurrentTrip;
@property (strong, nonatomic) FIRDatabaseReference* refHistory;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) FCBookCommand* currentStatus;
@property (strong, nonatomic) NSMutableDictionary *cachedDecision;
+ (instancetype) shareInstance;
+ (void) removeInstance;
- (RACSignal *)checkWaitingStatus:(BookStatus)status;
- (RACSignal *)loadCurrentTrip;
- (RACSignal *)changePaymentMethod;
- (void) createDigitalBookingData;
- (void) sendingBooking: (FCBooking*) book
               complete: (void (^)(NSError* error))block;
- (void) removeBooking: (NSString*) bookingId;
#pragma mark - Booking listener
- (void) listenerNewBooking;
- (void) removeNewBookingListener;

#pragma mark - Book Tracking
- (void) trackingEstimateReceiveDis: (NSInteger) dis
                         receiveDur: (NSInteger) dur;

#pragma mark - Book Extra
- (void) updateBookExtra: (FCRouter*) router;

#pragma mark - Booking Handler
- (void) onHandlerNewBook: (FCBooking*) book;
- (void) onHandlerExistBook: (FCBooking*) book;
- (void) onBookTimeout: (NSTimer *) timer;
- (void) updateLastestBookingInfo: (FCBooking*) booking
                            block: (void (^)(NSError * error))block;
- (void) notifyClientCancel;

#pragma mark - Booking Amount Require
- (void) processFinishedTrip: (FCBooking*) book;

#pragma mark - Layout Handler
- (void) showBookAlertView;
- (void) hideBookAlertView;
- (void) showPopupMissBook: (FCBooking *)copyBook;
- (void) showTripMapView;
- (void) hideTripMapView: (void (^)(BOOL complete)) completed;
- (void) showDigitalClockTrip;
- (void) showAcceptedFailed;

- (void) updateInfoReceiveImages:(NSArray*) receiveImages;
- (void) updateInfoDeliverImages:(NSArray*) deliverImages;
- (void) updateEndReason:(NSDictionary*) endReason;
- (void) updateCancelReason:(CancelReason*) cancelReason;
- (void) updateInfoDeliverFailImages:(NSArray*) deliverFailImages;

- (NSDictionary *) trackingBookInfo: (FCBookCommand*) forStatus book: (FCBooking*) book;
- (void) recheckValidateEstimate;
- (NSDictionary *) getEstimateBackup;

- (RACSignal *) checkChangeBookInfo;
- (void) setDataToDatabase:(NSString *)path json:(NSDictionary *)json update:(BOOL)update;
@end
