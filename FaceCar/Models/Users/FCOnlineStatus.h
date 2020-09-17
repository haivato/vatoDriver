//
//  FCOnlineStatus.h
//  FC
//
//  Created by facecar on 5/27/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCOnlineStatus : FCModel
@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) long long lastOnline;
@property (assign, nonatomic) NSInteger status;
@property (strong, nonatomic) FCLocation* location;
@end
