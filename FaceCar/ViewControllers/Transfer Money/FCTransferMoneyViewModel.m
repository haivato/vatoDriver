//
//  FCTransferMoneyViewModel.m
//  FC
//
//  Created by facecar on 10/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTransferMoneyViewModel.h"
#import "APIHelper.h"

@implementation FCTransferMoneyViewModel

static FCTransferMoneyViewModel* instance = nil;

+ (FCTransferMoneyViewModel*) shareInstance {
    if (instance == nil) {
        instance = [[FCTransferMoneyViewModel alloc] init];
    }
    
    return instance;
}

- (void) apiGetPhoneDetail : (NSString*) phone block: (void (^)(FCUserInfo* user)) block {
    NSDictionary* body = @{@"phoneNumber": phone};
    [[APIHelper shareInstance] get:API_GET_USER_INFO
                            params:body
                          complete:^(FCResponse *response, NSError *e) {
                              @try {
                                  FCUserInfo* info = [[FCUserInfo alloc] initWithDictionary:response.data
                                                                                      error:nil];
                                  block(info);
                              }
                              @catch (NSException* e) {
                              }
                          }];
}

- (void) apiTranferMoney: (FCTransferMoney*) data block: (void (^)(BOOL success)) block {
    NSDictionary* body = @{@"amount":@(data.cash_amount),
                           @"phone":data.mobile,
                           @"pin":data.pin};
    
    [[APIHelper shareInstance] post:API_TRANSFER_MONEY_TO_VATO
                               body:body
                           complete:^(FCResponse *response, NSError *e) {
                               @try {
                                   block(response.status == APIStatusOK);
                               }
                               @catch (NSException* e) {
                                   DLog(@"Error: %@", e);
                               }
                          }];
}

- (void) apiZalopayWithdraw: (NSString*) pin amount: (NSInteger)amount block: (void (^)(BOOL success)) block {
    NSDictionary* body = @{@"pin": pin,
                           @"amount": @(amount)};
    [[APIHelper shareInstance] post:API_TRANSFER_MONEY_TO_ZALOPAY
                               body:body
                           complete:^(FCResponse *response, NSError *e) {
                               @try {
                                   block(response.status == APIStatusOK);
                               }
                               @catch (NSException* e) {
                                   DLog(@"Error: %@", e);
                               }
                           }];
}
@end
