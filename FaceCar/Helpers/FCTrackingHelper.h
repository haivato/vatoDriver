//
//  FCTrackingHelper.h
//  FC
//
//  Created by tony on 11/23/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
NS_SWIFT_NAME(TrackingHelper)
@interface FCTrackingHelper : NSObject

+ (void) trackEvent: (NSString*) name value: (NSDictionary*) value;

@end

NS_ASSUME_NONNULL_END
