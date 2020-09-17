//
//  FCUser.m
//  FaceCar
//
//  Created by facecar on 5/10/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCUser.h"

@implementation FCUser
- (id) init {
    self = [super init];
    if (self) {
        self.phone = @"";
        self.email = @"";
        self.fullName = @"";
        self.avatarUrl = @"";
    }
    return self;
}

- (NSString*) getDisplayName {
    if (self.nickname.length > 0)
        return self.nickname;
    
    return self.fullName;
}

- (BOOL)isEqual:(id)object {
    FCUser *other = [FCUser castFrom:object];
    if (!other) { return NO; }
    if (![self.firebaseId isEqual:other.firebaseId]) {
        return NO;
    }
    
    if (![self.phone isEqual:other.phone]) {
        return NO;
    }
    
    if (![self.email isEqual:other.email]) {
        return NO;
    }
    
    if (![self.avatarUrl isEqual:other.avatarUrl]) {
        return NO;
    }
    
    if (![self.fullName isEqual:other.fullName]) {
        return NO;
    }
    
    if (![self.nickname isEqual:other.nickname]) {
        return NO;
    }
    
    if (self.cash != other.cash) {
        return NO;
    }
    
    if (self.coin != other.coin) {
        return NO;
    }
    
    return YES;
}
@end
