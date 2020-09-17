//
//  FCNotificationSetting.h
//  FaceCar
//
//  Created by facecar on 5/2/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCNotificationSetting : FCModel

@property(assign, nonatomic) BOOL active;
@property(strong, nonatomic) NSString* message;

@end
