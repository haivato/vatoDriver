//
//  BookTripMissView.m
//  FC
//
//  Created by Son Dinh on 5/21/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "BookTripMissView.h"
#import "NSObject+Helper.h"

@interface BookTripMissView()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *labelAddressFrom;
@property (strong, nonatomic) IBOutlet UILabel *labelAddressTo;
@property (strong, nonatomic) IBOutlet UIView *orangeDot;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UILabel *labelClientPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblOnetouchTitlePrice;
@property (weak, nonatomic) IBOutlet UILabel *lblFixedTripTitlePrice;
@property (weak, nonatomic) IBOutlet FCButton *btnClose;
@property (weak, nonatomic) IBOutlet UILabel *titelLabel;

@end
@implementation BookTripMissView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

- (void)loadData:(FCBookInfo*) book
{
    //update data
    [_labelAddressFrom setText:book.startName];
    if (book.tripType == BookTypeOneTouch) {
        [_labelAddressTo setText:@"Điểm đến xác định theo lộ trình thực tế."];
        [_labelAddressTo setTextColor:[UIColor lightGrayColor]];
    }
    else {
        [_labelAddressTo setText:book.endName];
    }
    self.titelLabel.text = @"Bạn bị nhỡ chuyến xe";
    if ([book deliveryMode]) {
        self.titelLabel.text = @"Bạn bị nhỡ chuyến giao hàng";
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    NSString *text = [self formatPrice:[book getBookPrice] +book.additionPrice withSeperator:@","];
    [_labelClientPrice setText:[NSString stringWithFormat:@"%@đ", text]];
    [_labelTime setText:[self getTimeString:[self getCurrentTimeStamp] withFormat:@"dd/MM/yyyy HH:mm"]];
    
    [_labelClientPrice setHidden:book.tripType == BookTypeOneTouch];
    [_lblOnetouchTitlePrice setHidden:book.tripType != BookTypeOneTouch];
    [_lblFixedTripTitlePrice setHidden:book.tripType == BookTypeOneTouch];
}

- (IBAction)onDone:(id)sender {
    [self removeFromSuperview];
}


@end
