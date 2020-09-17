//
//  IndicatorUtils.m
//  FaceCar
//
//  Created by Vu Dang on 6/3/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "IndicatorUtils.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@implementation IndicatorUtils

+ (void) showWithAllowDismiss: (BOOL) allow {
    
    [IndicatorUtils show];
    
//    if (allow) {
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    }
//    else {
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    }
}

+ (void) show {
    [IndicatorUtils showWithMessage:@"Đang kết nối ..."];
}

+ (void) dissmiss {
    [[LoadingManager instance] dismiss];
}

+ (void) showWithMessage:(NSString *)message {
    [[LoadingManager instance] show];
//    [[LoadingManager instance] showWithDuration:30];
//    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    
//    NSInteger w = UIScreen.mainScreen.bounds.size.width/2;
//    [SVProgressHUD setMinimumSize:CGSizeMake(w, w*2/3)];
//    [SVProgressHUD setFont:[UIFont fontWithName:@"Arial" size:20]];
//    [SVProgressHUD showWithStatus:message];
}

@end
