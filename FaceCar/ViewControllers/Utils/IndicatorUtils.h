//
//  IndicatorUtils.h
//  FaceCar
//
//  Created by Vu Dang on 6/3/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IndicatorUtils : NSObject
+ (void) showWithAllowDismiss: (BOOL) allow;
+ (void) show;
+ (void) dissmiss;
+ (void) showWithMessage: (NSString*) message;
@end
