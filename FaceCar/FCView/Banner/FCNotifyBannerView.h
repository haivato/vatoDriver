//
//  FCNotifyBannerView.h
//  FaceCar
//
//  Created by facecar on 12/16/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCView.h"

typedef NS_ENUM(NSInteger, FCNotifyBannerType) {
    FCNotifyBannerTypeSuccess = 0,
    FCNotifyBannerTypeError = 1
};

@interface FCNotifyBannerView : FCView

+ (FCNotifyBannerView*) banner;

- (void) show: (UIView*) inview
      forType: (FCNotifyBannerType) type
     autoHide: (BOOL) autoHide
      message: (NSString*) message
   closeClick: (void (^)(void)) close
  bannerClick: (void (^)(void)) banner;

@end
