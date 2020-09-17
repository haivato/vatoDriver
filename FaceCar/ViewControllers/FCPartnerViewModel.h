//
//  FCPartnerViewModel.h
//  FC
//
//  Created by facecar on 12/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCPartnerStatus.h"

typedef NS_ENUM(NSInteger, FCPartnerJoinStatus) {
    FCPartnerJoinStatusUnknow = -1,
    FCPartnerJoinStatusWaitingReview = 0,
    FCPartnerJoinStatusJoined = 2,
    FCPartnerJoinStatusLeft = 8,
    FCPartnerJoinStatusRejected = 16
};

@interface FCPartnerViewModel : NSObject

@property (strong, nonatomic) UIViewController* viewController;
@property (strong, nonatomic) NSMutableArray* listPartner;
@property (strong, nonatomic) NSMutableDictionary* listPartnerStatus;

- (NSInteger) statusForPartner: (NSInteger) partnerid;
- (void) joinToPartner: (NSInteger) partnerid
               handler: (void (^) (NSError*)) block ;

@end
