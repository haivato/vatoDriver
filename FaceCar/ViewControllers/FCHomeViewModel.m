//
//  FCHomeViewModel.m
//  FC
//
//  Created by vudang on 5/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCHomeViewModel.h"
#import "AppDelegate.h"
#import "NSString+MD5.h"
#import "APIHelper.h"
#import "InviteFriendTableViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCInvoiceManagerViewController.h"
#import "FCNotifyViewController.h"
#import "FCWebViewController.h"
#import "HomeViewController.h"
#import "GoogleMapsHelper.h"
#import "ProfileViewController.h"
#import "FCWarningNofifycationView.h"
#import "DateTimeUtils.h"
#import "FCNotification.h"
#import "FCNewWebViewController.h"
#import "FCDevice.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
@interface FCHomeViewModel ()
@property (strong, nonatomic) UIViewController* viewController;
@end

static FCHomeViewModel* instace;

@implementation FCHomeViewModel {
    AppDelegate* appDelegate;
    FCWarningNofifycationView* _maintenaceView;
    UIAlertController* _alertSignout;
}

+ (FCHomeViewModel*) getInstace {
    return instace;
}

- (instancetype) initViewModelWithViewController:(UIViewController *)vc {
    
    self = [super init];
    
    if (self) {
        instace = self;
        self.onlineStatus = [[FCOnlineStatus alloc] init];
        
        self.viewController = vc;
        
        [self addDriverInfoChangedListener];
        
        [self addDriverOnlineChangedListener];
        
        [self checkInviteDynamicLink];
        
        [self getTotalUnreadNotification];
        
        [self checkingPushNotification];
        
        [self checkSystemMaintance];
        
        [self checkAvatar];
        
        // device token
        
        [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
            if (error) {
                return;
            }
            NSString *token = result.token;
            if ([token length] == 0) {
                return;
            }
            [[FirebaseHelper shareInstance] updateDeviceToken:token];
        }];
    
        
        // update platform
        [[FirebaseHelper shareInstance] updatePlatfom];
        
        [[FirebaseHelper shareInstance] updateUserGroup];
    }
    
    return self;
}

- (void) checkAvatar {
    @try {
        if (self.driver.user.avatarUrl.length == 0) {
            if ([FIRAuth auth].currentUser.photoURL.absoluteString.length > 0) {
                [[FirebaseHelper shareInstance] updateUserAvatar:[FIRAuth auth].currentUser.photoURL];
            }
        }
    }
    @catch (NSException* e) {
        
    }
}


- (void) checkSystemMaintance {
    [[FirebaseHelper shareInstance] getAppConfigure:^(FCAppConfigure * _Nullable appconfigure) {
        if (appconfigure.maintenance.active) {
            _maintenaceView = [[FCWarningNofifycationView alloc] init];
            _maintenaceView.bgColor = [UIColor whiteColor];
            _maintenaceView.messColor = [UIColor darkGrayColor];
            [_maintenaceView show:self.viewController.navigationController.view
                 image:[UIImage imageNamed:@"maintenance"]
                 title:@"Thông báo"
               message:appconfigure.maintenance.message
              buttonOK:nil
          buttonCancel:nil
              callback:nil];
            [self.viewController.navigationController.view addSubview:_maintenaceView];
        }
        else if (_maintenaceView) {
            [_maintenaceView removeFromSuperview];
        }
    }];
}


- (RACSignal *)listenDriverChangeInfo {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> s) {
        [[FirebaseHelper shareInstance] addDriverInfoChangedListener:^(FIRDataSnapshot * _Nullable snapshot) {
            if (snapshot && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                @strongify(self);
                FCDriver* driver = [[FCDriver alloc] initWithDictionary:snapshot.value error:nil];
                driver.user = self.driver.user;
                [s sendNext:driver];
            } else {
                [s sendNext:nil];
            }
        }];
        return nil;
    }];
}
- (RACSignal *)listenAutoAccept {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> s) {
        [[FirebaseHelper shareInstance] addAutoAccept:^(FIRDataSnapshot * _Nullable snapshot) {
            if (snapshot && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                FCDriver* driver = [[FCDriver alloc] initWithDictionary:snapshot.value error:nil];
                [s sendNext:driver];
            } else {
                [s sendNext:nil];
            }
        }];
        return nil;
    }];
}

- (void)setDriver:(FCDriver *)driver {
    _driver = driver;
    if (!driver.user) {
        return;
    }
    [[TOManageCommunication shared] updateWithUser:driver];
}


- (void) addDriverInfoChangedListener {
    @weakify(self);
    [[[[self listenDriverChangeInfo] distinctUntilChanged] takeUntil:[self rac_willDeallocSignal]]subscribeNext:^(FCDriver *driver) {
        @strongify(self);
        if (!driver) { return; }
        self.driver = driver;
        [[UserDataHelper shareInstance] saveUserToLocal:self.driver];
        [self checkDevice:self.driver];
        [self checkingZone];
    }];
    
//    [[FirebaseHelper shareInstance] addDriverInfoChangedListener:^(FIRDataSnapshot * snapshot) {
//        if (snapshot && [snapshot.value isKindOfClass:[NSDictionary class]]) {
//            FCDriver* driver = [[FCDriver alloc] initWithDictionary:snapshot.value error:nil];
//            driver.user = self.driver.user;
//            self.driver = driver;
//            [[UserDataHelper shareInstance] saveUserToLocal:self.driver];
//
//            [self checkDevice:self.driver];
//
//            [self checkingZone];
//        }
//    }];
    
    [[FirebaseHelper shareInstance] getDriver:^(FCDriver * driver) {
        @strongify(self);
        if (driver) {
            self.driver = driver;
            
            // save curent driver
            [[UserDataHelper shareInstance] saveUserToLocal:_driver];
        }
    }];
}
- (void)addAutoAccept:(void (^)(NSNumber*))completed
{
    [[FirebaseHelper shareInstance] addAutoAccept:^(FIRDataSnapshot * _Nullable snapshot) {
        if (snapshot && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            FCDriver* driver = [[FCDriver alloc] initWithDictionary:snapshot.value error:nil];
            if (!driver) { return; }
            completed(driver.autoAccept);
        }
    }];
//    [[[[self listenAutoAccept] distinctUntilChanged] takeUntil:[self rac_willDeallocSignal]]subscribeNext:^(FCDriver *driver) {
//        if (!driver) { return; }
//        completed(driver.autoAccept);
//    }];
}

- (void) checkingZone {
    CLLocation* location = [GoogleMapsHelper shareInstance].currentLocation;
    if (location) {
        @weakify(self);
        [[FirebaseHelper shareInstance] getZoneByLocation:location.coordinate handler:^(FCZone * zone) {
            @strongify(self);
            NSString* lastAppVersion = [self getCurrentAppVersion];
            NSString* currentAppVersion = [self getAppVersion];

            if (zone.id != self.driver.zoneId || ![currentAppVersion isEqualToString:lastAppVersion]) {
                self.driver.zoneId = zone.id;
                [self apiUpdateUserData: zone.id];
                [self saveAppVersion:currentAppVersion];
            } else {
                [self updateAccount:nil complete:^(FCResponse *res, NSError *error) {
                    DLog(@"%@", [error localizedDescription]);
                }];
            }
        }];
    } else {
        [self updateAccount:nil complete:nil];
    }
    
}

- (void) updateAccount:(NSDictionary *)params complete:(void (^)(FCResponse *res,NSError *error))block {
    NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:params ?: @{}];
    FIRUser* user = [FIRAuth auth].currentUser;
    NSString* phone = user.phoneNumber;
    if (phone.length == 0 || user.uid.length == 0) {
        return;
    }
    if ([phone hasPrefix:@"+84"]) {
        phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
    }
    NSString *uid = user.uid ?: @"";
    NSString *appVersion = [self getAppVersion];
    
    [new addEntriesFromDictionary:@{@"isDriver":@(YES),
                                    @"phoneNumber":phone,
                                    @"firebaseId":uid,
                                    @"appVersion":[NSString stringWithFormat:@"%@I", appVersion] }];
    
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        NSString *token = result.token;
        if ([token length] > 0) {
            [new addEntriesFromDictionary:@{@"deviceToken": token}];
            [[FirebaseHelper shareInstance] updateDeviceToken:token];
        }
        [[APIHelper shareInstance] post:API_UPDATE_ACCOUNT
            body:new
        complete:block];
    }];
}

- (void) apiUpdateUserData: (NSInteger) zoneId {
    [self updateAccount:@{@"zoneId": @(zoneId)} complete:^(FCResponse *res, NSError *error) {
        [[FirebaseHelper shareInstance] updateZoneById:zoneId];
    }];
//    FIRUser* user = [FIRAuth auth].currentUser;
//    NSString* phone = user.phoneNumber;
//    if (phone.length == 0 || user.uid.length == 0) {
//        return;
//    }
//    if ([phone hasPrefix:@"+84"]) {
//        phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
//    }
//
//    NSString* uid = user.uid;
//    NSDictionary* body = @{@"isDriver":@(YES),
//                           @"phoneNumber":phone,
//                           @"firebaseId":uid,
//                           @"zoneId": @(zoneId),
//                           @"appVersion":[NSString stringWithFormat:@"%@I", [self getAppVersion]]};
//
//    [[APIHelper shareInstance] post:API_UPDATE_ACCOUNT
//                               body:body
//                           complete:^(FCResponse *response, NSError *e) {
//                               [[FirebaseHelper shareInstance] updateZoneById:zoneId];
//                           }];
}

- (void) addDriverOnlineChangedListener {
    [[FirebaseHelper shareInstance] addDriverOnlineListener:^(FCOnlineStatus *online) {
        DLog(@"DriverOnlineStatusChanged: %ld", (long)online.status)
        if (online.status != self.onlineStatus.status) {
            self.onlineStatus = online;
            [self apiUpdateOnlineStatus:online.status handler:^(BOOL success) {
                
            }];
        }
    }];
}

- (void) checkDevice: (FCDriver*) driver {
    if (!_alertSignout && driver.deviceInfo.id.length > 0 && [self getDeviceId].length > 0 && ![driver.deviceInfo.id isEqualToString:[self getDeviceId]]) {
        
        [[FirebaseHelper shareInstance] driverOffline:nil];
        [[FirebaseHelper shareInstance] signOut:^(NSError * _Nullable error) {
            [[TOManageCommunication shared] stop];
            [[TOManageCommunication shared] cleanUp];
            [[VatoPermission shared] cleanUp];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOutEvent" object:nil];
        }];
        
        _alertSignout = [UIAlertController showAlertInViewController:self.viewController
                                           withTitle:@"Thông báo"
                                             message:@"Tài khoản của bạn đã được đăng nhập bởi một thiết bị khác."
                                   cancelButtonTitle:@"Đóng"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                _alertSignout = nil;
                                                if (buttonIndex == 0) {
//                                                    [(AppDelegate*)[UIApplication sharedApplication].delegate loadLoginView];
                                                    [[VatoDriverUpdateLocationService shared] stopUpdate];
                                                    [[[UIApplication sharedApplication] keyWindow].rootViewController dismissViewControllerAnimated:YES completion:^{
                                                        UIViewController* startview = [[NavigatorHelper shareInstance] getViewControllerById:LOGIN_VIEW_CONTROLLER
                                                        inStoryboard:STORYBOARD_LOGIN];

                                                        [UIView transitionFromView:[[UIApplication sharedApplication] keyWindow].rootViewController.view
                                                                            toView:startview.view
                                                                          duration:0.3 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionFlipFromLeft
                                                                        completion:^(BOOL finished) {
                                                            [[UIApplication sharedApplication] keyWindow].rootViewController = startview;
                                                        }];
                                                    }];
                                                }
                                            }];
    }
}

- (void) checkInviteDynamicLink {

    // get invite code
    NSString* codeInvite = [appDelegate getInviteCode:appDelegate.inviteUrl];
    
    // goto verify view
    if (codeInvite.length > 0) {
        InviteFriendTableViewController* vc = [[UIStoryboard storyboardWithName:@"Invitation"
                                                                         bundle:nil] instantiateViewControllerWithIdentifier:@"InviteFriendTableViewController"];
        vc.homeViewModel = self;
        vc.inviteCode = codeInvite;
        FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]
                                                          initWithRootViewController:vc];
        [self.viewController presentViewController:navController
                                          animated:YES
                                        completion:nil];
        
        // release
        appDelegate.inviteUrl = nil;
    }
    
}

- (void) getTotalUnreadNotification {
    long long to = (long long)[self getCurrentTimeStamp];
    long long from = (long long) (to - limitdays);
    NSDictionary* body = @{@"from":@(from),
                           @"to" : @(to),
                           @"page":@(0),
                           @"size":@(10)};
    [[APIHelper shareInstance] get:API_GET_LIST_NOTIFY
                               params:body
                           complete:^(FCResponse *response, NSError *e) {
                               @try {
                                   NSInteger totalUnread = 0;
                                   if (response.data) {
                                       NSArray* array = [response.data objectForKey:@"notifications"];
                                       long long lastNotify = [[UserDataHelper shareInstance] getLastestNotification];
                                       if (lastNotify == 0) {
                                           totalUnread = array.count;
                                       }
                                       else {
                                           for (NSDictionary* dict in array) {
                                               long long time = [[dict objectForKey:@"createdAt"] longLongValue];
                                               if (time > lastNotify) {
                                                   totalUnread ++;
                                               }
                                           }
                                       }
                                       
                                       [self setNotifyBadge:totalUnread];
                                   }
                               }
                               @catch (NSException* e) {
                                   DLog(@"Error: %@", e)
                               }
                               
                           }];
}

- (void) setNotifyBadge: (NSInteger) badge {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    self.totalUnreadNotify = badge;
}

/*
 - Checking old account that  not login via phone provider
 */
- (void) checkingValidAuth {
    NSString* email = [FIRAuth auth].currentUser.email;
    if ([email isEqualToString:[NSString stringWithFormat:@"%@@vato.vn",PHONE_TEST]]) {
        return;
    }
    
    BOOL valid = NO;
    if ([FIRAuth auth].currentUser) {
        for (id<FIRUserInfo> provider in [FIRAuth auth].currentUser.providerData) {
            if ([provider.providerID isEqualToString:FIRPhoneAuthProviderID]) {
                valid = YES;
                break;
            }
        }
    }
    
    if (!valid) {
        @weakify(self)
        [[FirebaseHelper shareInstance] signOut:^(NSError *error) {
            @strongify(self);
            if (!error) {
                [[TOManageCommunication shared] stop];
                [[TOManageCommunication shared] cleanUp];
                [[VatoPermission shared] cleanUp];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOutEvent" object:nil];
                UIViewController* startview = [[NavigatorHelper shareInstance] getViewControllerById:LOGIN_VIEW_CONTROLLER
                                                                                        inStoryboard:STORYBOARD_LOGIN];
                startview.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self.viewController  presentViewController:startview
                                                        animated:YES
                                                      completion:nil];
            }
        }];
    }
}

- (BOOL) checkIsHaveVehicle {
    if (!self.driver.vehicle) {
        return NO;
    }
    return YES;
}
#pragma mark - APIs

/**
 Call api này để cập nhật trạng thái online ngay tức thời.
 Chỉ call nếu trạng thái thay đổi và với trạng thái "BUSY" thì không cần cập nhật

 @param status: trạng thái cần cập nhật
 */
- (void) apiUpdateOnlineStatus : (NSInteger) status
                        handler: (void (^) (BOOL success)) block {
    NSLog(@"Update Status Changed: %ld", (long)status);
    FCDriver *currentDriver = [[FirebaseHelper shareInstance] currentDriver];
    if (!currentDriver) {
        return;
    }
    
    if (!self.driver.user) {
        // Update
        self.driver = currentDriver;
    }
    
    if (self.onlineStatus && self.driver.user.id != 0) {
        @try {
            self.onlineStatus.status = status;
            self.onlineStatus.id = self.driver.user.id;
            
            CLLocation* location = [GoogleMapsHelper shareInstance].currentLocation;
            if (location && location.coordinate.latitude != 0 && location.coordinate.longitude != 0) {
                self.onlineStatus.location = [[FCLocation alloc] initWithLat:location.coordinate.latitude lon:location.coordinate.longitude];
            }
            NSDictionary* body = @{@"status": @(status),
                                   @"location": @{@"lat":@(self.onlineStatus.location.lat),
                                                  @"lon":@(self.onlineStatus.location.lon)}};
            
            [[APIHelper shareInstance] post:API_UPDATE_ONLINE_STATUS
                                       body:body
                                   complete:^(FCResponse *response, NSError *e) {
                                       if (response.status == APIStatusOK) {
                                           BOOL success = [(NSNumber*)response.data boolValue];
                                           if (block) {
                                               block(success);
                                           }
                                       }
                                       else if (block) {
                                           block (NO);
                                       }
                                   }];
        }
        @catch(NSException* e) {
            DLog(@"%@",e)
        }
    }
}

#pragma mark - Popup Notification
- (void) apiGetPromotionNow:(NSInteger) atZone complete: (void (^)(FCManifest* manifest, FCManifestPredicate* predicate)) completed {
    NSDictionary* param = @{@"zoneId": @(atZone)};
    [[APIHelper shareInstance] get:API_GET_MANIFEST_NOW params:param complete:^(FCResponse *response, NSError *e) {
        if (response.status == APIStatusOK) {
            if (completed) {
                // find predicate
                NSArray* arrManifestPredicate = (NSArray*) [response.data objectForKey:@"manifestPredicates"];
                NSMutableArray* predicates = [[NSMutableArray alloc] init];
                for (NSDictionary* dict in arrManifestPredicate) {
                    FCManifestPredicate* manifest = [[FCManifestPredicate alloc] initWithDictionary:dict error:nil];
                    if (manifest) {
                        [predicates addObject:manifest];
                    }
                }
                FCManifestPredicate* predicate = [self findManifestPredicate:predicates];

                // find manifest
                if (predicate) {
                    NSArray* arrManifest = (NSArray*) [response.data objectForKey:@"manifests"];
                    for (NSDictionary* dict in arrManifest) {
                        FCManifest* manifest = [[FCManifest alloc] initWithDictionary:dict error:nil];
                        if (manifest && manifest.id == predicate.manifestId) {
                            completed(manifest, predicate);
                            return;
                        }
                    }
                }
                
                completed (nil, nil);
            }
        }
        else if (completed) {
            completed (nil, nil);
        }
    }];
}

- (void) apiGetPromotionDetail:(NSString*) promotionId completed: (void (^)(FCNotification*)) completed {
    NSDictionary* param = @{@"id": promotionId};
    [[APIHelper shareInstance] get:API_GET_MANIFEST_DETAIL params:param complete:^(FCResponse *response, NSError *e) {
        if (response.status == APIStatusOK) {
            if (completed) {
                FCManifest* manifest = [[FCManifest alloc] initWithDictionary:response.data error:nil];
                if (manifest) {
                    FCNotification* notify = [[FCNotification alloc] init];
                    notify.title = manifest.title;
                    notify.body = manifest.description;
                    notify.createdAt = manifest.createdAt;
                    notify.bannerUrl = manifest.banner;
                    completed(notify);
                }
                else {
                    completed(nil);
                }
            }
        }
        else if (completed) {
            completed (nil);
        }
    }];
}

- (FCManifestPredicate*) findManifestPredicate:(NSMutableArray*) predicates {
    NSArray* predicateOptional = [predicates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FCManifestPredicate* f, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        if (!f.active) {
            return NO;
        }
        
        // Date
        long long timestamp = [self getCurrentTimeStamp];
        long long startDate = [DateTimeUtils atStartOfDayTimestamp:f.startDate];
        long long endDate = [DateTimeUtils atEndOfDayTimestamp:f.endDate];
        if (startDate > timestamp || endDate < timestamp) {
            return NO;
        }
        
        // Time
        float hour = [DateTimeUtils getHour:timestamp/1000];
        if (f.startTime > hour || f.endTime < hour) {
            return NO;
        }
        
        // total per day
        NSInteger counterPerDay = [self getManifestCounterPerDay:f.id];
        if (counterPerDay >= f.timesPerDay) {
            return NO;
        }
        
        // total counter
        NSInteger totalCounter = [self getManifestTotalCounter:f.id];
        if (totalCounter >= f.times) {
            return NO;
        }
        
        // cache
        [self cacheManifestInfoCounter:f.id];
        return YES;
        
    }]];
    
    if (predicateOptional.count > 0) {
        FCManifestPredicate* farePredicate = [[predicateOptional sortedArrayUsingComparator:^NSComparisonResult(FCManifestPredicate*  obj1, FCManifestPredicate* obj2) {
            return obj1.priority < obj2.priority;
        }] firstObject];
        
        return farePredicate;
    }
    
    return nil;
}

/**
 Cache counter show on day and total counter for a popup
 */
- (void) cacheManifestInfoCounter: (NSInteger) manifestId {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger counterPerDay = [self getManifestCounterPerDay:manifestId] + 1;
    NSInteger totalCounter = [self getManifestTotalCounter:manifestId] + 1;
    
    NSString* keyCounterPerDay = [NSString stringWithFormat:@"manifest-counter-per-day-%ld-%@", manifestId, [self getTimeStringByDate:[NSDate date]]];
    NSString* keyTotalCounter = [NSString stringWithFormat:@"manifest-total-counter-%ld", manifestId];
    [userDefault setObject:@(counterPerDay) forKey:keyCounterPerDay];
    [userDefault setObject:@(totalCounter) forKey:keyTotalCounter];
}

- (NSInteger) getManifestCounterPerDay: (NSInteger) manifestId {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString* keyCounterPerDay = [NSString stringWithFormat:@"manifest-counter-per-day-%ld-%@", manifestId, [self getTimeStringByDate:[NSDate date]]];
    return [[userDefault valueForKey:keyCounterPerDay] integerValue];
}

- (NSInteger) getManifestTotalCounter: (NSInteger) manifestId {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString* keyTotalCounter = [NSString stringWithFormat:@"manifest-total-counter-%ld", manifestId];
    return [[userDefault objectForKey:keyTotalCounter] integerValue];
}

#pragma mark - Push Handlers
- (void) checkingPushNotification {

    [RACObserve(appDelegate, pushData) subscribeNext:^(NSDictionary* dict) {
        if (dict) {
            UIViewController* vc = [appDelegate visibleViewController:self.viewController];
            if (vc && [vc isKindOfClass:[HomeViewController class]]) {
                [self onReceivePush:dict shouldShowBanner:NO];
            }
            else {
                [self onReceivePush:dict shouldShowBanner:YES];
            }
        }
    }];
}

- (void) onReceivePush: (NSDictionary*) dict shouldShowBanner: (BOOL) showbanner {
    @try {
        
        NSInteger type = [[dict valueForKey:@"type"] integerValue];
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if ((type != NotifyTypeChatting && type != NotifyTypeNewBooking) &&
            (state == UIApplicationStateActive || showbanner)) {
            
            NSString* body = [[[dict valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"body"];
            [self showMessageBanner:body
                             status:YES];
        }
        else {
            UIViewController* vc = nil;
            if (type == NotifyTypeDefault) {
                vc = [[FCNotifyViewController alloc] initView];
            }
            else if (type == NotifyTypeReferal) {
                vc = [[FCInvoiceManagerViewController alloc] initViewForPresent];
            }
            else if (type == NotifyTypeLink) {
                NSString* link = [dict valueForKey:@"url"];
                if (link.length > 0) {
                    if ([link containsString:@"https://id"]) {
                        [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
                            @try {
                                NSString* link = [NSString stringWithFormat:@"%@?token=%@", link, token];
                                NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                                [cookieProperties setObject:@"x-access-token" forKey:NSHTTPCookieName];
                                [cookieProperties setObject:token forKey:NSHTTPCookieValue];
                                
                                NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                                [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
                                
                                FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
                                FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
                                [[appDelegate visibleViewController:self.viewController]  presentViewController:navController animated:TRUE completion:^{
                                    [vc loadWebview:link];
                                }];
                            }
                            @catch (NSException* e) {
                                DLog(@"Error: %@", e)
                            }
                        }];
                        return;
                    }
                    else {
                        FCWebViewModel* model = [[FCWebViewModel alloc] initWithUrl:link];
                        vc = [[FCWebViewController alloc] initViewWithViewModel:model];
                    }
                }
                
                
            }
            else if (type == NotifyTypeBalance) {
                vc = [[NavigatorHelper shareInstance] getViewControllerById:@"ProfileViewController"
                                                               inStoryboard:STORYBOARD_PROFILE];
                [(ProfileViewController*) vc setHomeViewmodel:self];
            }
            else if (type == NotifyTypeUpdateApp) {
                id currVC = [appDelegate visibleViewController:self.viewController];
                if ([currVC isKindOfClass:[HomeViewController class]]) {
                    
                }
                [appDelegate checkUpdateVersion];
            }
            
            if (vc) {
                FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
                [[appDelegate visibleViewController:self.viewController]  presentViewController:navController animated:TRUE completion:nil];
            }
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
@end
