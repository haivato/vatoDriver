//  File name   : TripListenNewTripManager.h
//
//  Author      : Dung Vu
//  Created date: 10/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

@import Foundation;
@class RACSignal;

NS_ASSUME_NONNULL_BEGIN
@interface TripListenNewTripManager : NSObject
@property (readonly, nonatomic) RACSignal *tripNewSignal;
- (RACSignal *)findTrip:(NSString *)tripId;
+ (NSString *)generateIdTrip;
- (void)clearTripAllow;
- (void)deleteTrip:(NSString *)tripId;
+ (void)setDataTripNotify:(NSString *)tripId json:(NSDictionary *)json completion:(void(^)(NSError * _Nullable))completion;
@end
NS_ASSUME_NONNULL_END

