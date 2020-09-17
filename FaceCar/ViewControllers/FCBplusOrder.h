//
//  FCBplusOrder.h
//  FC
//
//  Created by facecar on 8/15/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBplusOrder : FCModel

@property (assign, nonatomic) NSInteger amount;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* key;
@property (assign, nonatomic) NSInteger order_id;
@property (strong, nonatomic) NSString* service_name;

@end
