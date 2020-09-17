//
//  FirebaseHelper.m
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FirebaseHelper.h"
#import "GoogleMapsHelper.h"
#import "NSString+MD5.h"
#import "TripTypeUtil.h"
#import "FCDevice.h"

#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@implementation FirebaseHelper

static FirebaseHelper * instnace = nil;
+ (FirebaseHelper*) shareInstance {
    if (instnace == nil) {
        instnace = [[FirebaseHelper alloc] init];
    }
    return instnace;
}

- (id) init {
    self = [super init];
    if (self) {
        self.ref = [FIRDatabase database].reference;
        _currentDriverLocation = nil;
    }
    
    if (!self.currentDriver) {
        self.currentDriver = [[UserDataHelper shareInstance] getCurrentUser];
    }
    
    return self;
}

- (NSString*) getUserId {
    return [FIRAuth auth].currentUser.uid;
}

- (NSInteger) getUserIdInt {
    return self.currentDriver.user.id;
}

- (NSString*) getUserIdStr {
    NSString* userId = [NSString stringWithFormat:@"%ld", self.currentDriver.user.id];
    return userId;
}

- (NSInteger) getGroup {
    int group = (int)[[self getUserId] javaHashCode] % 10;
    return group;
}

#pragma mark - Auth handler
- (FIRAuthCredential*) getPhoneCredential:(NSString*) phone {
    NSString* email = [NSString stringWithFormat:@"%@@%@", phone, EMAIL];
    FIRAuthCredential *credential = [FIREmailAuthProvider credentialWithEmail: email
                                                                     password: PASS];
    return credential;
    
}

- (void) phoneAuth:(NSString*) phone credential:(FIRAuthCredential*)credential handler:(void (^)(FIRUser *))completed {
    [[FIRAuth auth] signInAndRetrieveDataWithCredential:credential
                                             completion:^(FIRAuthDataResult* authResult, NSError* error) {
                                                 if (!error) {
                                                     completed(authResult.user);
                                                 }
                                                 else {
                                                     NSString* email = [NSString stringWithFormat:@"%@@%@", phone, EMAIL];
                                                     [[FIRAuth auth] createUserWithEmail:email
                                                                                password:PASS
                                                                              completion:^(FIRAuthDataResult* authResult, NSError* error) {
                                                                                  completed(authResult.user);
                                                                              }];
                                                 }
                                             }];
}

- (FIRAuthCredential*) getGoogleCredential:(NSString*) idToken accessToken: (NSString*) acctoken {
    if (!idToken || !acctoken) {
        return nil;
    }
    FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:idToken accessToken:acctoken];
    return credential;
}

- (void) googleAuth:(FIRAuthCredential*) credential handler:(void (^)(FIRUser *))completed {
    if (!credential) {
        completed(nil);
        return;
    }
    
    [[FIRAuth auth] signInAndRetrieveDataWithCredential:credential
                                             completion:^(FIRAuthDataResult* authResult, NSError * error) {
                                                 if (!error) {
                                                     completed(authResult.user);
                                                 }
                                                 else {
                                                     DLog(@"Error: %@", error)
                                                     completed(nil);
                                                 }
                                             }];
}


#pragma mark - Drivers

- (void) updateDriverData: (FCDriver*) driver
      withCompletionBlock: (void (^)(NSError * _Nullable, FIRDatabaseReference * _Nullable))block {
    @try {
        if (driver.user) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[FIRAuth auth].currentUser.uid];
            FCUser* user = driver.user;
            NSDictionary *post = [user toDictionary];
            [ref updateChildValues:post
               withCompletionBlock:block];
        }
        
        {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:[FIRAuth auth].currentUser.uid];
            NSMutableDictionary *post = [[NSMutableDictionary alloc] initWithDictionary:[driver toDictionary]];
            [post removeObjectForKey:@"user"];
            [ref updateChildValues:post
               withCompletionBlock:block];
        }
    }
    @catch (NSException* e) {
        block(nil, nil);
    }
}


- (void) getDriver:(void (^)(FCDriver*))completed  {
    @try {
        NSString* firebaseId = [FIRAuth auth].currentUser.uid;
        [self getUser:firebaseId handler:^(FCUser * user) {
            if (user) {
                FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:firebaseId];
                [ref keepSynced:YES];
                [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
                    if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* dict = [NSDictionary dictionaryWithDictionary:snapshot.value];
                        NSError* err;
                        FCDriver* driver = [[FCDriver alloc] initWithDictionary:dict error:&err];
                        driver.user = user;
                        
                        if (driver.user.firebaseId.length > 0 && driver.user.phone.length > 0) {
                            self.currentDriver = driver;
                            
                            // save to local
                            [[UserDataHelper shareInstance] saveUserToLocal:self.currentDriver];
                            completed(self.currentDriver);
                        }
                        else {
                            completed (nil);
                        }
                    }
                    else {
                        completed (nil);
                    }
                }];
            }
            else {
                completed(nil);
            }
        }];
    }
    @catch (NSException* e) {
        completed (nil);
    }
}

- (void) signOut:(void (^)(NSError*))completed {
    
    [[APICall shareInstance] apiSigOut];
    [[FireBaseTimeHelper default] stopUpdate];
    [[FirebaseTokenHelper instance] stopUpdate];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    [[FirebaseHelper shareInstance] driverOffline:^(NSError * _Nullable error, FIRDatabaseReference * _Nullable ref) {
        
    }];
    
    [[FCBookingService shareInstance] removeNewBookingListener];
    [FCBookingService removeInstance];
    [self removeDriverInfoChangedListener];
    self.currentDriver = nil;
    
    [[GIDSignIn sharedInstance] signOut];
    [[UserDataHelper shareInstance] clearUserData];
    
    
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    
    if (completed) {
        completed(error);
    }
}

- (void) getFirebaseToken:(void (^)(NSString * _Nullable, NSError * _Nullable))completed
{
    [[FIRAuth auth].currentUser getIDTokenForcingRefresh:YES
                                              completion:completed];
}

- (void) driverBusy
{
    [self updateDriverStatus:DRIVER_BUSY];
    
    [[FCBookingService shareInstance] removeNewBookingListener];
}

- (void) driverReady
{
    [self updateDriverStatus:DRIVER_READY];
    
    [[FCBookingService shareInstance] listenerNewBooking];
}

- (void) updateDriverStatus:(NSInteger)status
{
    if (!IS_STATUS_VALIDATE((long) status))
    {
        DLog(@"Status invalid: %ld", (long)status);
        return;
    }
    [[self class] updateDriverStatus:status funcName:[NSString stringWithFormat:@"%s line: %d",__FUNCTION__, __LINE__]];
    [self updateOnlineStatus:status
                     handler:nil];
}

FIRDatabaseHandle driverInfoListenerHandler;
- (void)addDriverInfoChangedListener:(void (^)(FIRDataSnapshot * _Nullable))completed
{
    @try {
        // remove listener before add listener
        [self removeDriverInfoChangedListener];
        
        // listen to driver info changed
        FIRDatabaseReference *ref = [[self.ref child:TABLE_DRIVER] child:[FIRAuth auth].currentUser.uid];
        driverInfoListenerHandler = [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            completed(snapshot);
        }];
    } @catch (NSException *exception) {
        DLog(@"%@", exception.description)
    }
}
- (void)addAutoAccept:(void (^)(FIRDataSnapshot * _Nullable))completed
{
    @try {
        
        // listen to driver info changed
        FIRDatabaseReference *ref = [[self.ref child:TABLE_DRIVER] child:[FIRAuth auth].currentUser.uid];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            completed(snapshot);
        }];
    } @catch (NSException *exception) {
        DLog(@"%@", exception.description)
    }
}

- (void)removeDriverInfoChangedListener
{
    if (driverInfoListenerHandler != 0) {
        FIRDatabaseReference *ref = [[self.ref child:TABLE_DRIVER] child:[FIRAuth auth].currentUser.uid];
        [ref removeObserverWithHandle:driverInfoListenerHandler];
    }
}

- (void) updateUserEmail: (NSString*) email complete: (void (^) (NSError* err)) block {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[self getUserId]];
            NSDictionary *post = @{@"email":email};
            [ref updateChildValues:post];
        }
        
        if ([[FIRAuth auth] currentUser].email.length == 0) {
            [[FIRAuth auth].currentUser updateEmail:email completion:^(NSError * error) {
                if (block) {
                    block(error);
                }
            }];
        }
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void) updatePlatfom {
    if ([[FIRAuth auth] currentUser]) {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:[self getUserId]];
        NSDictionary *post = @{@"currentVersion": [self getAppVersion]};
        [ref updateChildValues:post];
    }
}

- (void) updateDeviceInfo {
    @try {
        NSString* phone = [[[FIRAuth auth] currentUser].phoneNumber stringByReplacingOccurrencesOfString:@"+84"
                                                                                              withString:@"0"];
        if ([[FIRAuth auth] currentUser] && ![phone isEqualToString:PHONE_TEST]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:[self getUserId]];
            NSDictionary *post = @{@"deviceInfo":[[[FCDevice alloc] init] toDictionary]};
            [ref updateChildValues:post];
        }
    }
    @catch (NSException* e) {}
    @finally {}
    
}

- (void) updateUserGroup {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:[self getUserId]];
            int group = (int)[[[FIRAuth auth] currentUser].uid javaHashCode] % 10;
            NSDictionary *post = @{@"group":[NSString stringWithFormat:@"%d", group]};
            [ref updateChildValues:post];
        }
    }
    @catch (NSException* e) {}
}

- (void) updateDeviceToken:(NSString*) token {
    @try {
        if ([[FIRAuth auth] currentUser] && token.length > 0) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:[self getUserId]];
            NSDictionary *post = @{@"deviceToken": token};
            [ref updateChildValues:post];
        }
    }
    @catch (NSException* e) {
        
    }
}

- (void) updateUserPhone: (NSString*) phone {
    @try {
        if ([[FIRAuth auth] currentUser] && phone.length > 0) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[self getUserId]];
            NSDictionary *post = @{@"phone": phone};
            [ref updateChildValues:post];
        }
    }
    @catch (NSException* e) {
        
    }
}

- (void) updateUserId:(NSInteger) userid {
    @try {
        if ([[FIRAuth auth] currentUser] && userid > 0) {
            FIRDatabaseReference* ref = [[self.ref child:TABLE_USER]
                                         child:[self getUserId]];
            NSDictionary *post = @{@"id":@(userid)};
            [ref updateChildValues:post];
        }
    }
    @catch (NSException* e) {}
    
}

- (void) updateAvatarUrl:(NSString*) avatarUrl {
    @try {
        if ([[FIRAuth auth] currentUser] && avatarUrl.length > 0) {
            FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
            changeRequest.photoURL = [NSURL URLWithString:avatarUrl];
            [changeRequest commitChangesWithCompletion:^(NSError * error) {
                FIRDatabaseReference* ref = [[self.ref child:TABLE_USER]
                                             child:[FIRAuth auth].currentUser.uid];
                NSDictionary *post = @{@"avatarUrl":avatarUrl};
                [ref updateChildValues:post];
            }];
        }
    }
    @catch (NSException* e) {}
    
}

- (void) updateZone: (CLLocation*) location {
    @try {
        if ([[FIRAuth auth] currentUser]) {
            FIRDatabaseReference* refZone = [[[[self.ref child:TABLE_MASTER] child:TABLE_ZONE] child:@"0"] child:@"cities"];
            [refZone keepSynced:YES];
            [refZone observeSingleEventOfType:FIRDataEventTypeValue
                                    withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                        if (snapshot.value) {
                                            for (FIRDataSnapshot* s in snapshot.children) {
                                                NSString* polyline = [s.value valueForKey:@"polyline"];
                                                if (polyline.length > 0) {
                                                    GMSPath *path =[GMSPath pathFromEncodedPath:polyline];
                                                    if (GMSGeometryContainsLocation(location.coordinate, path, NO)) {
                                                        [self updateZoneById:[[s.value valueForKey:@"id"] integerValue]];
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }];
        }
    }
    @catch (NSException* e) {
    }
}

- (void) updateZoneById: (NSInteger) zoneId {
    @try {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:[FIRAuth auth].currentUser.uid];
        NSDictionary *post = @{@"zoneId":@(zoneId)};
        [ref updateChildValues:post];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void) subscribeToTopic {
    @try {
        [[FirebaseHelper shareInstance] getDriver:^(FCDriver * driver) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                @try {
                    if (driver.topic.length > 0) {
                        [[FIRMessaging messaging] unsubscribeFromTopic:driver.topic];
                    }
                    
                    [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat: @"driver.city~%ld", (long)driver.zoneId]];
                }
                @catch (NSException* e) {}
                
                // update new topic
                FIRDatabaseReference* ref = [[self.ref child:TABLE_DRIVER] child:[FIRAuth auth].currentUser.uid];
                [ref updateChildValues:@{@"topic" : [NSString stringWithFormat: @"driver.city~%ld", (long)driver.zoneId]}];
            }];
        }];
    }
    @catch (NSException* e) {}
}

#pragma mark - Driver Online

- (void)driverOnline: (void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block
{
    [self updateOnlineStatus:DRIVER_READY
                     handler:block];
    
    [[FCBookingService shareInstance] listenerNewBooking];
    
    [[self class] updateDriverStatus:DRIVER_READY funcName:[NSString stringWithFormat:@"%s line: %d",__FUNCTION__, __LINE__]];

    // last time online update
    if (updateOnlineTimer)
    {
        [updateOnlineTimer invalidate];
        updateOnlineTimer = nil;
    }
    
    updateOnlineTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_UPDATE_LASTONLINE target:self selector:@selector(updateLastOnlineTime) userInfo:nil repeats:YES];
    [updateOnlineTimer fire];
}

- (void)driverOffline: (void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block
{
    @try {
        [self updateOnlineStatus:DRIVER_UNREADY
                         handler:block];
        [[FCBookingService shareInstance] removeNewBookingListener];
        
        
        [updateOnlineTimer invalidate];
        updateOnlineTimer = nil;
    } @catch (NSException *exception) {
        
    } @finally {
        [[self class] updateDriverStatus:DRIVER_UNREADY funcName:[NSString stringWithFormat:@"%s line: %d",__FUNCTION__, __LINE__]];
    }
}

NSTimer *updateOnlineTimer;
- (void) updateLastOnlineTime
{
    [self updateOnlineTime];
    
    // force start update location to keep background
    [[GoogleMapsHelper shareInstance] startUpdateLocation];
}

- (void) setCurrentDriverLocation:(CLLocation *)location
{
    _currentDriverLocation = location;
}

- (void) updateTimeOnlineHistory: (BOOL) isOn {
    @try {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_TIME_ONLINE] child:[self getUserId]].childByAutoId;
        NSDictionary *post = @{@"time": [FIRServerValue timestamp],
                               @"online": @(isOn)};
        [ref setValue:post];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (RACSignal *)getOnlineStatus {
    FIRDatabaseReference* ref = [[[self.ref child:TABLE_DRIVER_ONLINE]
                                  child:[NSString stringWithFormat:@"%ld", (long)[self getGroup]]]
                                 child:[FIRAuth auth].currentUser.uid];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *json = [NSDictionary castFrom:snapshot.value];
            if (!json) {
                NSError *e = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey: @"No value"}];
                [subscriber sendError:e];
                return;
            }
            NSNumber *state = [NSNumber castFrom:[json objectForKey:@"status"]] ?: @(DRIVER_UNREADY);
            [subscriber sendNext:state];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
}

- (void) updateOnlineStatus: (NSInteger) status
                    handler: (void (^)(NSError *__nullable error, FIRDatabaseReference * ref)) block {
    @try {
        self.currentDriverOnlineStatus = status;
        
        if (self.currentDriver.user.id != 0) {
//            FIRDatabaseReference* ref = [[[[self.ref child:TABLE_DRIVER_ONLINE_STATUS]
//                                          child:[NSString stringWithFormat:@"%ld", [self getGroup]]]
//                                         child:[self getUserId]]
//                                         child:[self getUserIdStr]];
//            [ref setValue:@(status) withCompletionBlock:block];
        }
        
        {
            FIRDatabaseReference* ref = [[[self.ref child:TABLE_DRIVER_ONLINE]
                                          child:[NSString stringWithFormat:@"%ld", [self getGroup]]]
                                         child:[FIRAuth auth].currentUser.uid];
            [ref updateChildValues:@{@"status":@(status)}];
            
            if (block) {
                block(nil, ref);
            }
        }
    }
    @catch(NSException* e) {
        
    }
}


- (void) updateOnlineTime {
//    @try {
//        /*
//        {
//            FIRDatabaseReference* ref = [[[[self.ref child:TABLE_DRIVER_ONLINE_TIME]
//                                          child:[NSString stringWithFormat:@"%ld", [self getGroup]]]
//                                         child:[self getUserId]]
//                                         child:[self getUserIdStr]];
//            [ref setValue:[FIRServerValue timestamp]];
//        }
//        */
//        {
//            FIRDatabaseReference* ref = [[[self.ref child:TABLE_DRIVER_ONLINE]
//                                          child:[NSString stringWithFormat:@"%ld", [self getGroup]]]
//                                         child:[FIRAuth auth].currentUser.uid];
//            long long t = [[NSDate new] timeIntervalSince1970];//[FireBaseTimeHelper default].currentTime;
//            [ref updateChildValues:@{
//                                     @"lastOnline": @(t),
//                                     @"id":@([self getUserIdInt])
//                                     }];
//        }
//    }
//    @catch(NSException* e) {
//
//    }
}

- (void) updateCar: (FCUCar*) car {
    @try {
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_DRIVER]
                                      child:[self getUserId]] child:@"vehicle"];
        [ref updateChildValues:[car toDictionary]];
    }
    @catch(NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void) removeCar {
    @try {
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_DRIVER]
                                      child:[self getUserId]] child:@"vehicle"];
        [ref removeValue];
    }
    @catch(NSException* e) {
        DLog(@"Error: %@", e)
    }
}

FIRDatabaseReference* _refOnlineStatus;
FIRDatabaseHandle _handlerOnlineStatus;
- (void) addDriverOnlineListener: (void (^) (FCOnlineStatus* online)) block {
    @try {
        _refOnlineStatus = [[[self.ref child:TABLE_DRIVER_ONLINE]
                                      child:[NSString stringWithFormat:@"%ld", [self getGroup]]]
                                     child:[FIRAuth auth].currentUser.uid];
        _handlerOnlineStatus = [_refOnlineStatus observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                        if (snapshot && snapshot.value) {
                            FCOnlineStatus* online = [[FCOnlineStatus alloc] initWithDictionary:snapshot.value
                                                                                          error:nil];
                            if (online) {
                                block(online);
                            }
                        }
                    }];
    }
    @catch(NSException* e) {
    }
}

- (void) removeDriverOnlineListener {
    @try {
        if (_handlerOnlineStatus != 0 && _refOnlineStatus) {
            [_refOnlineStatus removeObserverWithHandle:_handlerOnlineStatus];
        }
    }
    @catch(NSException* e) {
        
    }
}

#pragma mark - Clients

- (void) getClient: (NSString*) clientFirebaseId
           handler: (void (^)(FCClient *))completed {
    @try {
        [self getUser:clientFirebaseId
              handler:^(FCUser * user) {
                  if (user) {
                      FIRDatabaseReference* ref = [[self.ref child:TABLE_CLIENT] child:clientFirebaseId];
                      [ref keepSynced:YES];
                      [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
                          if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
                              NSDictionary* dict = [NSDictionary dictionaryWithDictionary:snapshot.value];
                              FCClient* client = [[FCClient alloc] initWithDictionary:dict error:nil];
                              client.user = user;
                              completed(client);
                          }
                          else {
                              completed (nil);
                          }
                      }];
                  }
                  else {
                      completed(nil);
                  }
              }];
        
    }
    @catch (NSException* e) {
        completed(nil);
    }
}

- (void) getUser: (NSString*) firebaseId
         handler: (void (^)(FCUser *))completed {
    @try {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:firebaseId];
        [ref keepSynced:YES];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
            if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dict = [NSDictionary dictionaryWithDictionary:snapshot.value];
                NSError* err;
                FCUser* user = [[FCUser alloc] initWithDictionary:dict error:&err];
                if (user && user.phone.length > 0 && user.firebaseId.length > 0) {
                    completed(user);
                }
                else {
                    completed (nil);
                }
            }
            else {
                completed (nil);
            }
        }];
    }
    @catch (NSException* e) {
        completed(nil);
    }
}

- (void) getPromotion: (NSString*) ofClient
        promotionCode: (NSString*) code
              handler: (void (^) (FCGift*)) handler {
    @try {
        NSString* uid = ofClient;
        FIRDatabaseReference* ref = [[self.ref child:TABLE_PROMOTION] child:uid];
        [ref keepSynced:YES];
        [ref observeSingleEventOfType:FIRDataEventTypeValue
                            withBlock:^(FIRDataSnapshot * snapshot) {
                                if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
                                    FCGift* gift = [[FCGift alloc] initWithDictionary:snapshot.value
                                                                                error:nil];
                                    if ([gift.code isEqualToString:code]) {
                                        handler(gift);
                                    }
                                    else {
                                        handler(nil);
                                    }
                                }
                                else {
                                    handler(nil);
                                }
                            }];
    }
    @catch (NSException* e) {
        
    }
}

#pragma mark - BackList
- (void) getListBlackList:(void (^)(NSMutableArray*))completed {
    FIRDatabaseReference* ref = [[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid];
    FIRDatabaseQuery* query = [[ref queryOrderedByChild:@"isFavorite"] queryEqualToValue:@NO];
    [query keepSynced:YES];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
        DLog(@"------- GetListFavorite: %@", snapshot.value)
        
        NSMutableArray* list = [[NSMutableArray alloc] init];
        for(FIRDataSnapshot* s in snapshot.children) {
            FCFavorite* fav = [[FCFavorite alloc] initWithDictionary:s.value error:nil];
            if (fav)
                [list addObject:fav];
        }
        completed(list);
    }];
}

- (void) getFavoriteInfo: (NSString*) clientFirebaseId handler:(void (^)(FCFavorite * fav))block  {
    @try {
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid] child:clientFirebaseId];
        [ref keepSynced:YES];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot* snapshot) {
            NSError* err;
            FCFavorite* fav = [[FCFavorite alloc] initWithDictionary:snapshot.value error:&err];
            block(fav);
        }];
    }
    @catch (NSException* e) {
        
    }
}

- (void) requestAddFavorite: (FCFavorite*) fav withCompletionBlock:(void (^)(NSError * error, FIRDatabaseReference * ref))block {
    @try {
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid] child:fav.userFirebaseId];
        [ref setValue:[fav toDictionary] withCompletionBlock:block];
    }
    @catch(NSException* e) {
        
    }
}

- (void) removeFromBacklist: (FCFavorite*) favorite handler:(void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block {
    FIRDatabaseReference* ref = [[[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid] child:favorite.userFirebaseId];
    [ref removeValueWithCompletionBlock:block];
}

- (void) getListBackList:(void (^)(NSMutableArray*))completed  {
    FIRDatabaseReference* ref = [[self.ref child:TABLE_FAVORITE] child:[FIRAuth auth].currentUser.uid];
    // FIRDatabaseQuery* query = [[ref queryOrderedByChild:@"isFavorite"] queryEqualToValue:@NO];
    [ref keepSynced:YES];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- getListBackList: %@", snapshot.value)
        
        NSMutableArray* list = [[NSMutableArray alloc] init];
        for(FIRDataSnapshot* s in snapshot.children) {
            FCFavorite* fav = [[FCFavorite alloc] initWithDictionary:s.value error:nil];
            if (fav && fav.isFavorite == NO)
                [list addObject:fav];
        }
        completed(list);
    }];
}

#pragma mark - Car

- (void) getListVatoProduct:(void (^)(NSMutableArray *))completed {
    @try {
        FIRDatabaseReference* ref = [[[FirebaseHelper shareInstance].ref child:TABLE_MASTER] child:@"Products"];
        [ref keepSynced:YES];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
            
            NSMutableArray* listProducts = [[NSMutableArray alloc] init];
            for (FIRDataSnapshot* snap in [snapshot children]) {
                FCProduct* prod = [[FCProduct alloc] initWithDictionary:snap.value error:nil];
                if (prod) {
                    [listProducts addObject:prod];
                }
            }
            completed(listProducts);
        }];
    }
    @catch(NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void) getListService: (void (^) (NSMutableArray* list)) block {
    @try {
        FIRDatabaseReference* ref = [[[FirebaseHelper shareInstance].ref child:TABLE_MASTER] child:@"VatoService"];
        [ref keepSynced:YES];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
            
            NSMutableArray* services = [[NSMutableArray alloc] init];
            for (FIRDataSnapshot* snap in [snapshot children]) {
                FCMService* ser = [[FCMService alloc] initWithDictionary:snap.value error:nil];
                if (ser) {
                    [services addObject:ser];
                }
            }
            block(services);
        }];
    }
    @catch(NSException* e) {
        DLog(@"Error: %@", e)
    }
}

#pragma mark - Receipt

- (void) getAllFare: (void (^)(NSMutableArray* list)) block {
    FIRDatabaseReference* ref = [[self.ref child:TABLE_MASTER] child:TABLE_FARE_SETTING];
    [ref keepSynced:YES];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
        NSMutableArray* receipts = [[NSMutableArray alloc] init];
        for (FIRDataSnapshot* snap in snapshot.children) {
            FCFareSetting* receipt = [[FCFareSetting alloc] initWithDictionary:snap.value error:nil];
            if (receipt && receipt.active) {
                [receipts addObject:receipt];
            }
        }
        
        block(receipts);
    }];
}

- (void) getFareDetail: (NSInteger) service
              tripType: (NSInteger) type
            atLocation: (CLLocation*) location
             taxiBrand: (NSInteger) taxiBrand
               handler: (void (^__nullable)(FCFareSetting* __nullable, NSArray<FCFarePredicate*>* __nullable, NSArray<FCFareModifier*>* __nullable))completed {

    @weakify(self);
    [self getZoneByLocation:location.coordinate  handler:^(FCZone * zone) {
        __block BOOL isAPIFareSettings = self.appConfigure.api_fare_settings;
        __block NSInteger zoneId = ZONE_VN;
        if (zone) {
            zoneId = zone.id;
        }
        [self getFareDetail:service tripType:type zone:zoneId taxiBrand:taxiBrand handler:completed];
//        @strongify(self);
//        if (isAPIFareSettings) {
//            [[APICall shareInstance] apiFareSettingsWithCoordinate:location.coordinate complete:^(NSArray<FCFareSetting *> *fareSettings, NSArray<FCFarePredicate *> *farePredecates, NSArray<FCFareModifier *> *fareModifiers, NSError *error) {
//                if (!error && fareSettings.count > 0) {
//                    NSArray* arr = nil;
//                    if (isAPIFareSettings) {
//                        // ZoneId will not apply for API, we only need to find the right fare settings for fare services
//                        arr = [fareSettings filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FCFareSetting* r, NSDictionary<NSString *,id> * _Nullable bindings) {
//                            if (r.service != service) {
//                                return NO;
//                            }
//
//                            NSArray* tripTypes = [TripTypeUtil splitTripType:r.tripType];
//                            if (![tripTypes containsObject:@(type)]) {
//                                return NO;
//                            }
//
//                            return YES;
//                        }]];
//                    } else {
//                        arr = [fareSettings filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FCFareSetting* r, NSDictionary<NSString *,id> * _Nullable bindings) {
//                            if (r.zoneId != zoneId) {
//                                return NO;
//                            }
//
//                            if (r.service != service) {
//                                return NO;
//                            }
//
//                            NSArray* tripTypes = [TripTypeUtil splitTripType:r.tripType];
//                            if (![tripTypes containsObject:@(type)]) {
//                                return NO;
//                            }
//
//                            return YES;
//                        }]];
//                    }
//
//                    FCFareSetting* result = nil;
//                    if (arr.count > 0) {
//                        result = [[arr sortedArrayUsingComparator:^NSComparisonResult(FCFareSetting*  obj1, FCFareSetting* obj2) {
//                            return obj1.priority < obj2.priority;
//                        }] firstObject];
//                    }
//
//                    if (result) {
//                        completed(result, farePredecates, fareModifiers);
//                        return;
//                    }
//                }
//
//                // Back to Firebase
//                [self getFareDetail:service tripType:type zone:zoneId handler:completed];
//            }];
//        } else {
//            [self getFareDetail:service tripType:type zone:zoneId handler:completed];
//        }
    }];
}


- (void) getFareDetail: (NSInteger) service
              tripType: (NSInteger) type
                  zone: (NSInteger) zoneId
             taxiBrand: (NSInteger) taxiBrand
               handler: (void (^__nullable)(FCFareSetting* __nullable, NSArray<FCFarePredicate*>* __nullable, NSArray<FCFareModifier*>* __nullable))completed {
    [self getAllFare:^(NSMutableArray *list) {
        NSMutableArray* fareZoneVN = [[NSMutableArray alloc] init];
        NSArray* arr = [list filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FCFareSetting* r, NSDictionary<NSString *,id> * _Nullable bindings) {
            if (!r.active) {
                return NO;
            }
            
            if (r.service != 96) {
                if (r.service != service) {
                    return NO;
                }
            }
            
            if (r.taxiBrand != taxiBrand) {
                return NO;
            }
            
            NSArray* tripTypes = [TripTypeUtil splitTripType:r.tripType];
            if (![tripTypes containsObject:@(type)]) {
                return NO;
            }
            
            if (r.zoneId != zoneId) {
                if (r.zoneId == ZONE_VN) {
                    [fareZoneVN addObject:r];
                }
                return NO;
            }
            
            return YES;
        }]];
        
        FCFareSetting* result = nil;
        if (arr.count > 0) {
            result = [[arr sortedArrayUsingComparator:^NSComparisonResult(FCFareSetting*  obj1, FCFareSetting* obj2) {
                return obj1.priority < obj2.priority;
            }] firstObject];
        } else {
            result = [[fareZoneVN sortedArrayUsingComparator:^NSComparisonResult(FCFareSetting*  obj1, FCFareSetting* obj2) {
                return obj1.priority < obj2.priority;
            }] firstObject];
        }
        
        if (result) {
            completed(result, nil, nil);
        }
        else {
            completed(nil, nil, nil);
        }
    }];
}

- (void) getListFareByLocation: (CLLocation*) atlocation
                       handler: (void (^)(NSArray*))completed {
    [self getZoneByLocation:atlocation.coordinate
                    handler:^(FCZone * zone) {
                        NSInteger zoneId = ZONE_VN;
                        if (zone) {
                            zoneId = zone.id;
                        }

                        [self getListFareByZoneId:zoneId
                                          handler:completed];

                    }];
}

- (void) getListFareByZoneId: (NSInteger) zoneId
                     handler: (void (^)(NSArray*))completed {
    [self getAllFare:^(NSMutableArray *list) {
        NSArray* arr = [list filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FCFareSetting* r, NSDictionary<NSString *,id> * _Nullable bindings) {
            if (!r.active) {
                return NO;
            }
            
            if (r.zoneId != zoneId) {
                return NO;
            }
            
            return YES;
        }]];
        
        if (arr.count > 0) {
            completed (arr);
        }
        else {
            [self getListFareByZoneId:ZONE_VN
                              handler:completed];
        }
    }];
}
#pragma mark - App Settings
- (void) getServerTime: (void (^)(NSTimeInterval)) block {
    FIRDatabaseReference *offsetRef = [[FIRDatabase database] referenceWithPath:@".info/serverTimeOffset"];
    [offsetRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSTimeInterval offset = [(NSNumber *)snapshot.value doubleValue];
        NSTimeInterval estimatedServerTimeMs = [[NSDate date] timeIntervalSince1970] * 1000.0 + offset;
        DLog(@"Estimated server time: %@", [self getTimeString:estimatedServerTimeMs withFormat:@"yyyy-MM-dd HH:MM:ss"])
        if (block) {
            block(estimatedServerTimeMs/1000);
        }
    }];
}


- (void) getAppSettings:(void (^)(FCSetting*))completed {
    FIRDatabaseReference* ref = [[[self.ref child:@"Settings"]
                                            child:@"Driver"]
                                            child:@"IOS"];
    FIRDatabaseQuery* query = [[ref queryOrderedByChild:@"newest"] queryEqualToValue:@(YES)];
    [query keepSynced:YES];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- getAppSettings: %@", snapshot.value)
        for (FIRDataSnapshot* s in snapshot.children) {
            FCSetting* fav = [[FCSetting alloc] initWithDictionary:s.value error:nil];
            if (fav) {
                completed(fav);
                return;
            }
        }
        completed(nil);
    }];
}

- (void) getAppConfigs:(void (^)())completed {
    FIRDatabaseReference* ref = [[[self.ref child:TABLE_APP_SETTINGS] child:@"Driver"] child:@"Configs"];
    [ref keepSynced:YES];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        DLog(@"------- getAppConfigs: %@", snapshot.value)
        
        NSError* err;
        self.appConfigs = [[FCConfigs alloc] initWithDictionary:snapshot.value error:&err];
        completed();
    }];
}

#pragma MARK - Master

- (void) getZoneByLocation: (CLLocationCoordinate2D) location handler:(void (^)(FCZone*)) completed {
    FIRDatabaseReference* refZone = [[[[self.ref child:TABLE_MASTER] child:TABLE_ZONE] child:@"0"] child:@"cities"];
    [refZone keepSynced:YES];
    [refZone observeEventType:FIRDataEventTypeValue
                            withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         if (snapshot.value) {
             FCZone* zone = nil;
             for (FIRDataSnapshot* s in snapshot.children) {
                 NSString* polyline = [s.value valueForKey:@"polyline"];
                 if (polyline.length > 0) {
                     GMSPath *path =[GMSPath pathFromEncodedPath:polyline];
                     FCZone *zoneTemp = [[FCZone alloc] initWithDictionary:s.value
                                                         error:nil];
                     if (GMSGeometryContainsLocation(location, path, NO) && (zone == nil || zone.sort < zoneTemp.sort)) {
                         zone = [[FCZone alloc] initWithDictionary:s.value
                                                                     error:nil];
                     }
                 }
             }
             
             if (completed != nil) {
                 completed (zone);
             }
         }
         else {
             completed (nil);
         }
     }];
}

- (void) getPartners:(CLLocation*) atLocation
             handler:(void (^)(NSMutableArray*))completed {
    
    [self getZoneByLocation:atLocation.coordinate
                    handler:^(FCZone * zone) {
                        NSInteger cityid = ZONE_VN;
                        if (zone) {
                            cityid = zone.id;
                        }
                        
                        FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                                      child:TABLE_PARTNER]
                                                     child:[NSString stringWithFormat:@"%ld", cityid]];
                        [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                            DLog(@"c: %@", snapshot.value)
                            
                            NSMutableArray* lst = [[NSMutableArray alloc] init];
                            for (FIRDataSnapshot* s in snapshot.children) {
                                NSError* err;
                                FCPartner* partner = [[FCPartner alloc] initWithDictionary:s.value error:&err];
                                if (partner)
                                    [lst addObject:partner];
                            }
                            
                            completed(lst);
                        }];
                        
                    }];
}

- (void) getAppConfigure:(void (^)(FCAppConfigure *))completed {
    @try {
        if (self.appConfigure) {
            completed(self.appConfigure);
            return;
        }
        FIRDatabaseReference* ref = [[self.ref child:TABLE_MASTER]
                                     child:TABLE_APP_CONFIGURE];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot* snapshot) {
                        if (snapshot && snapshot.value)
                        {
                            DLog(@"getAppConfigure: %@", snapshot.value);
                            self.appConfigure = nil;
                            
                            FCAppConfigure* configure = [[FCAppConfigure alloc] initWithDictionary:snapshot.value
                                                                                             error:nil];
                            
                            self.appConfigure = configure;
                            completed(configure);
                        }
                        
                    }];
    }
    @catch (NSException* e) {
        
    }
}

- (void) getInviteContent:(void (^)(FCMInvite *))completed {
    @try {
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                      child:TABLE_CAMPAIGNS] child:@"Invite"];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot* snapshot) {
                        if (snapshot && snapshot.value)
                        {
                            DLog(@"getInviteContent: %@", snapshot.value);
                            
                            FCMInvite* invite = [[FCMInvite alloc] initWithDictionary:snapshot.value
                                                                                error:nil];
                            completed(invite);
                        }
                        
                    }];
    }
    @catch (NSException* e) {
        
    }
}
         
- (void) resetMapKeys {
    self.googleKeys = nil;
}

- (void) getGoogleMapKeys: (void (^)(NSString* key)) block {
    @try {
        if (self.googleKeys.length > 0) {
            if (block) {
                block(self.googleKeys);
            }
            return;
        }
        
        FIRDatabaseReference* ref = [[[self.ref child:TABLE_MASTER]
                                      child:TABLE_APP_CONFIGURE]
                                     child:@"google_api_keys"];
        [ref keepSynced:YES];
        [ref observeEventType:FIRDataEventTypeValue
                    withBlock:^(FIRDataSnapshot* snapshot) {
                        
                        // Nếu keys settings có thay đổi thì reset ngay -> get key mới
                        [self resetMapKeys];
                        
                        if (snapshot && snapshot.value) {
                            DLog(@"getListGoogleMapKeys: %@", snapshot.value);
                            NSMutableArray* list = [[NSMutableArray alloc] init];
                            for (FIRDataSnapshot* s in snapshot.children) {
                                FCGoogleKey* invite = [[FCGoogleKey alloc] initWithDictionary:s.value
                                                                                        error:nil];
                                if (invite && invite.active) {
                                    [list addObject:invite];
                                }
                            }
                            
                            if (list.count > 0) {
                                int index = arc4random() % list.count;
                                FCGoogleKey* keyObj = [list objectAtIndex:index];
                                NSString* key = keyObj.key;
                                self.googleKeys = key;
                                DLog(@"Result GoogleMapKeys: %@", key);
                                
                                if (block) {
                                    block(key);
                                }
                            }
                        }
                    }];
    }
    @catch (NSException* e) {
        
    }
}


- (NSArray*) getListBanking {
    FCAppConfigure* configure = [FirebaseHelper shareInstance].appConfigure;
    if (configure.banking.count > 0) {
        NSMutableArray* list = [[NSMutableArray alloc] init];
        for (FCBanking* bank in configure.banking) {
            if (bank.active) {
                [list addObject:bank];
            }
        }
        
        return list;
    }
    
    return nil;
}


#pragma mark - Storage
- (FIRStorageUploadTask*) uploadImage:(UIImage*) image withPath: (NSString*) path handler : (void (^)(NSURL* url)) block {
    NSData *data = UIImagePNGRepresentation(image);
    return [self uploadData:data
                   withPath:path
                    handler:block];
}

- (void)upload: (NSArray<UIImage *> * _Nonnull)images withPath: (NSString *_Nonnull)path completeHandler:(void(^)(NSArray<NSURL *> *urls, NSError * _Nullable error)) handler{
    [[self upload:images withPath:path] subscribeNext:^(id x) {
        NSArray<NSURL *> *urls = (NSArray<NSURL *> *)x;
        if (handler) {
            handler(urls, nil);
        }
    } error:^(NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }];
}


- (RACSignal *)convert:(UIImage *)image {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = UIImageJPEGRepresentation(image, 0.5);
            [subscriber sendNext:data];
            [subscriber sendCompleted];
            
        });
        return nil;
    }];
}


- (RACSignal *)upload: (NSArray<UIImage *> * _Nonnull)images withPath: (NSString *_Nonnull) path {
    if (![self isNetworkAvailable]) {
        return [RACSignal error:[NSError errorWithDomain:@"ErrorNerwork" code:1011 userInfo:@{NSLocalizedDescriptionKey: @"Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra và thử lại."}]];
    }
    if ([images count] == 0) {
        return [RACSignal empty];
    }
    
    NSMutableArray<RACSignal *> *tasks = [NSMutableArray new];
    for (NSInteger i = 0; i < [images count]; i++) {
        UIImage *image = images[i];
        @weakify(self);
        RACSignal *task = [[self convert:image] flattenMap:^RACStream *(NSData *data) {
            @strongify(self);
            return [[self uploadData:data withPath:[NSString stringWithFormat:@"images/%@_%ld_%f", path, (long)i, [[NSDate date] timeIntervalSince1970]]] deliverOn:[RACScheduler scheduler]];
        }];
        [tasks addObject:task];
    }
    
    return [[RACSignal zip:tasks] deliverOn:[RACScheduler scheduler]];
}

- (RACSignal *) uploadData:(NSData*) data withPath:(NSString*) path {
    FIRStorage *storage = [FIRStorage storage];
    // Create a storage reference from our storage service
    FIRStorageReference *storageRef = [[storage reference] child:path];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        FIRStorageUploadTask *uploadTask = [storageRef putData:data
                                                      metadata:metadata
                                                    completion:^(FIRStorageMetadata *metadata,
                                                                 NSError *error) {
                                                        if (error) {
                                                            [subscriber sendError:error];
                                                            [subscriber sendCompleted];
                                                            return;
                                                        }
                                                        [storageRef downloadURLWithCompletion:^(NSURL * URL, NSError * error) {
                                                            if (error) {
                                                                [subscriber sendError:error];
                                                            } else {
                                                                [subscriber sendNext:URL];
                                                            }
                                                            [subscriber sendCompleted];
                                                        }];
                                                    }];
        
        return [RACDisposable disposableWithBlock:^{
            [uploadTask cancel];
        }];
    }];
}


- (FIRStorageUploadTask*) uploadData:(NSData*) data
                            withPath:(NSString*) path
                             handler:(void (^)(NSURL* url)) block {
    
    // Get a reference to the storage service using the default Firebase App
    FIRStorage *storage = [FIRStorage storage];
    
    // Create a storage reference from our storage service
    FIRStorageReference *storageRef = [[storage reference] child:path];
    
    
    // Upload the file to the path "images/rivers.jpg"
    FIRStorageUploadTask *uploadTask = [storageRef putData:data
                                                  metadata:nil
                                                completion:^(FIRStorageMetadata *metadata,
                                                             NSError *error) {
                                                    if (block) {
                                                        if (error != nil) {
                                                            block(nil);
                                                        } else {
                                                            [storageRef downloadURLWithCompletion:^(NSURL * URL, NSError * error) {
                                                                block(URL);
                                                            }];
                                                        }
                                                    }
                                                }];
    return uploadTask;
}



- (void) updateUserAvatar: (NSURL*) url {
    if ([[FIRAuth auth] currentUser]) {
        FIRDatabaseReference* ref = [[self.ref child:TABLE_USER] child:[FIRAuth auth].currentUser.uid];
        NSDictionary *post = @{@"avatarUrl": url.absoluteString};
        [ref updateChildValues:post];
    }
}



- (void)authenWithPhone:(NSString * _Nonnull)phone complete:(void (^ _Nonnull)(NSString * _Nonnull))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error {
    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:phone
                                            UIDelegate:nil
                                            completion:^(NSString* verificationID, NSError* e) {
                                                DLog(@"timestampe 2: %f", [self getCurrentTimeStamp])
                                                
                                                if (e) {
                                                    DLog(@"[Login] getSMSPasscode: %@", error);
                                                    error(e);
                                                }
                                                else {
                                                    complete(verificationID ?: @"");
                                                }
                                            }];
}
- (void)authenWithOtp:(NSString * _Nonnull)otp use:(NSString * _Nonnull)verify complete:(void (^ _Nonnull)(id <UserProtocol> _Nullable))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error {
    FIRPhoneAuthCredential* phoneCredential = [[FIRPhoneAuthProvider provider] credentialWithVerificationID:verify
                                                                                           verificationCode:otp];
    
    [[FIRAuth auth] signInAndRetrieveDataWithCredential:phoneCredential
                                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable e) {
                                                 DLog(@"[Login] verifySMSPassCode: %@", e);
                                                 if (e) {
                                                     error(e);
                                                     return;
                                                 }
                                                 
                                                 complete(authResult.user);
                                             }];
    
}
- (void)authenWithCustomToken:(NSString * _Nonnull)customToken complete:(void (^ _Nonnull)(id <UserProtocol> _Nullable))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error {
    [[VatoPermission shared] cachePermissionWithCustomToken:customToken];
    [[FIRAuth auth] signInWithCustomToken:customToken completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable e) {
        if (e) {
            error(e);
            return;
        }
        complete(authResult.user);
    }];
}

- (void)authenTrackingWithService:(NSInteger)type {
    self.authService = type;
}

- (NSString*) getAuthServiceName {
    return self.authService == 0 ? @"Firebase" : @"Vato";
}


- (void)updateTrip:(NSString *)tripID payment:(PaymentMethod)paymentMethod {
    @try {
        FIRDatabaseReference *ref = [[[self.ref child:TABLE_BOOK_TRIP] child:tripID] child:@"info"];
        [ref updateChildValues:@{@"payment":@(paymentMethod)} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            DLog(@"%@, %@", error, ref);
        }];
    }
    @catch(NSException* e) {
        DLog(@"%@", e);
    }
}
@end
