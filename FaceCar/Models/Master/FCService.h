//
//  FCService.h
//  FaceCar
//
//  Created by vudang on 2/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCService : FCModel

@property(assign, nonatomic) BOOL choose;
@property(strong, nonatomic) NSArray<FCMCarType *>* cartypes;

@end
