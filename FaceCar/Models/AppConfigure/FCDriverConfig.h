//
//  FCDriverConfig.h
//  FC
//
//  Created by tony on 8/21/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCDriverConfig;
@interface FCDriverConfig : FCModel
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) NSInteger type;
@end
