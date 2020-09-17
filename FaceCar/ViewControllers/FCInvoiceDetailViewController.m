//
//  FCInvoiceDetailViewController.m
//  FaceCar
//
//  Created by facecar on 6/7/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCInvoiceDetailViewController.h"
#import "UserDataHelper.h"

@interface FCInvoiceDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIView *descView;

@end

@implementation FCInvoiceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.invoice) {
        [self loadData];
    }
    else if (self.withdrawData) {
        [self loadWithdraw];
    }
    else {
        [IndicatorUtils show];
        [[APIHelper shareInstance] get:API_GET_TRANS_DETAIL
                                params:@{@"id":@(self.invoiceId)}
                              complete:^(FCResponse *response, NSError *e) {
                                  [IndicatorUtils dissmiss];
                                  if (response.status == APIStatusOK) {
                                      FCInvoice* invoice = [[FCInvoice alloc] initWithDictionary:response.data
                                                                                           error:nil];
                                      if (invoice) {
                                          self.invoice = invoice;
                                          [self loadData];
                                      }
                                  }
                              }];
    }
    
    //show appp information
    FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
    [self.labelAppVersion setText:[NSString stringWithFormat:@"%li | %@", (long)driver.user.id, APP_VERSION_STRING]];
}


- (void) btnLeftClicked: (id) sender {
    if (!self.isPushedView) {
        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) loadData {
    NSInteger userid = [[UserDataHelper shareInstance] getCurrentUser].user.id;
    self.lblTitle.text = [_invoice titleTransaction];
    
    NSInteger amount = _invoice.amount;
    if (_invoice.accountFrom == userid) {
        self.lblAmount.text = [NSString stringWithFormat:@"-%@đ", [self formatPrice:amount withSeperator:@","]];
        [self.lblAmount setTextColor:UIColorFromRGB(0xE12424)];
    }
    else {
        self.lblAmount.text = [NSString stringWithFormat:@"+%@đ", [self formatPrice:amount withSeperator:@","]];
        [self.lblAmount setTextColor:LIGHT_GREEN];
    }
    
    self.lblDate.text = [self getTimeString:_invoice.transactionDate];
    self.lblIdentifier.text = [NSString stringWithFormat:@"%lld", _invoice.id];
    if (_invoice.description.length > 0) {
        self.lblDesc.text = _invoice.description;
    }
    else {
        self.descView.hidden = YES;
    }
}

- (void) loadWithdraw {
    self.lblTitle.text = @"Rút tiền về ngân hàng";
    self.lblAmount.text = [NSString stringWithFormat:@"-%@đ", [self formatPrice:_withdrawData.amount withSeperator:@","]];
    [self.lblAmount setTextColor:UIColorFromRGB(0xE12424)];
    self.lblDate.text = [self getTimeString:_withdrawData.createdAt];
    self.lblIdentifier.text = [NSString stringWithFormat:@"%lld", _withdrawData.id];
    if (_withdrawData.bankNote.length > 0) {
        self.lblDesc.text = _withdrawData.bankNote;
    }
    else {
        self.descView.hidden = YES;
    }
    
    switch (_withdrawData.status) {
        case INITIAL:
            self.lblStatus.text = @"Chờ xử lý";
            self.lblStatus.textColor = UIColorFromRGB(0xF4A42C);
            break;
            
        case TRANSFERRED_MANUALLY:
        case TRANSFERRED_SEMI_AUTOMATIC:
            self.lblStatus.text = @"Hoàn thành";
            self.lblStatus.textColor = LIGHT_GREEN;
            break;
            
        case REJECTED_MANUALLY:
        case REJECTED_SEMI_AUTOMATIC:
            self.lblStatus.text = @"Bị từ chối";
            [self.lblStatus setTextColor:UIColorFromRGB(0xE12424)];
            break;
            
        default:
            break;
    }
}

@end
