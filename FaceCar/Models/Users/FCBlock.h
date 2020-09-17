//
//  FCBlock.h
//  FC
//
//  Created by facecar on 7/31/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBlock : FCModel
@property (assign, nonatomic) BOOL block;
@property (strong, nonatomic) NSString* description;
@property (assign, nonatomic) long long timestamp;
@end
