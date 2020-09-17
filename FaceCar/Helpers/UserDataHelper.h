//
//  DriverHelper.h
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FCProfileLevel2;
@class FCBanking;
@class FCDigitalClockTrip;
@class FCBooking;
@class FCBankingInfo;
@class FCDriver;

@import Firebase;

@interface UserDataHelper : NSObject

+ (UserDataHelper*__nonnull) shareInstance;

@property(strong, nonatomic) NSNumber* _Nullable autoAccept;
@property (nonatomic, assign) NSInteger countContract;
- (void) saveUserToLocal :(FCDriver*__nonnull) client;
- (FCDriver*__nullable) getCurrentUser;
- (NSInteger) userId;
- (void) clearUserData;

- (void) saveCurrentDigitalClockTrip:(FCDigitalClockTrip* __nonnull)clock forBook: (FCBooking*__nonnull) book;
- (void) removeCurrentDigitalClockTrip:(FCBooking*__nonnull) book;
- (FCDigitalClockTrip* __nullable) getLastDigitalClockTrip: (FCBooking*__nonnull) book;

- (NSInteger) getCurrentCar;
- (void) getAuthToken:(nullable FIRAuthTokenCallback) callback;

- (void) cacheNotificationStatus : (BOOL) noshowAgain;
- (BOOL) allowShowNotification;

- (void) saveLastestNotification: (long long) notifyCreated;
- (long long) getLastestNotification;

- (void) cacheCurrentPushData: (NSDictionary*__nonnull) dict;
- (NSDictionary*__nullable) getPushData;
- (void) removePushData;

- (void) cacheLvl2Info: (FCProfileLevel2*__nonnull) lvl2;
- (FCProfileLevel2*__nullable) getLvl2Info;
- (void) removeLvl2Info;

- (void) saveTripForDay: (long long) time trips: (NSMutableArray*) trips hasMore: (BOOL) more;
- (BOOL) hasMoreTripsForDay: (long long) time ;
- (NSMutableArray*) getListTripsForDay: (long long) time;
- (void) saveSumaryTrip: (NSInteger) tripcount
            totalAmount: (NSInteger) amount
                 forday: (long long) time;
- (NSNumber*) getTripSumaryAmount: (long long) time;
- (NSNumber*) getTripSumaryCount: (long long) time;


#pragma mark - Banking Info
- (void) saveBankingInfo: (FCBankingInfo*) banking;
- (FCBankingInfo*) getBankingInfo: (NSString*) bankName;
- (void) removeBankingInfo;

- (void) saveDefaultBanking: (FCBanking*) banking;
- (FCBanking*) getDefaultBanking;

@end
