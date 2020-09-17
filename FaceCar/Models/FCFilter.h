//
//  FCFilter.h
//  FaceCar
//
//  Created by Vu Dang on 6/12/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCFilter : FCModel

@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) BOOL favorite;
@property (assign, nonatomic) BOOL blackList;

@end
