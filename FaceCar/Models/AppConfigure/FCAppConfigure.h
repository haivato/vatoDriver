//
//  FCAppConfigure.h
//  FaceCar
//
//  Created by facecar on 3/12/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCHelp.h"
#import "FCMaintenance.h"
#import "FCBookingRule.h"
#import "FCLinkConfigure.h"
#import "FCBookConfigure.h"
#import "FCDriverConfig.h"
#import "FCBanking.h"

@interface FCAppConfigure : FCModel

@property (nonatomic) BOOL api_fare_settings;
@property (strong, nonatomic) NSString* push_key;
@property (strong, nonatomic) NSArray<FCHelp>* driver_help_menus; // menu tro giup
@property (strong, nonatomic) FCMaintenance* maintenance;
@property (strong, nonatomic) FCBookingRule* booking_rule_checking;
@property (strong, nonatomic) FCBookConfigure* booking_configure;
@property (strong, nonatomic) NSArray<FCLinkConfigure>* app_link_configure;
@property (strong, nonatomic) NSArray<FCLinkConfigure>* topup_configure;
@property (strong, nonatomic) NSArray<FCDriverConfig>* driver_config;
@property (strong, nonatomic) NSArray<FCBanking>* banking;

@end
