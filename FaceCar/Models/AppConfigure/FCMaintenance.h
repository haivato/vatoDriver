//
//  FCMaintenance.h
//  FC
//
//  Created by facecar on 4/6/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCMaintenance : FCModel
@property (assign, nonatomic) BOOL active;
@property (strong, nonatomic) NSString* message;
@end
