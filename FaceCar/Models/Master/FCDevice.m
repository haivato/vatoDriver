//
//  FCDevice.m
//  FC
//
//  Created by facecar on 7/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCDevice.h"

@implementation FCDevice

- (id) init {
    self = [super init];
    
    self.id = [self getDeviceId];
    self.name = [[UIDevice currentDevice] name];
    self.model = [[UIDevice currentDevice] model];
    self.version = [[UIDevice currentDevice] systemVersion];
    
    return self;
}

- (BOOL)isEqual:(id)object {
    FCDevice *other = [FCDevice castFrom:object];
    return [self.id isEqual:other.id];
}

@end
