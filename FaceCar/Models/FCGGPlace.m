//
//  FCGGPlace.m
//  FaceCar
//
//  Created by facecar on 4/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCGGPlace.h"

@implementation FCGGPlace
@synthesize description;

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError **)err {
    self = [super initWithDictionary:dict error:err];
    if (self) {
        if ([dict valueForKey:@"structured_formatting"]) {
            self.name = [[dict valueForKey:@"structured_formatting"] valueForKey:@"main_text"];
            self.address = [[dict valueForKey:@"structured_formatting"] valueForKey:@"secondary_text"];
        }
    }
    return self;
}
@end
