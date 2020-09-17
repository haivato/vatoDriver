//
//  FCInvoiceDetailViewController.h
//  FaceCar
//
//  Created by facecar on 6/7/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCInvoice.h"
#import "FCWithdrawHistory.h"

@interface FCInvoiceDetailViewController : FCViewController
@property (strong, nonatomic) FCInvoice* invoice;
@property (strong, nonatomic) FCWithdrawHistory* withdrawData;
@property (assign, nonatomic) NSInteger invoiceId;
@property (weak, nonatomic) IBOutlet UILabel *labelAppVersion;
@end

