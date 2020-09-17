//
//  FCResponse.m
//  FaceCar
//
//  Created by facecar on 5/10/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCResponse.h"

@implementation FCResponse

- (instancetype)initWithDictionary:(NSDictionary *)dict
                             error:(NSError **)err {
    self = [super initWithDictionary:dict error:err];
    if (self && !self.data) {
        self.data = [dict objectForKey:@"data"];
    }
    
    return self;
}

@end
