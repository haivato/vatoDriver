//
//  ZaloPaySDKErrorCode.h
//  ZPDK
//
//  Created by bonnpv on 11/30/16.
//  Copyright © 2016 VNG. All rights reserved.
//

#ifndef ZaloPaySDKErrorCode_h
#define ZaloPaySDKErrorCode_h

typedef enum : NSInteger {
    ZPErrorCode_Success         = 1,
    ZPErrorCode_NotInstall      = -1,
    ZPErrorCode_InvalidResponse = -2,
    ZPErrorCode_InvalidOrder    = -3,
    ZPErrorCode_UserCancel      = -4,
    ZPErrorCode_Fail            = -5,
} ZPErrorCode;


#endif /* ZaloPaySDKErrorCode_h */
