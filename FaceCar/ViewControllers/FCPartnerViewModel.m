//
//  FCPartnerViewModel.m
//  FC
//
//  Created by facecar on 12/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPartnerViewModel.h"
#import "GoogleMapsHelper.h"
#import "FirebaseHelper.h"
#import "APIHelper.h"

@implementation FCPartnerViewModel

- (id) init {
    self = [super init];
    if (self) {
        [self getListData];
        [self getListMyPartner];
    }
    
    return self;
}

- (void) getListData {
    CLLocation* atLocation = [GoogleMapsHelper shareInstance].currentLocation;
    [[FirebaseHelper shareInstance] getPartners:atLocation
                                        handler:^(NSMutableArray * lst) {
                                            self.listPartner = lst;
                                        }];
}

- (NSInteger) statusForPartner: (NSInteger) partnerid {
    if (_listPartnerStatus.count > 0) {
        FCPartnerStatus* stt = [_listPartnerStatus objectForKey:@(partnerid)];
        if (stt) {
            return stt.status;
        }
    }
    
    return FCPartnerJoinStatusUnknow;
}

- (void) getListMyPartner {
    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_GET_MY_PARTNERS
                            params:nil
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                          }];
}

- (void) joinToPartner: (NSInteger) partnerid
               handler: (void (^) (NSError*)) block {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_JOIN_TO_PARTNERS
                               body:@{@"partner_id":@(partnerid)}
                           complete:^(FCResponse *response, NSError *e) {
                               [IndicatorUtils dissmiss];
                           }];
}

@end
