//
//  FCTripDayTableViewCell.m
//  FC
//
//  Created by facecar on 6/24/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTripDayTableViewCell.h"
#import "NSObject+Helper.h"

@interface FCTripDayTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *labelAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblRef;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet FCLabel *lblPayment;
@property (weak, nonatomic) IBOutlet FCLabel *lblPromotion;
@property (weak, nonatomic) IBOutlet UIImageView *iconStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *serviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeLabel;

@end

@implementation FCTripDayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) updateData:(FCTripHistory *)trip {
    self.serviceNameLabel.text = [trip localizeServiceName];
    
    if (trip.tripCode) {
        [self.lblRef setText:[NSString stringWithFormat:@"Mã chuyến: %@", trip.tripCode]];
    }
    else {
        [self.lblRef setText:[NSString stringWithFormat:@""]];
    }

    if (trip.status == TripStatusCompleted) {
        self.iconStatus.hidden = NO;
        self.lblStatus.hidden = NO;
        
        if (trip.eval == 0) {
            self.iconStatus.image = [UIImage imageNamed:@"ic_evalute_3"];
            self.lblStatus.text = @"Hợp lệ";
            self.lblStatus.textColor = GREEN_COLOR;
        }
        else {
            if (trip.confirmEvaluate) {
                self.iconStatus.image = [UIImage imageNamed:@"ic_evalute_2"];
                self.lblStatus.text = @"Không hợp lệ";
                self.lblStatus.textColor = RED_COLOR;
            }
            else {
                self.iconStatus.image = [UIImage imageNamed:@"ic_evalute_1"];
                self.lblStatus.text = @"Đang chờ duyệt";
                self.lblStatus.textColor = ORANGE_COLOR ;
            }
        }
    }
    else {
        self.iconStatus.hidden = YES;
        self.lblStatus.hidden = YES;
    }
    
    // payment option
    switch (trip.payment) {
        case PaymentMethodVisa:
        case PaymentMethodMastercard:
        case PaymentMethodATM:
            self.lblPayment.text = @"  Thẻ  ";
            self.lblPayment.textColor = UIColor.whiteColor;
            self.lblPayment.backgroundColor = ORANGE_COLOR;
            break;

        case PaymentMethodVATOPay:
            self.lblPayment.text = @"  VATOPay  ";
            self.lblPayment.textColor = UIColor.whiteColor;
            self.lblPayment.backgroundColor = ORANGE_COLOR;
            break;

        default:
            self.lblPayment.text = @"  Tiền mặt  ";
            self.lblPayment.textColor = UIColor.blackColor;
            self.lblPayment.backgroundColor = LIGHT_GRAY;
            break;
    }

    // promotion
    if (trip.promotionModifierId != 0 || trip.fareClientSupport > 0) {
        self.lblPromotion.hidden = NO;
    }
    else if (trip.promotionModifierId != 0 ) {
        self.lblPromotion.hidden = NO;
    }
    else {
        self.lblPromotion.hidden = YES;
    }
    
    [self.labelTime setText:[self getTimeString:trip.createdAt]];
    
    NSMutableArray* addrsslist = [[NSMutableArray alloc] init];
    if (trip.startName) {
        [addrsslist addObject:trip.startName];
    }
    if (trip.startAddress) {
        [addrsslist addObject:trip.startAddress];

    }
    
    if (addrsslist.count > 0) {
        [self.labelAddress setText:[addrsslist componentsJoinedByString:@", "]];
    }
    else {
        [self.labelAddress setText:@"Điểm đi: không xác định"];
    }
    
    self.labelPrice.text = @"";
    self.completeLabel.text = @"";
    switch (trip.statusDetail) {
        case BookStatusClientCreateBook:
        case BookStatusDriverAccepted:
        case BookStatusClientAgreed:
        case BookStatusStarted:
            [self.completeLabel setText:@"Trong chuyến đi"];
            [self.labelPrice setTextColor:LIGHT_GREEN];
            break;
            
        case BookStatusCompleted:
            [self.labelPrice setText:[NSString stringWithFormat:@"%@đ", [self formatPrice:MAX(trip.price, trip.farePrice) + trip.additionPrice withSeperator:@","]]];
            [self.labelPrice setTextColor:LIGHT_GREEN];
            self.completeLabel.text = @"Hoàn thành";
            self.completeLabel.textColor = [UIColor colorWithRed:0/255.f green:97/255.f blue:61/255.f alpha:1.f];
            break;
        
        case BookStatusClientTimeout:
        case BookStatusClientCancelInBook:
        case BookStatusClientCancelIntrip:
            [self.completeLabel setText:@"Khách huỷ"];
            [self.completeLabel setTextColor:[UIColor orangeColor]];
            break;
            
        case BookStatusAdminCancel:
            [self.completeLabel setText:@"Admin huỷ"];
            [self.completeLabel setTextColor:[UIColor orangeColor]];
            break;
            
        case BookStatusDriverCancelInBook:
            [self.completeLabel setText:@"Tài xế bỏ qua"];
            [self.completeLabel setTextColor:[UIColor orangeColor]];
            break;
            
        case BookStatusDriverCancelIntrip:
            [self.completeLabel setText:@"Tài xế huỷ"];
            [self.completeLabel setTextColor:[UIColor orangeColor]];
            break;
            
        case BookStatusDriverMissing:
            [self.completeLabel setText:@"Nhỡ chuyến"];
            [self.completeLabel setTextColor:[UIColor orangeColor]];
            break;
        case BookStatuDeliveryFail:
            [self.labelPrice setText:[NSString stringWithFormat:@"%@đ", [self formatPrice:MAX(trip.price, trip.farePrice) + trip.additionPrice withSeperator:@","]]];
            [self.labelPrice setTextColor:LIGHT_GREEN];
            self.completeLabel.text = @"Giao hàng thất bại";
            self.completeLabel.textColor = [UIColor colorWithRed:255/255.f green:36/255.f blue:36/255.f alpha:1.f];
            break;
        default:
            [self.labelPrice setText:@""];
            [self.labelPrice setTextColor:[UIColor orangeColor]];
            break;
    }
}

@end
