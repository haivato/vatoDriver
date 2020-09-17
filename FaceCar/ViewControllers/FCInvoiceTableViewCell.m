//
//  FCInvoiceTableViewCell.m
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCInvoiceTableViewCell.h"
#import "UIView+Border.h"

@implementation FCInvoiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.lblTransType borderViewWithColor:[UIColor clearColor] andRadius:3];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void) loadData:(FCInvoice *)invoice {
    [self.invoiceId setText:invoice.description];
    [self.bgImage circleView];
    self.lblTransType.hidden = NO;
    
    NSInteger value = invoice.amount;
    NSInteger after = invoice.after;
    
    [self.lblAfter setText:[NSString stringWithFormat:@"Số dư cuối: %@đ", [self formatPrice:after withSeperator:@","]]];
    [self.lblDate setText:[self getTimeString:invoice.transactionDate withFormat:@"dd/MM | HH:mm"]];
    self.lblTransactionID.text = [NSString stringWithFormat:@"ID: %lld", invoice.id];
    
    if(invoice.status == TRANS_CANCELED) {
        self.lblTransType.text = @"Thất bại";
        [self.lblValue setTextColor:UIColorFromRGB(0xE12424)];
    }
    else if(invoice.status == TRANS_PENDING) {
        self.lblTransType.text = @"Chờ duyệt";
        self.lblTransType.textColor = UIColorFromRGB(0xF4A42C);
    }
    else {
        self.lblTransType.text = @"Thành công";
        self.lblTransType.textColor = LIGHT_GREEN;
    }
    if (invoice.accountTo == [[UserDataHelper shareInstance] getCurrentUser].user.id) {
        [self.lblValue setText:[NSString stringWithFormat:@"+%@đ", [self formatPrice:value withSeperator:@","]]];
        [self.lblValue setTextColor:LIGHT_GREEN];
        self.img.image = [UIImage imageNamed:@"deposit"];
    }
    else {
        [self.lblValue setText:[NSString stringWithFormat:@"-%@đ", [self formatPrice:value withSeperator:@","]]];
        [self.lblValue setTextColor:UIColorFromRGB(0xE12424)];
        self.img.image = [UIImage imageNamed:@"cash-in-out"];
    }
}


- (void) loadWithdraw:(FCWithdrawHistory *)invoice {
    [self.invoiceId setText:invoice.bankNote];
    [self.bgImage circleView];
    self.lblTransType.hidden = NO;
    
    NSInteger value = invoice.amount;
    
    [self.lblDate setText:[self getTimeString:invoice.createdAt withFormat:@"HH:mm\ndd/MM"]];
    
    switch (invoice.status) {
        case INITIAL:
            self.lblTransType.text = @"Chờ xử lý";
            self.lblTransType.textColor = UIColorFromRGB(0xF4A42C);
            break;
            
        case TRANSFERRED_MANUALLY:
        case TRANSFERRED_SEMI_AUTOMATIC:
            self.lblTransType.text = @"Hoàn thành";
            self.lblTransType.textColor = LIGHT_GREEN;
            break;
            
        case REJECTED_MANUALLY:
        case REJECTED_SEMI_AUTOMATIC:
            self.lblTransType.text = @"Bị từ chối";
            [self.lblValue setTextColor:UIColorFromRGB(0xE12424)];
            break;
            
        default:
            break;
    }
    
    [self.lblValue setText:[NSString stringWithFormat:@"-%@đ", [self formatPrice:value withSeperator:@","]]];
    [self.lblValue setTextColor:UIColorFromRGB(0xE12424)];
    self.img.image = [UIImage imageNamed:@"cash-in-out"];
}


@end
