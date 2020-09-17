//
//  FCWalletViewModel.h
//  FC
//
//  Created by facecar on 6/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZPDK/ZPDK/ZaloPaySDK.h>

@interface FCWalletViewModel : NSObject

@property (assign, nonatomic) NSInteger amountForDeposit;
@property (assign, nonatomic) ZPErrorCode depositResult;
@property (assign, nonatomic) BOOL bplusResult;

- (instancetype) initViewModel: (UIViewController*) vc;
- (void) apiGetOder;
- (void) apiGetBplusOrder;
- (void) apiGetMyBalance: (void (^)(FCBalance* balance)) block;
@end
