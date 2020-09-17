//
//  FCConfigs.h
//  FaceCar
//
//  Created by Vu Dang on 10/7/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCBookConfig.h"
#import "FCNotificationSetting.h"

@interface FCConfigs : FCModel

@property(assign, nonatomic) NSInteger masterVersion;
@property(assign, nonatomic) NSInteger amountRequire;
@property(assign, nonatomic) BOOL zalopayEnable;
@property(strong, nonatomic) FCNotificationSetting  *notification;

@end
