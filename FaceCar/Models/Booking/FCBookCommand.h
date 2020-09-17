//
//  FCBookCommand.h
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCBookCommand;
@interface FCBookCommand : FCModel
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) long long time;
    
- (BOOL)isDriverStatus;
@end
