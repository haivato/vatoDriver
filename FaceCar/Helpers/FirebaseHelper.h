//
//  FirebaseHelper.h
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"
#import "FCDriver.h"
#import "FCClient.h"
#import "FCFavorite.h"
#import "FCMCarType.h"
#import "FCFareSetting.h"
#import "FCFarePredicate.h"
#import "FCFareModifier.h"
#import "FCFilter.h"
#import "FCSetting.h"
#import "FCConfigs.h"
#import "FCService.h"
#import "UserDataHelper.h"
#import "FCNotificationSetting.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "FCProduct.h"
#import "FCBookTracking.h"
#import "ClockViewModel.h"
#import "FCZone.h"
#import "FCPartner.h"
#import "FCFee.h"
#import "FCAppConfigure.h"
#import "FCMInvite.h"
#import "FCBooking.h"
#import "FCBookingService.h"
#import "FCGoogleKey.h"
#import "FCOnlineStatus.h"
#import "FCMService.h"
@import SMSVatoAuthen;

@interface FIRUser(Extension)<UserProtocol>

@end

@import GoogleMaps;
@import Firebase;
@import FirebaseDatabase;

@protocol AuthenDependencyProtocol;
@protocol UserProtocol;

extern const struct MONExtResultStruct MONExtResult;

@interface FirebaseHelper : NSObject<AuthenDependencyProtocol>

@property (strong, nonatomic) FIRDatabaseReference* _Nullable ref;
@property (strong, nonatomic) FCConfigs* _Nullable appConfigs;
@property (strong, nonatomic) FCSetting* _Nullable appSettings;
@property (strong, nonatomic) FCAppConfigure* _Nullable appConfigure;

@property (strong, nonatomic) FCDriver* _Nullable currentDriver;
@property (assign, nonatomic) NSInteger currentDriverOnlineStatus;
@property (strong, nonatomic) CLLocation*_Nullable currentDriverLocation;
@property (strong, nonatomic) NSString*_Nullable currentClientLocationAddress;
@property (assign, nonatomic) NSInteger authService; // - 0: firebase, 1: vato

@property (strong, nonatomic) ClockViewModel* bookTrackingModel;
@property (strong, nonatomic) NSString* __nullable googleKeys;

+ (FirebaseHelper* __nullable) shareInstance;

- (FIRAuthCredential*__nonnull) getPhoneCredential:(NSString*__nonnull) phone;
- (void) phoneAuth:(NSString*__nonnull) phone credential:(FIRAuthCredential*__nullable)credential handler:(void (^__nullable)(FIRUser *__nullable))completed;
- (FIRAuthCredential*__nullable) getGoogleCredential:(NSString*__nullable) idToken accessToken: (NSString*__nullable) acctoken;
- (void) googleAuth:(FIRAuthCredential*__nullable) credential handler:(void (^__nullable)(FIRUser *__nullable))completed;

#pragma mark - Driver (User)
- (NSString*__nullable) getUserIdStr;
- (void) signOut: (void (^__nullable) (NSError*__nullable error)) completed;
- (void) updateUserEmail: (NSString*) email complete: (void (^) (NSError* err)) block ;
- (void) getDriver:(void (^__nullable)(FCDriver*__nullable))completed;
- (void) updateDriverData: (FCDriver*__nonnull) driver
      withCompletionBlock: (void (^)(NSError * _Nullable, FIRDatabaseReference * _Nullable))block;
- (void) getFirebaseToken: (void (^_Nullable)(NSString *_Nullable token, NSError *_Nullable error)) completed;
- (void) addDriverInfoChangedListener:(void (^_Nullable)(FIRDataSnapshot*_Nullable))completed;
- (void) addAutoAccept:(void (^_Nullable)(FIRDataSnapshot*_Nullable))completed;
- (void) removeDriverInfoChangedListener;
- (void) driverReady;
- (void) driverBusy;
- (void) updatePlatfom;
- (void) updateDeviceInfo;
- (void) updateUserGroup;
- (void) updateDriverStatus:(NSInteger) status;
- (void) updateDeviceToken:(NSString*__nonnull) token;
- (void) updateUserPhone:(NSString*__nonnull) phone;
- (void) updateUserId:(NSInteger) userid;
- (void) updateAvatarUrl:(NSString*) avatarUrl;
- (void) updateUserAvatar: (NSURL*) url;
- (void) subscribeToTopic;
- (void) updateZone: (CLLocation*__nonnull) location;
- (void) updateZoneById: (NSInteger) zoneId;
- (void) updateCar: (FCUCar*) car;
- (void) removeCar;

#pragma mark - Driver Online
- (void) updateOnlineTime;
- (void) driverOnline: (void (^__nullable)(NSError *__nullable error, FIRDatabaseReference *__nullable ref))block;
- (void) driverOffline: (void (^__nullable)(NSError *__nullable error, FIRDatabaseReference *__nullable ref))block;
- (void) updateTimeOnlineHistory: (BOOL) isOn;
- (void) addDriverOnlineListener: (void (^) (FCOnlineStatus* online)) block;
- (void) removeDriverOnlineListener;

#pragma mark - Clients
- (void) getClient: (NSString*) clientFirebaseId
           handler: (void (^)(FCClient *))completed;
- (void) getPromotion: (NSString*) ofClient
        promotionCode: (NSString*) code
              handler: (void (^) (FCGift*)) handler;

#pragma mark - BackList
- (void) getListBlackList:(void (^__nullable)(NSMutableArray*__nullable))completed;
- (void) getFavoriteInfo: (NSString*) clientFirebaseId handler:(void (^)(FCFavorite * fav))block;
- (void) getListBackList:(void (^__nullable)(NSMutableArray*__nullable))completed;
- (void) requestAddFavorite: (FCFavorite*) fav withCompletionBlock:(void (^)(NSError * error, FIRDatabaseReference * ref))block;
- (void) removeFromBacklist: (FCFavorite*__nullable) favorite handler:(void (^__nullable)(NSError *__nullable error, FIRDatabaseReference *__nullable ref))block;

#pragma mark - Car
- (void) getListVatoProduct:(void (^__nonnull)(NSMutableArray *__nullable))completed;
- (void) getListService: (void (^) (NSMutableArray* list)) block;

#pragma mark - FareSetting
- (void) getFareDetail: (NSInteger) service
              tripType: (NSInteger) type
            atLocation: (CLLocation*__nonnull) location
            taxiBrand: (NSInteger) taxiBrand
               handler: (void (^__nullable)(FCFareSetting* __nullable, NSArray<FCFarePredicate*>* __nullable, NSArray<FCFareModifier*>* __nullable))completed;
- (void) getListFareByLocation: (CLLocation*__nonnull) atlocation
                       handler: (void (^__nullable)(NSArray*__nullable))completed;;

#pragma mark - App Settings
- (void) getServerTime: (void (^)(NSTimeInterval)) block;
- (void) getAppSettings:(void (^_Nullable)(FCSetting*_Nullable))completed;
- (void) getAppConfigs:(void (^_Nullable)())completed;
- (void) getPartners:(CLLocation*__nonnull) atLocation
             handler:(void (^_Nullable)(NSMutableArray*_Nullable))completed;
- (void) getAppConfigure:(void (^__nullable)(FCAppConfigure*__nullable appconfigure))completed;
- (void) getInviteContent:(void (^__nullable)(FCMInvite *__nullable))completed;
- (void) getZoneByLocation: (CLLocationCoordinate2D) location handler:(void (^__nullable)(FCZone*__nullable)) completed;
- (void) getGoogleMapKeys: (void (^__nullable)(NSString*__nullable key)) block;
- (void) resetMapKeys;
- (NSArray*) getListBanking;

#pragma mark - Storage
- (FIRStorageUploadTask*__nullable) uploadImage:(UIImage*__nonnull) image  withPath: (NSString*__nonnull) path handler: (void (^__nullable)(NSURL*__nullable url)) block;
- (FIRStorageUploadTask*__nullable) uploadData:(NSData*__nonnull) data
                                      withPath:(NSString*__nonnull) path
                                       handler:(void (^__nullable)(NSURL*__nullable url)) block;
- (RACSignal *_Nonnull)getOnlineStatus;
#pragma mark - authenticate sms
- (void)authenWithPhone:(NSString * _Nonnull)phone complete:(void (^ _Nonnull)(NSString * _Nonnull))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error;
- (void)authenWithOtp:(NSString * _Nonnull)otp use:(NSString * _Nonnull)verify complete:(void (^ _Nonnull)(id <UserProtocol> _Nullable))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error;
- (void)authenWithCustomToken:(NSString * _Nonnull)customToken complete:(void (^ _Nonnull)(id <UserProtocol> _Nullable))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error;
- (void)authenTrackingWithService:(NSInteger)type;
- (NSString*) getAuthServiceName;

#pragma mark - Trip
- (void)updateTrip:(NSString *)tripID payment:(PaymentMethod)paymentMethod;

#pragma mark - Upload array image
- (void)upload: (NSArray<UIImage *> * _Nonnull)images withPath: (NSString *_Nonnull)path completeHandler:(void(^)(NSArray<NSURL *> *urls, NSError *_Nullable error)) handler;

@end
