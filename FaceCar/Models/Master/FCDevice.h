//
//  FCDevice.h
//  FC
//
//  Created by facecar on 7/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCDevice : FCModel
@property(nonatomic, strong) NSString*  id;
@property(nonatomic, strong) NSString*  version;
@property(nonatomic, strong) NSString*  model;
@property(nonatomic, strong) NSString*  name;
@end
