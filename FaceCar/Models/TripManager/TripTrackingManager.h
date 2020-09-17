//  File name   : TripTrackingManager.h
//
//  Author      : Dung Vu
//  Created date: 10/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

@import Foundation;

@class RACSignal;
NS_ASSUME_NONNULL_BEGIN
@interface TripTrackingManager : NSObject
@property (readonly, nonatomic) NSString *currentTripId;
@property (readonly, nonatomic) RACSignal *errorSignal;
@property (readonly, nonatomic) RACSignal *bookingSignal;
@property (readonly, nonatomic) RACSignal *commandSignal;
@property (readonly, nonatomic) RACSignal *bookInfoSignal;
@property (readonly, nonatomic) RACSignal *bookExtraSignal;
@property (readonly, nonatomic) RACSignal *bookEstimateSignal;
@property (readonly, nonatomic) RACSignal *paymentMethodSignal;
- (instancetype)init:(NSString *)tripId;
- (void)clearTripAllow;
- (void)setDataTripNotify:(NSString *)tripId
                     json:(NSDictionary *)json
               completion:(void(^)(NSError * _Nullable))completion;
/**
 Set data to database

 @param path path to set value
 @param json value need to update
 @param update override / update
 */
- (void)setDataToDatabase:(NSString *)path json:(NSDictionary *)json update:(BOOL)update;
- (void)setDataToDatabase:(NSString *)path
                     json:(NSDictionary *)json
                   update:(BOOL)update
               completion:(void(^)(NSError * _Nullable error))handler;

- (void)setMutipleDataToDatabase:(NSArray<NSString *> *)paths
                            json:(NSArray<NSDictionary *> *)jsons
                          update:(BOOL)update ;
- (RACSignal *)updateMutipleValue:(NSDictionary<NSString *, NSDictionary *> *)data update:(BOOL)update;


/**
 Set multiplle json to database

 @param data data is json with key: path, value: json value set
 */
- (void)setMutipleDataToDatabase:(NSDictionary<NSString *, NSDictionary *> *)data update:(BOOL)update;
/**
 Return trip if it exist

 @return event include data
 */
- (RACSignal *)getTripInfo;

/**
 Stop listen change trip
 */
- (void)stopListen;
/**
 Remove Trip
 */
- (void)deleteTrip;


/**
 Load current trip driver if it exist

 @return event include tripId
 */
+ (RACSignal *)loadCurrentTrip;

+ (void)removeCurrentTrip:(NSString *)tripId;

- (NSDictionary *)backup;
@end
NS_ASSUME_NONNULL_END

