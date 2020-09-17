//
//  ZPBillHandleDelegate.h
//  ZPDK
//
//  Created by bonnpv on 11/30/16.
//  Copyright © 2016 VNG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZaloPaySDKErrorCode.h"

@protocol ZaloPaySDKDelegate <NSObject>
- (void)zalopayCompleteWithErrorCode:(ZPErrorCode)errorCode transactionId:(NSString *)transactionId;
@end
