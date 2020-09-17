//
//  FCHelp.h
//  FaceCar
//
//  Created by facecar on 4/6/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCHelp;
@interface FCHelp : FCModel

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* link;
@property (assign, nonatomic) NSInteger type; // 1: link, 2: phone

@end
