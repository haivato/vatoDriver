//
//  FCProduct.h
//  FC
//
//  Created by facecar on 5/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCModel.h"
#import "FCMCarType.h"

@interface FCProduct : FCModel

@property(assign, nonatomic) NSInteger id;
@property (assign, nonatomic) BOOL active;
@property (strong, nonatomic) NSArray<FCMCarType>* services;

@end
