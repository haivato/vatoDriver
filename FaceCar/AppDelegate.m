//
//  AppDelegate.m
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigatorHelper.h"
#import "GoogleMapsHelper.h"
#import "IndicatorUtils.h"
#import "LoginViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <ZPDK/ZPDK/ZaloPaySDK.h>
#import "APICall.h"
#import "FCInvoiceManagerViewController.h"
#import "FCNotifyViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCWebViewController.h"
#import "InviteFriendTableViewController.h"
#import "HomeViewController.h"
#import <VatoNetwork/VatoNetwork-Swift.h>
#import <SMSVatoAuthen/SMSVatoAuthen-Swift.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "FCTrackingHelper.h"

#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
NSString * const zpTransactionUpdateNotification = @"zpTransactionUpdateNotification";
NSInteger const zaloPayId = ZALOPAY_APPID;

@import Firebase;
@import FirebaseAuth;
@import GoogleSignIn;

@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate, GIDSignInDelegate>

@property (nonatomic, strong) UIAlertController *popupUpdate;
@property (nonatomic, strong) RACDisposable * diposeFetchRequest;
@end

@implementation AppDelegate {
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[[Crashlytics class]]];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // get push data
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *j = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
        j[NotificationTap] = @YES;
        [self onReceivePush: j];
    }
    
    [FIROptions defaultOptions].deepLinkURLScheme = APP_URL_SCHEME;
    BOOL debug;
#if DEV
    debug = YES;
    NSString* firPath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info-Test" ofType:@"plist"];
    FIROptions* options = [[FIROptions alloc] initWithContentsOfFile:firPath];
    [FIRApp configureWithOptions:options];
#else
    debug = NO;
    NSString* firPath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
    FIROptions* options = [[FIROptions alloc] initWithContentsOfFile:firPath];
    [FIRApp configureWithOptions:options];
    [VatoFoodApiSettingEnvironment setWithEnvironment:VatoFoodEnvironmentProduction];
#endif
    [API configWithUse:debug];
    [API logApiWithUse:debug];
    
    FIRFirestore *db = [FIRFirestore firestore];
    FIRFirestoreSettings *settings = db.settings;
    settings.persistenceEnabled = YES;
    db.settings = settings;
    [FIRDatabase database].persistenceEnabled = YES; // local capture
    
    [SMSVatoAuthenInterface configureWithDependency:[FirebaseHelper shareInstance]];
    [GoogleMapsHelper shareInstance];
    
    [[ZaloPaySDK sharedInstance] initWithAppId:zaloPayId]; // khởi tạo ZPDK
    
    [self loadSplashView];
    
    // google sign in cofig
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
    // register notification
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        // For iOS 10 data message (sent via FCM)
        [FIRMessaging messaging].delegate = self;
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    [self connectToFcm];
    
    [[APICall shareInstance] checkingNetwork];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    return YES;
}

- (void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if ([VatoLocationManager shared].location) {
        [[VatoDriverUpdateLocationService shared] syncCloudWithLocation:[VatoLocationManager shared].location.coordinate];
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
//    NSDate *new = [[NSDate date] dateByAddingTimeInterval:1800];
//    [VatoDriverUpdateLocationService shared] sys
//    self.diposeFetchRequest = [[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh] after:new schedule:^{
//        completionHandler(UIBackgroundFetchResultNewData);
//    }];
    DLog(@"performFetchWithCompletionHandler ....")
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    if (_diposeFetchRequest) {
        [_diposeFetchRequest dispose];
    }
    [self connectToFcm];
    [[VatoLocationManager shared] startUpdatingLocation];
    // dont allow sleep
    [application setIdleTimerDisabled:YES];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllDeliveredNotifications];
    [center removeAllPendingNotificationRequests];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESUME_APP
                                                        object:nil
                                                      userInfo:nil];

    [self checkUserAvailable];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

    
- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *))restorationHandler {
    NSLog(@"%@", userActivity.webpageURL);
    __weak AppDelegate *weakSelf = self;
    
    BOOL handled = [[FIRDynamicLinks dynamicLinks]
                    handleUniversalLink:userActivity.webpageURL
                    completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                 NSError * _Nullable error) {
                        AppDelegate *strongSelf = weakSelf;
                        NSString *link = dynamicLink.url.absoluteString;
                        [strongSelf onGotInviteCode:link];
                    }];
    
    if (!handled) {
        // Show the deep link URL from userActivity.
        NSString *link = userActivity.webpageURL.absoluteString;
        [self onGotInviteCode:link];
    }
    
    return handled;
}
    
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    
    if ([[url absoluteString] containsString:@"zp-redirect"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:zpTransactionUpdateNotification object:url];
        return YES;
    }
    
    if ([[FIRAuth auth] canHandleURL:url]) {
        return YES;
    }
    
    if ([url.absoluteString hasPrefix:@"momo"]) {
        [MomoBridge handleOpenUrlWithOpen:url sourceApplication:@""];
    }
    
    return [[GIDSignIn sharedInstance] handleURL:url];
}
    
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([[FIRAuth auth] canHandleURL:url]) {
        return YES;
    }
    
    if ([url.absoluteString hasPrefix:@"momo"]) {
        [MomoBridge handleOpenUrlWithOpen:url sourceApplication:sourceApplication];
    }

    if ([[url absoluteString] containsString:@"zp-redirect"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:zpTransactionUpdateNotification object:url];
        return YES;
    }
    
    
    FIRDynamicLink *dynamicLink =
    [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    
    if (dynamicLink) {
        // Handle the deep link. For example, show the deep-linked content or
        // apply a promotional offer to the user's account.
        // [START_EXCLUDE]
        // In this sample, we just open an alert.
        NSString *link = [[dynamicLink url] absoluteString];
        [self onGotInviteCode:link];
        // [END_EXCLUDE]
        return YES;
    }
    
    return [[GIDSignIn sharedInstance] handleURL:url];
}
    
- (void) onGotInviteCode: (NSString*) inviteUrl {
    self.inviteUrl = inviteUrl;
    if (![[FIRAuth auth] currentUser]) {
        return;
    }
    
    if (self.homeViewModel) {
        [self.homeViewModel checkInviteDynamicLink];
    }
}

- (NSString*) getInviteCode : (NSString*) inviteLink {
    NSString* codeInvite;
    
    NSArray *comp1 = [inviteLink componentsSeparatedByString:@"?"];
    NSString *query = [comp1 lastObject];
    NSArray *queryElements = [query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        if (keyVal.count > 0) {
            NSString *variableKey = [keyVal objectAtIndex:0];
            NSString *value = (keyVal.count == 2) ? [keyVal lastObject] : nil;
            if ([variableKey isEqualToString:@"invitecode"]) {
                codeInvite = value;
                break;
            }
        }
    }

    return codeInvite;
}

- (void) checkUpdateVersion {
    __weak AppDelegate * const weakSelf = self;

    [[FirebaseHelper shareInstance] getAppSettings:^(FCSetting * setting) {
        if (!setting || weakSelf.popupUpdate) return;

        @autoreleasepool {
            NSString *appVersion = [weakSelf getAppVersion];
            BOOL needUpdate = [NSString differentWithCurrentVersion:appVersion compareVersion:setting.ver];
            if (!needUpdate) {
                return;
            }

            __autoreleasing UIAlertAction *aceptAction = [UIAlertAction actionWithTitle:@"Đồng ý" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                __autoreleasing NSURL *url = [NSURL URLWithString:APP_STORE];

                if ([[UIApplication sharedApplication] canOpenURL:url])  {
                    [[UIApplication sharedApplication] openURL:url];
                }

                weakSelf.popupUpdate = nil;
            }];

            __autoreleasing UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Để sau" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.popupUpdate = nil;
            }];


            if (setting.force) {
                weakSelf.popupUpdate = [UIAlertController showAlertInViewController:weakSelf.window.rootViewController
                                                                          withTitle:@"Cập nhật phiên bản mới"
                                                                            message:setting.message
                                                                  cancelButtonTitle:nil
                                                             destructiveButtonTitle:nil
                                                                  otherButtonTitles:nil
                                                                           tapBlock:nil];
                [weakSelf.popupUpdate addAction:aceptAction];
            } else {
                weakSelf.popupUpdate = [UIAlertController showAlertInViewController:weakSelf.window.rootViewController
                                                                          withTitle:@"Cập nhật phiên bản mới"
                                                                            message:setting.message
                                                                  cancelButtonTitle:nil
                                                             destructiveButtonTitle:nil
                                                                  otherButtonTitles:nil
                                                                           tapBlock:nil];
                [weakSelf.popupUpdate addAction:aceptAction];
                [weakSelf.popupUpdate addAction:cancelAction];
            }
        }
            
    }];
}

- (void) checkUserAvailable {
    if ([self isNetworkAvailable]) {
        FIRUser* user = [[FIRAuth auth] currentUser];
        if (user) {
            [user getIDTokenForcingRefresh:YES
                                completion:^(NSString* token, NSError* error) {
                                    if (error && error.code != FIRAuthErrorCodeNetworkError) {
                                        [[FIRAuth auth] signOut:nil];
                                        [self loadSplashView];
                                    }
                                }];
        }
    }
}

- (void) loadSplashView {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:@"SplashViewController" inStoryboard:STORYBOARD_LOGIN];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void) loadLoginView {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:LOGIN_VIEW_CONTROLLER inStoryboard:STORYBOARD_LOGIN];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void) loadMainView {
    [[FirebaseHelper shareInstance] getAppConfigs:^{
    }];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        
    } completion:^(BOOL finished) {
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:MAIN_VIEW_CONTROLLER inStoryboard:STORYBOARD_MAIN];
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];
    }];
}

- (UIViewController *)visibleViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        
        return [self visibleViewController:lastViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        
        return [self visibleViewController:selectedViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    
    return [self visibleViewController:presentedViewController];
}

#pragma mark - FirMessage Delegate

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void) messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    // Print full message
    NSLog(@"%@", remoteMessage.appData);
    
    [self onReceivePush:remoteMessage.appData];
}
#endif

- (void) messaging:(FIRMessaging *)messaging didRefreshRegistrationToken:(NSString *)fcmToken {
    
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    DLog(@"Token: %@", fcmToken);
}

#pragma mark - Push notification settings
- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification  {
    DLog(@"Local pushs");
}

- (void)connectToFcm {
    // Won't connect since there is no token
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
        NSString *token = result.token;
        if ([token length] == 0) {
            return;
        }
        [[FIRMessaging messaging] setShouldEstablishDirectChannel:YES];
    }];
    
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // set firebase apns token
    [[FIRMessaging messaging] setAPNSToken:deviceToken];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Disconnected from FCM");
    
    OnlineStatus status = [FirebaseHelper shareInstance].currentDriverOnlineStatus;
    if (status == DRIVER_UNREADY)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    else
    {
        // notify status
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertTitle:@"VATO Driver"];
        
        NSString *message = nil;
        if (status == DRIVER_READY)
        {
            message = @"Bạn đang TRỰC TUYẾN";
        }
        else
        {
            message = @"Bạn đang trong chuyến đi";
        }
        
        [notification setAlertBody:message];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        
        NSString* mess = @"Ứng dụng đã ẩn quá lâu, hãy mở lại để đảm bảo trạng thái TRỰC TUYẾN?";
        
        // long time online
        UILocalNotification *notificationReconnect = [[UILocalNotification alloc]init];
        [notificationReconnect setAlertTitle:@"Thông báo"];
        [notificationReconnect setAlertBody:mess];
        [notificationReconnect setFireDate:[NSDate dateWithTimeIntervalSinceNow:15*60]];
        [notificationReconnect setSoundName:@"disconnect.mp3"];
        
        
        // schedule notification
        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObjects:notification, notificationReconnect, nil]];
    }
    
    [[FIRMessaging messaging] setShouldEstablishDirectChannel:NO];
}

- (void) showNotifyLoseNetwork {
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    [notification setAlertTitle:@"VATO Driver"];
    
    OnlineStatus status = [FirebaseHelper shareInstance].currentDriverOnlineStatus;
    if (status == DRIVER_UNREADY)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    else
    {
        [notification setAlertBody:@"Đường truyền mạng có vấn đề. Kiểm tra ngay để tiếp tục TRỰC TUYẾN"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        
        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    //    if (userInfo[kGCMMessageIDKey]) {
    //        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //    }
    
    // Print full message.
    DLog(@"%@ didReceiveRemoteNotification 1: ", userInfo);
    
    [self onReceivePush:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    
     [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print full message.
    NSLog(@"didReceiveRemoteNotification 2: %@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    // Print full message `
    NSLog(@"%@", remoteMessage.appData);
    
    [self onReceivePush:remoteMessage.appData];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *json = [[[notification request] content] userInfo];
    [self onReceivePush:json];
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *json = [[[[response notification] request] content] userInfo];
    NSMutableDictionary *j = [[NSMutableDictionary alloc] initWithDictionary:json];
    j[NotificationTap] = @YES;
    [self onReceivePush:j];
    completionHandler();
}
#endif

- (void) onReceivePush: (NSDictionary*) dict {
    self.pushData = dict;
    [[UserDataHelper shareInstance] cacheCurrentPushData:dict];
    [[NotificationPushService instance] updateWithPush:dict];
}
@end
