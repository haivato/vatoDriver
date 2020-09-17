//
//  FCZone.h
//  FC
//
//  Created by facecar on 5/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCZone : FCModel
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* postcode;
@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) NSInteger sort;

@end
