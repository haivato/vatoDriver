//
//  AFNetworkingHelper.h
//  FaceCar
//
//  Created by Vu Dang on 7/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCResponse.h"
#import "FCUser.h"
#import "FCNotification.h"
@class FCBalance;
@class FCFareSetting;
@class FCFareModifier;
@class FCFarePredicate;

@interface APICall : NSObject

+ (APICall*_Nonnull) shareInstance;

- (void) apiGetRefferalCodeWithComplete:(void (^_Nonnull)(NSString*_Nonnull)) completed;

- (void) apiVerifyRefferalCode:(NSString*_Nonnull) code withComplete:(void (^_Nonnull)(NSString*_Nonnull, BOOL)) completed;

- (void) apiGetInvoicesList:(NSDictionary*_Nonnull) params block:(void (^__nullable)(NSArray* list, BOOL more)) completed;

- (void) checkingNetwork;

- (void) apiGetTripListFromDay:(double)fromTimestamp toDay:(double)toTimestamp block:(void (^__nullable)(NSArray*__nullable, NSInteger, NSInteger))completed;

- (void) apiGetWithdrawHistoryList:(NSDictionary*) params block:(void (^)(NSArray* list, BOOL more)) completed;

- (void) apiUpdateProfile:(NSString*) email
                 nickname:(NSString*) nickname
                 fullname:(NSString*) fullname
                   avatar:(NSString*) avatar
                  handler:(void (^)(NSError * error)) block;

- (void) apiSigOut;
+ (void) apiGetMyBalance:(void (^)(FCBalance *))block;

- (void)apiFareSettingsWithCoordinate:(CLLocationCoordinate2D)coordinate complete:(void(^_Nonnull)(NSArray<FCFareSetting*> *fareSettings, NSArray<FCFarePredicate*> *farePredecates, NSArray<FCFareModifier*> *fareModifiers, NSError *error))complete;

@end
