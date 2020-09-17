//
//  FCUCar.m
//  FC
//
//  Created by facecar on 6/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCUCar.h"

@implementation FCUCar

- (instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super initWithDictionary:dict error:err];
    if (self) {
        [self setColorCode];
    }
    return self;
}

- (void) setColorCode {
    if ([self.color isEqualToString:@"Black"]) {
        _colorCode = Black;
    }
    else if ([self.color isEqualToString:@"White"]) {
        _colorCode = White;
    }
    else if ([self.color isEqualToString:@"Dark Grey"]) {
        _colorCode = DarkGrey;
    }
    else if ([self.color isEqualToString:@"Red"]) {
        _colorCode = Red;
    }
    else if ([self.color isEqualToString:@"Orange Red"]) {
        _colorCode = OrangeRed;
    }
    else if ([self.color isEqualToString:@"Blue"]) {
        _colorCode = Blue;
    }
    else if ([self.color isEqualToString:@"Green"]) {
        _colorCode = Green;
    }
    else if ([self.color isEqualToString:@"Yellow"]) {
        _colorCode = Yellow;
    }
    else if ([self.color isEqualToString:@"Brown"]) {
        _colorCode = Brown;
    }
    else if ([self.color isEqualToString:@"Orange"]) {
        _colorCode = Orange;
    }
    else if ([self.color isEqualToString:@"Dark Green"]) {
        _colorCode = DarkGreen;
    }
    else {
        _colorCode = White;
    }
}

- (BOOL)isEqual:(id)object {
    FCUCar *other = [FCUCar castFrom:object];
    return (other.id == self.id);
}

@end
