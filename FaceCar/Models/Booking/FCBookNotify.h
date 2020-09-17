//
//  FCBookNotify.h
//  FaceCar
//
//  Created by facecar on 6/20/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBookNotify : FCModel
@property (strong, nonatomic) NSString* driverId;
@property (strong, nonatomic) NSString* requestId;
@property (strong, nonatomic) NSString* tripId;
@end
