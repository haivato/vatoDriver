//
//  VatoPayViewController.h
//  FC
//
//  Created by tony on 12/11/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import <UIKit/UIKit.h>
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface FCVatoPayViewController : UITableViewController
@property (nonatomic) WalletTripObjcWrapper *walletTripObjecWrapper;
@property (nonatomic) WalletPointObjcWrapper *walletPointObjcWrapper;
//WalletPointObjcWrapper
- (instancetype) init;
@end

NS_ASSUME_NONNULL_END
