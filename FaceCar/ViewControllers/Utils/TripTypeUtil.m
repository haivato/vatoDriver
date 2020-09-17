//
//  TripTypeUtil.m
//  FC
//
//  Created by facecar on 7/23/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "TripTypeUtil.h"

@implementation TripTypeUtil
+ (NSArray*) splitTripType: (NSInteger) tripType {
    NSArray* arr = @[@1,@2,@4];
    return [arr filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id s, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ([s integerValue] & tripType) == [s integerValue];
    }]];
}
@end
