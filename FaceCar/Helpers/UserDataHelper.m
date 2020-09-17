//
//  DriverHelper.m
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "UserDataHelper.h"
#import "AppDelegate.h"
#import "FCTripHistory.h"
#import "FCDigitalClockTrip.h"
#import "FCProfileLevel2.h"
#import "FCBooking.h"
#import "FCBankingInfo.h"
#import "FCBanking.h"
#import "FCUser.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
@import FirebaseAnalytics;
@implementation UserDataHelper {
    NSString* _firebaseToken;
}

static UserDataHelper * instnace = nil;
+ (UserDataHelper*) shareInstance {
    if (instnace == nil) {
        instnace = [[UserDataHelper alloc] init];
    }
    return instnace;
}

- (void) saveUserToLocal :(FCDriver*) user {
    [FIRAnalytics setUserID:[NSString stringWithFormat:@"%ld", user.user.id]];
    NSString *version = APP_VERSION_STRING;
    [FIRAnalytics setUserPropertyString:@"user_app_version" forName:[NSString stringWithFormat:@"ios_%@",version]];
    NSString* json = [user toJSONString];
    [[NSUserDefaults standardUserDefaults] setValue:json forKey:@"driver_info_1.0.0"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FCDriver*) getCurrentUser {
    NSString* json = [[NSUserDefaults standardUserDefaults] valueForKey:@"driver_info_1.0.0"];
    NSError* err;
    FCDriver* client = [[FCDriver alloc] initWithString:json error:&err];
    return client;
}

- (void) clearUserData {
    _firebaseToken = nil;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [userDefaults dictionaryRepresentation];
    for (id key in dict) {
        DLog(@"Remove key: %@", key)
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
}

#pragma mark - Trip History
- (void) saveTripForDay: (long long) time trips: (NSMutableArray*) trips hasMore: (BOOL) more {
    @try {
        NSString* days = [self getTimeString:time withFormat:@"yyyy-MM-dd"];
        NSArray *dictionaries = [FCTripHistory arrayOfDictionariesFromModels:trips];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionaries options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString* key = [NSString stringWithFormat:@"trip-history-%@", days];
        NSString* keymore = [NSString stringWithFormat:@"trip-history-has-more-%@", days];
        [[NSUserDefaults standardUserDefaults] setObject:string forKey:key];
        [[NSUserDefaults standardUserDefaults] setObject:@(more) forKey:keymore];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (NSMutableArray*) getListTripsForDay: (long long) time {
    @try {
        NSString* days = [self getTimeString:time withFormat:@"yyyy-MM-dd"];
        NSString* key = [NSString stringWithFormat:@"trip-history-%@", days];
        NSString* json = [[NSUserDefaults standardUserDefaults] valueForKey:key];
        NSMutableArray* array = [FCTripHistory arrayOfModelsFromString:json
                                                                 error:nil];
        return array;
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e);
    }
   
    return nil;
}

- (BOOL) hasMoreTripsForDay: (long long) time {
    @try {
        NSString* days = [self getTimeString:time withFormat:@"yyyy-MM-dd"];
        NSString* key = [NSString stringWithFormat:@"trip-history-has-more-%@", days];
        return [[[NSUserDefaults standardUserDefaults] valueForKey:key] boolValue];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e);
    }
    
    return NO;
}

- (void) saveSumaryTrip: (NSInteger) tripcount
            totalAmount: (NSInteger) amount
                 forday: (long long) time {
    @try {
        NSString* day = [self getTimeString:time withFormat:@"yyyy-MM-dd"];
        NSString* keycount = [NSString stringWithFormat:@"trip-sumary-count-%@", day];
        NSString* keyamount = [NSString stringWithFormat:@"trip-sumary-amount-%@", day];
        [[NSUserDefaults standardUserDefaults] setObject:@(tripcount) forKey:keycount];
        [[NSUserDefaults standardUserDefaults] setObject:@(amount) forKey:keyamount];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (NSNumber*) getTripSumaryAmount: (long long) time {
    @try {
        NSString* day = [self getTimeString:time withFormat:@"yyyy-MM-dd"];
        NSString* keyamount = [NSString stringWithFormat:@"trip-sumary-amount-%@", day];
        return [[NSUserDefaults standardUserDefaults] objectForKey:keyamount];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
    
    return nil;
}


- (NSNumber*) getTripSumaryCount: (long long) time {
    @try {
        NSString* day = [self getTimeString:time withFormat:@"yyyy-MM-dd"];
        NSString* keyamount = [NSString stringWithFormat:@"trip-sumary-count-%@", day];
        return [[NSUserDefaults standardUserDefaults] objectForKey:keyamount];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
    
    return nil;
}

#pragma mark - Banking Info
- (void) saveBankingInfo: (FCBankingInfo*) banking {
    NSString* key = [NSString stringWithFormat:@"banking-info-%@-%@", banking.bank, [FIRAuth auth].currentUser.uid];
    [[NSUserDefaults standardUserDefaults] setObject:[banking toJSONString] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FCBankingInfo*) getBankingInfo: (NSString*) bankName {
    NSString* key = [NSString stringWithFormat:@"banking-info-%@-%@", bankName, [FIRAuth auth].currentUser.uid];
    NSString* json = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (json.length > 0) {
        NSError* err;
        FCBankingInfo* info = [[FCBankingInfo alloc] initWithString:json error:&err];
        return info;
    }
    
    return nil;
}

- (void) removeBankingInfo {
    NSString* key = [NSString stringWithFormat:@"banking-info-%@", [FIRAuth auth].currentUser.uid];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void) saveDefaultBanking: (FCBanking*) banking {
    NSString* key = [NSString stringWithFormat:@"banking-default-%@", [FIRAuth auth].currentUser.uid];
    [[NSUserDefaults standardUserDefaults] setObject:[banking toJSONString] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FCBanking*) getDefaultBanking {
    NSString* key = [NSString stringWithFormat:@"banking-default-%@", [FIRAuth auth].currentUser.uid];
    NSString* json = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (json.length > 0) {
        NSError* err;
        FCBanking* info = [[FCBanking alloc] initWithString:json error:&err];
        return info;
    }
    
    return nil;
}

#pragma mark - Digital Clock Trip

- (void) saveCurrentDigitalClockTrip:(FCDigitalClockTrip *)clock forBook:(FCBooking*)book
{
    NSString* json = [clock toJSONString];
    NSString* key = [NSString stringWithFormat:@"latest_clock_trip_%@", book.info.tripId];
    [[NSUserDefaults standardUserDefaults] setObject:json forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) removeCurrentDigitalClockTrip: (FCBooking*) book
{
    NSString* key = [NSString stringWithFormat:@"latest_clock_trip_%@", book.info.tripId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FCDigitalClockTrip*)getLastDigitalClockTrip: (FCBooking*) book
{
    NSString* key = [NSString stringWithFormat:@"latest_clock_trip_%@", book.info.tripId];
    NSString* json = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    FCDigitalClockTrip* trip = [[FCDigitalClockTrip alloc] initWithString:json error:nil];
    return trip;
}

- (NSInteger) getCurrentCar {
    NSNumber* num = [[NSUserDefaults standardUserDefaults] valueForKey:@"car_selected"];
    
    return [num integerValue];
}

- (void) getAuthToken:(nullable FIRAuthTokenCallback) callback {
    NSString *token = [FirebaseTokenHelper instance].token;
    if ([token length] != 0 && (_firebaseToken == nil || ![_firebaseToken isEqualToString:token])) {
        _firebaseToken = token;
    }
    if (_firebaseToken.length > 0) {
        callback(_firebaseToken, nil);
        return;
    }
    
    [[FIRAuth auth].currentUser getIDTokenForcingRefresh:YES
                                              completion:^(NSString * _Nullable token, NSError * _Nullable error) {
                                                  _firebaseToken = token;
                                                  callback(token, error);
                                              }];
}


//- (void) forceGetNewToken {
//    _firebaseToken = nil;
//    [self getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
//        _firebaseToken = token;
//    }];
//}

- (void) cacheNotificationStatus : (BOOL) noshowAgain {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:noshowAgain] forKey:@"allow_show_notification_3"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) allowShowNotification {
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"allow_show_notification_3"] ) {
        return TRUE;
    }
    
    FCSetting* setting = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentSetting;
    BOOL allow = [[[NSUserDefaults standardUserDefaults] valueForKey:@"allow_show_notification_3"] boolValue] && !setting.isApply;
    return allow;
}

- (void) cacheCurrentPushData: (NSDictionary*) dict {
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"push_data"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary*) getPushData {
    NSDictionary* dict =  [[NSUserDefaults standardUserDefaults] valueForKey:@"push_data"];
    if (dict) {
        [self removePushData];
    }
    return dict;
}

- (void) removePushData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"push_data"];
}

#pragma mark - Notification
- (void) saveLastestNotification: (long long) notifyCreated {
    [[NSUserDefaults standardUserDefaults] setObject:@(notifyCreated)
                                              forKey:@"lastestNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (long long) getLastestNotification {
    NSNumber* time =  [[NSUserDefaults standardUserDefaults] valueForKey:@"lastestNotification"];
    return [time longLongValue];
}

#pragma mark - LVL2 profile
- (void) cacheLvl2Info: (FCProfileLevel2*) lvl2 {
    [[NSUserDefaults standardUserDefaults] setObject:[lvl2 toDictionary] forKey:@"lvl2_data"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FCProfileLevel2*) getLvl2Info {
    NSDictionary* dict =  [[NSUserDefaults standardUserDefaults] valueForKey:@"lvl2_data"];
    if (dict) {
        return [[FCProfileLevel2 alloc] initWithDictionary:dict error:nil];
    }
    return nil;
}

- (void) removeLvl2Info {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lvl2_data"];
}

- (NSInteger) userId {
    FCDriver *client = [self getCurrentUser];
    NSInteger result = client.user.id;
    return result;
}

@end
