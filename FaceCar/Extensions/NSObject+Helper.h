//
//  NSObject.h
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FCFareSetting.h"

@interface NSObject (Helper)

- (void) saveAppVersion :(NSString*) version;
- (NSString*) getCurrentAppVersion;

- (BOOL) isNetworkAvailable;
- (void) showMessageBanner: (NSString*) message status:(BOOL) succ;
- (void) hideMessageBanner;
- (void) playsound:(NSString *)soundname;
- (void) playsound:(NSString *)soundname withVolume:(CGFloat)volume isLoop:(BOOL)loop;
- (void) playsound:(NSString *)soundname
            ofType:(NSString*) type
        withVolume:(CGFloat)volume
            isLoop:(BOOL)loop;
- (void) stopSound;
- (void) vibrateDevice;
- (NSDate*) getDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
- (NSDate*) getCurrentDate;
- (double) getTimestampOfDate:(NSDate*)date;
- (double) getCurrentTimeStamp;
- (NSString*) getTimeString:(double) timeStamp;
- (NSString*) getTimeString:(long long) timeStamp withFormat: (NSString*) format;
- (NSString*) getTimeStringByDate:(NSDate*)date;
- (NSString*) getTimeYYYYMMString:(double)timeStamp;
- (NSString*) getMinuteAndSecond:(NSInteger) totalSeconds;
- (NSString*) getHourAndMinuteAndSecond:(NSInteger) totalSeconds;
- (BOOL) theSameDay: (long long) date1 and: (long long) date2;
- (__autoreleasing NSString*) getAppVersion;
- (__autoreleasing NSString *)getBundleIdentifier;
- (CLLocationDistance) getDistance:(CLLocation*) from fromMe: (CLLocation*) to;
- (NSString*) convertAccessString : (NSString*)input;
- (long) caculatePrice : (FCFareSetting*) receipe distance: (long) distance duration: (long) duration timeWait: (long) wait;
- (long) caculatePrice: (FCFareSetting*) receipe
              distance: (long) distance
           timeRunning: (long) running
              finished: (BOOL) finished;

- (void) callPhone: (NSString*) phone;
- (NSInteger) getPrice : (NSString*) str;
- (long) roundUpPrice: (long) price;
- (BOOL) validPhone :(NSString*) phone;
- (BOOL) validEmail :(NSString*) email;
- (BOOL) validBankAccount: (NSString*) bankaccount;
- (NSInteger) getColorCodeFromString: (NSString*) rgb;


- (NSString*) formatPrice :(long) priceNum;
- (NSString*) formatPrice:(long)priceNum withSeperator:(NSString*)seperator;
- (NSString*) formatDistance:(NSInteger)meter;

- (void)setViewRoundCorner:(UIView*)view withRadius:(CGFloat)radius;

- (NSString*) getDeviceId;
- (BOOL) isIpad;
- (BOOL) isPhoneX;

- (NSString*) formatNumber:(NSUInteger)n toBase:(NSUInteger)base;
- (void) scanerPhoneNumber: (NSString*) string complete: (void (^)(NSString* phone, NSRange range)) block;
@end

@interface NSObject(Cast)
+ (instancetype __nullable)castFrom:(id __nullable) obj;
@end

@interface NSArray<ObjectType>(Map)
- (NSArray *_Nonnull)map: (id _Nonnull (^_Nonnull)(id _Nonnull object))block;
@end

@interface NSObject(Update)
+ (void) updateDriverStatus:(OnlineStatus)status funcName: (NSString *_Nonnull)name;
@end
