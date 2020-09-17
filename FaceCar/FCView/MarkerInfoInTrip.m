//
//  MarkerInfoInTrip.m
//  FaceCar
//
//  Created by vudang on 2/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "MarkerInfoInTrip.h"

@implementation MarkerInfoInTrip

- (instancetype) initialize {
    id view =   [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    return view;
}

- (void) loadTitle: (NSString*) duration {
    self.title.text = [[duration stringByReplacingOccurrencesOfString:@"mins" withString:@"min"] stringByReplacingOccurrencesOfString:@"min" withString:@"phút"];
}

@end
