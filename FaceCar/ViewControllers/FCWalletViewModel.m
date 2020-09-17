    //
//  FCWalletViewModel.m
//  FC
//
//  Created by facecar on 6/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWalletViewModel.h"
#import "APIHelper.h"
#import "FCBplusOrder.h"

#if DEV == NO
//#import <BPlusMiniSDK/BPlusMiniSDK.h>
#endif

@interface FCWalletViewModel () <ZaloPaySDKDelegate>
@property (strong, nonatomic) UIViewController* viewController;

@end

@implementation FCWalletViewModel

- (instancetype) initViewModel: (UIViewController*) vc {
    self = [super init];
    self.viewController = vc;
    
    return self;
}

- (void) apiGetMyBalance:(void (^)(FCBalance *))block {
    [[APIHelper shareInstance] get:API_GET_BALANCE
                            params:nil
                          complete:^(FCResponse *response, NSError *e) {
                              @try {
                                 FCBalance* balance = [[FCBalance alloc] initWithDictionary:response.data
                                                                                      error:nil];
                                  block(balance);
                              }
                              @catch (NSException* e) {
                                  DLog(@"Error: %@", e)
                              }
                          }];
}

#pragma mark - Zalo Pay
- (void) apiGetOder {
    
    [IndicatorUtils show];
    NSDictionary* params = [NSDictionary dictionaryWithObjects:@[@(self.amountForDeposit), @"Nộp tiền cho tài xế"]
                                                       forKeys:@[@"amount", @"desc"]];
    [[APIHelper shareInstance] post:API_GET_ZALO_ORDER
                               body:params
                           complete:^(FCResponse *response, NSError *e) {
                               [IndicatorUtils dissmiss];
                               
                               NSString* order = [response.data objectForKey:@"zptranstoken"];
                               [self zaloPayOrder:order];
                           }];
}

- (void) zaloPayOrder: (NSString*) order {
    if (order.length > 0) {
        [ZaloPaySDK sharedInstance].delegate = self;
        [[ZaloPaySDK sharedInstance] payOrder:order];
    }
    else {
        self.depositResult = ZPErrorCode_Fail;
    }
}

- (void) zalopayCompleteWithErrorCode:(ZPErrorCode)errorCode transactionId:(NSString *)transactionId {
    self.depositResult = errorCode;
}

#pragma mark - BankPlus

- (void) apiGetBplusOrder {
    [IndicatorUtils show];
    NSDictionary* body = @{@"amount":@(self.amountForDeposit),
                           @"description":@"Nộp tiền"};
    [[APIHelper shareInstance] post:API_GET_BPLUS_ORDER
                               body:body
                           complete:^(FCResponse *response, NSError *e) {
                               DLog(@"apiGetBplusOrder: %@", response)
                               [IndicatorUtils dissmiss];
                               NSError* err;
                               FCBplusOrder* order = [[FCBplusOrder alloc] initWithDictionary:response.data
                                                                                        error:&err];
                               [self processBplusOrder:order];
                           }];
}

- (void) processBplusOrder: (FCBplusOrder*) orderInfo {
    if (!orderInfo) {
        return;
    }
   
#if DEV == NO
//    NSArray *comp = [orderInfo.key componentsSeparatedByString:@"~"];
//    NSString* merchantCode = [comp objectAtIndex:0];
//    NSString* merchantKey = [comp objectAtIndex:1];
//    NSString* accessCode = [comp objectAtIndex:2];
//
//    [BPlusSDK sharedManager].merchantSecureKey = merchantKey;
//    [BPlusSDK sharedManager].accessCode = accessCode;
//    [BPlusSDK sharedManager].merchantCode = merchantCode;
//    [BPlusSDK sharedManager].isSandbox = NO;
//    [BPlusSDK sharedManager].timeout = 30;
//    [BPlusSDK sharedManager].presentingViewController = self.viewController;
//
//    NSDictionary *payInfo = @{@"serviceName":orderInfo.service_name,
//                              @"content":orderInfo.description,
//                              @"orderId":[NSString stringWithFormat:@"%ld", (long) orderInfo.order_id],
//                              @"amount":[NSString stringWithFormat:@"%ld", (long) orderInfo.amount]};
//
//    [[BPlusSDK sharedManager] payMerchantWithInfoComplete:payInfo complete:^(BOOL isSuccess, NSInteger status) {
//        self.bplusResult = status == BPSDK_INIT_STATUS_SUCCESSED;
//        if (isSuccess)
//            NSLog(@"Thanh toán thành công stt: %ld", status);
//        else
//            NSLog(@"Thanh toán thất bại stt: %ld", status);
//    }];
#endif
}

@end
