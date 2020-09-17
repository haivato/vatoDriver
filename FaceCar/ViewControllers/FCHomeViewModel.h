//
//  FCHomeViewModel.h
//  FC
//
//  Created by vudang on 5/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCOnlineStatus.h"
#import "FCManifest.h"
#import "FCManifestPredicate.h"
@class FCNotification;

@interface FCHomeViewModel : NSObject

@property (strong, nonatomic) FCDriver* driver;
@property (strong, nonatomic) FCOnlineStatus* onlineStatus;
@property (assign, nonatomic) NSInteger totalUnreadNotify;

+ (FCHomeViewModel*) getInstace;
- (instancetype) initViewModelWithViewController: (UIViewController*) vc;
- (void) checkInviteDynamicLink;
- (void) setNotifyBadge: (NSInteger) badge;

- (void) apiUpdateOnlineStatus: (NSInteger) status
                       handler: (void (^) (BOOL success)) block;
- (void) apiGetPromotionNow:(NSInteger) atZone complete: (void (^)(FCManifest* manifest, FCManifestPredicate* predicate)) completed;
- (void) apiGetPromotionDetail:(NSString*) promotionId completed: (void (^)(FCNotification*)) completed;

- (BOOL) checkIsHaveVehicle;
- (void) addAutoAcceptListen;
- (void) addAutoAccept:(void (^)(NSNumber*))completed;
@end
