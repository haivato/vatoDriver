//
//  AppDelegate.h
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#import "FCBookingService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FCSetting* currentSetting;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (assign, nonatomic) BOOL shouldCheckTripBookQueue;
@property (strong, nonatomic) NSString* inviteUrl;
@property (strong, nonatomic) NSDictionary* pushData;

- (void) loadMainView;
- (void) loadLoginView;

- (NSString*) getInviteCode : (NSString*) inviteLink;
- (void) verifyInviteCode: (NSString*) inviteUrl;
- (void) showNotifyLoseNetwork;
- (UIViewController *)visibleViewController:(UIViewController *)rootViewController;

- (void) checkUpdateVersion;
@end

