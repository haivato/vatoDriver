//
//  FCTransferMoneyViewModel.h
//  FC
//
//  Created by facecar on 10/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCUserInfo.h"
#import "FCTransferMoney.h"

@interface FCTransferMoneyViewModel : NSObject
+ (FCTransferMoneyViewModel*) shareInstance;

- (void) apiGetPhoneDetail: (NSString*) phone block: (void (^)(FCUserInfo* user)) block;
- (void) apiTranferMoney: (FCTransferMoney*) data block: (void (^)(BOOL success)) block;
- (void) apiZalopayWithdraw: (NSString*) pin amount: (NSInteger)amount block: (void (^)(BOOL success)) block;

@end
