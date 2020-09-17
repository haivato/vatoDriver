//
//  FCBookConfig.h
//  FaceCar
//
//  Created by vudang on 12/3/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCBookConfig;
@interface FCBookConfig : FCModel

@property(nonatomic, strong) NSString* city;
@property(nonatomic, assign) NSInteger max;
@property(nonatomic, assign) NSInteger min;
@property(nonatomic, assign) NSInteger minDistance;
@property(nonatomic, assign) NSInteger percent;

@end
