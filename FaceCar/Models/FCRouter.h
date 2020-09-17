//
//  FCRouter.h
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCRouter : FCModel
@property (strong, nonatomic) NSString* polylineEncode;
@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) NSInteger duration;
@property (strong, nonatomic) NSString* distanceText;
@property (strong, nonatomic) NSString* durationText;

- (id) init: (id) responseObj;
@end
