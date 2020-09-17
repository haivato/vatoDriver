//
//  FCFilter.m
//  FaceCar
//
//  Created by Vu Dang on 6/12/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCFilter.h"

@implementation FCFilter

- (id) init {
    self = [super init];
    if (self) {
        self.status = DRIVER_READY;
        self.favorite = FALSE;
        self.blackList = TRUE;
    }
    
    return self;
}

@end
