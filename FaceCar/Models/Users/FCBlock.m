//
//  FCBlock.m
//  FC
//
//  Created by facecar on 7/31/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBlock.h"

@implementation FCBlock
@synthesize description;

- (BOOL)isEqual:(id)object {
    FCBlock *other = [FCBlock castFrom:object];
    return self.block == other.block;
}

@end
