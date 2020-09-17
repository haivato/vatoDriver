//
//  ReceiptView.m
//  FC
//
//  Created by Son Dinh on 6/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "ReceiptView.h"
#import "NSObject+Helper.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@interface ReceiptView()
{
    
}
@property (weak, nonatomic) IBOutlet UILabel *senderPayLabel;

@property (strong, nonatomic) IBOutlet UIButton *receiptButtonDone;
@property (weak, nonatomic) IBOutlet UILabel *lblClientPay;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblPromoValue;
@property (weak, nonatomic) IBOutlet UILabel *lblSumaryPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentMethodTag;
@property (weak, nonatomic) IBOutlet UILabel *lblPromotionTag;
@property (weak, nonatomic) IBOutlet UILabel *lblTIPPrice;
@property (weak, nonatomic) IBOutlet UIView *notePaymentView;
@property (weak, nonatomic) IBOutlet UILabel *notePaymentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notePaymentDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *notePromotionView;
@property (weak, nonatomic) IBOutlet UILabel *lblPromotionNote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consPromotionNoteHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consPaymentMethodHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblPromotionNoteTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPriceAfterDiscount;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *statusDeliveryLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContraintDeliveryView;
@property (weak, nonatomic) IBOutlet UIView *viewStatusDelivery;
@property (weak, nonatomic) IBOutlet UILabel *descriptionDeliveryLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblSupplyDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelAppVersion;

// Food
@property (weak, nonatomic) IBOutlet UIStackView *foodStackView;
@property (weak, nonatomic) IBOutlet UILabel *orderFeeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderFeeTransportValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *promotionValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *bonusFoodLabel;
@property (weak, nonatomic) IBOutlet UILabel *bonusFoodTextLabel;
@property (weak, nonatomic) IBOutlet UIView *bonusView;
@property (weak, nonatomic) IBOutlet UILabel *discountShippingFee;
@property (weak, nonatomic) IBOutlet UIView *discountShippingFeeView;
@property (weak, nonatomic) IBOutlet UIView *discountAmountView;
@property (weak, nonatomic) IBOutlet UILabel *driverRevenueLabel;
@property (weak, nonatomic) IBOutlet UILabel *textOrderFeeValue;
@property (weak, nonatomic) IBOutlet UILabel *textOrderFeeTransport;
@property (weak, nonatomic) IBOutlet UIView *viewOrderFee;
@property (weak, nonatomic) IBOutlet UIView *viewGeneral;

@end

@implementation ReceiptView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.receiptButtonDone.backgroundColor = NewOrangeColor;
    self.heightContraintDeliveryView.constant = 0;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

- (void) updatePaymentMethodTag:(PaymentMethod) method {
    switch (method) {
        case PaymentMethodVisa:
        case PaymentMethodMastercard:
        case PaymentMethodATM:
            self.lblPaymentMethodTag.text = @"  Thẻ  ";
            self.lblPaymentMethodTag.textColor = UIColor.whiteColor;
            self.lblPaymentMethodTag.backgroundColor = ORANGE_COLOR;
            break;

        case PaymentMethodVATOPay:
            self.lblPaymentMethodTag.text = @"  VATOPay  ";
            self.lblPaymentMethodTag.textColor = UIColor.whiteColor;
            self.lblPaymentMethodTag.backgroundColor = ORANGE_COLOR;
            break;

        default:
            self.lblPaymentMethodTag.text = @"  Tiền mặt  ";
            self.lblPaymentMethodTag.textColor = UIColor.blackColor;
            self.lblPaymentMethodTag.backgroundColor = LIGHT_GRAY;
            break;
    }
}

- (void) updatePromotionTag: (BOOL) hasPromotion {
    if (hasPromotion) {
        self.lblPromotionTag.hidden = NO;
        self.lblPromotionTag.text = @"  Khuyến mãi  ";
    }
    else {
        self.lblPromotionTag.hidden = YES;
        self.lblPromotionTag.text = EMPTY;
    }
    if (self.book.info.discountAmount > 0) {
        self.lblPromotionTag.hidden = NO;
        self.lblPromotionTag.text = @"  Khuyến mãi  ";
    }
}

- (void) updatePaymentNoteView: (PaymentMethod) method {
    switch (method) {
        case PaymentMethodVisa:
        case PaymentMethodMastercard:
        case PaymentMethodATM:
            self.notePaymentView.hidden = NO;
            self.consPaymentMethodHeight.constant = 82;
            self.notePaymentTitleLabel.text = @"Không thu tiền mặt";
            self.notePaymentDescriptionLabel.text = @"Khách hàng thanh toán bằng thẻ, vui lòng không thu tiền mặt.";
            break;

        case PaymentMethodVATOPay:
            self.notePaymentView.hidden = NO;
            self.consPaymentMethodHeight.constant = 82;
            self.notePaymentTitleLabel.text = @"Không thu tiền mặt";
            self.notePaymentDescriptionLabel.text = @"Khách hàng thanh toán bằng VATOPay, vui lòng không thu tiền mặt.";
            break;

        default:
            self.notePaymentView.hidden = YES;
            self.consPaymentMethodHeight.constant = 0;
            self.notePaymentTitleLabel.text = nil;
            self.notePaymentDescriptionLabel.text = nil;
            break;
    }
}

- (void) updatePromotionNoteView: (NSInteger) promotionValue {
    @weakify(self);
    void(^showBox)(NSInteger) = ^(NSInteger value) {
        @strongify(self);
        if (value <= 0) { return; }
        self.notePromotionView.hidden = NO;
        self.consPromotionNoteHeight.constant = 82;
        self.lblPromotionNote.text = [NSString stringWithFormat:@"Khách hàng được khuyến mãi %@đ/chuyến. Tiền sẽ được chuyển vào tài khoản của bạn.", [self formatPrice:value withSeperator:@","]];
    };

    if ([self.book discountVato] > 0) {
        showBox([self.book discountVato]);
        return;
    }

    if (promotionValue == 0) {
        self.notePromotionView.hidden = YES;
        self.consPromotionNoteHeight.constant = 0;
    } else {
        if (self.book.info.promotionDescription.length > 0) {
               self.lblPromotionNoteTitle.text = self.book.info.promotionDescription;
           }
        showBox(promotionValue);
    }
}

- (void) updateAddressFrom:(NSString*)address
{
    if (self.book.info.tripType == BookTypeOneTouch ||
        self.book.info.tripType == BookTypeDigital) {
//        [self.labelAddressFrom setText:address];
    }
    else {
        NSMutableArray* addrs = [NSMutableArray arrayWithObjects:self.book.info.startName, self.book.info.startAddress, nil];
        NSString* addStr = [addrs componentsJoinedByString:@", "];
//        [self.labelAddressFrom setText:addStr];
    }
    
    //show appp information
    FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
    [self.labelAppVersion setText:[NSString stringWithFormat:@"%li | %@ | %@", (long)driver.user.id, APP_VERSION_STRING, self.book.info.tripId]];
}

- (void) updateAddressTo:(NSString*)address
{
    if (self.book.info.tripType == BookTypeOneTouch ||
        self.book.info.tripType == BookTypeDigital) {
//        [self.labelAddressTo setText:address];
    }
    else {
        NSMutableArray* addrs = [NSMutableArray arrayWithObjects:self.book.info.endName, self.book.info.endAddress, nil];
        NSString* addStr = [addrs componentsJoinedByString:@", "];
//        [self.labelAddressTo setText:addStr];
    }
}

- (void) updateDistance:(CGFloat)distance
{
    NSString *distanceStr = [NSString stringWithFormat:@"%.1f km", distance / 1000];
    distanceStr = [distanceStr stringByReplacingOccurrencesOfString:@"." withString:@","];
//    [self.labelReceiptDistance setText:distanceStr];
}

- (void) updateTime:(NSInteger)time
{
//    [self.labelReceiptTime setText:[NSString stringWithFormat:@"%ld phút", time / 60]];
}

- (void) updatePrice:(NSInteger)price
{
    self.foodStackView.hidden = YES;
    if (self.book.info.tripType == BookTypeDigital) {
        [self.lblClientPay setText:[self formatPrice:price withSeperator:@","]];
        [self.lblPrice setText:[NSString stringWithFormat:@"%@đ",[self formatPrice:price withSeperator:@","]]];
//        [self.lblPromoValue setText:[NSString stringWithFormat:@"-%@đ",[self formatPrice:0 withSeperator:@","]]];
        [self.lblSumaryPrice setText:[NSString stringWithFormat:@"%@đ",[self formatPrice:price withSeperator:@","]]];
        [self.lblPriceAfterDiscount setText:[NSString stringWithFormat:@"%@đ",[self formatPrice:price withSeperator:@","]]];
        
        [self updatePaymentMethodTag:PaymentMethodCash];
        [self updatePaymentNoteView:PaymentMethodCash];
        [self updatePromotionTag:NO];
        [self updatePromotionNoteView:0];
        [self updateGeneralView];
    } if ([self.book deliveryFoodMode]) {
        NSInteger originPrice = self.book.info.price;
        NSInteger totalFare = [self.book.info getBookPrice];
        NSInteger bookPrice = totalFare + self.book.info.additionPrice;
        NSInteger promotion = self.book.info.promotionValue;
        NSInteger clientSupport = MIN(self.book.info.fareClientSupport + promotion, totalFare);
        NSInteger clientpay = MAX(bookPrice - clientSupport,0);
        NSInteger priceAfterDiscount = MAX(originPrice-clientSupport, 0);
        NSInteger promoteValue = self.book.info.additionPrice + MAX(self.book.info.farePrice - self.book.info.price, 0); // = Tip từ khách + hệ thống tăng
        [self bindingDataFood];
        [self updatePromotionNoteView: self.book.info.promotionValue];
        [self updatePaymentMethodTag:self.book.info.payment];
        [self updatePaymentNoteView:self.book.info.payment];
        [self updatePromotionTag:clientSupport > 0];
    } else {
        NSInteger originPrice = self.book.info.price;
        NSInteger totalFare = [self.book.info getBookPrice];
        NSInteger bookPrice = totalFare + self.book.info.additionPrice;
        NSInteger promotion = self.book.info.promotionValue;
        NSInteger clientSupport = MIN(self.book.info.fareClientSupport + promotion, totalFare);
        NSInteger clientpay = MAX(bookPrice - clientSupport,0);
        NSInteger priceAfterDiscount = MAX(originPrice-clientSupport, 0);
        NSInteger promoteValue = self.book.info.additionPrice + MAX(self.book.info.farePrice - self.book.info.price, 0); // = Tip từ khách + hệ thống tăng
        
        [self.lblTIPPrice setText:[NSString stringWithFormat:@"%@đ",[self formatPrice:promoteValue withSeperator:@","]]];
        [self.lblClientPay setText:[self formatPrice:clientpay withSeperator:@","]];
        [self.lblPrice setText:[NSString stringWithFormat:@"%@đ",[self formatPrice:totalFare withSeperator:@","]]];
        if (clientSupport > 0)
            [self.lblPromoValue setText:[NSString stringWithFormat:@"-%@đ",[self formatPrice:clientSupport withSeperator:@","]]];
        [self.lblSumaryPrice setText:[NSString stringWithFormat:@"%@đ",[self formatPrice:bookPrice withSeperator:@","]]];// + driverSupport]];
        [self.lblPriceAfterDiscount setText:[NSString stringWithFormat:@"%@đ",[self formatPrice:originPrice withSeperator:@","]]];
        
        [self updatePaymentMethodTag:self.book.info.payment];
        [self updatePaymentNoteView:self.book.info.payment];
        [self updatePromotionTag:clientSupport > 0];
        [self updatePromotionNoteView: self.book.info.promotionValue];
        [self updateGeneralView];
    }
    [self updatePaymentMethodTitle];
}

- (void) updateNoteView {
//    self.lblNote.text = self.book.info.note;
//    self.noteView.hidden = self.book.info.note.length == 0;
}

- (void) updateGeneralView {
    [_discountShippingFeeView removeFromSuperview];
    [_discountAmountView removeFromSuperview];
}

- (void) updatePaymentMethodTitle {
    if (self.book.info.payment == PaymentMethodVATOPay) {
//        self.lblTitleReceipt.text = @"Thanh toán bằng tài khoản";
    }
    else {
//        self.lblTitleReceipt.text = @"Thu tiền khách";
    }
}

- (IBAction)onButtonDone:(id)sender {
    
    [self removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCloseReceipt)])
    {
        [self.delegate onCloseReceipt];
    }
}

- (void)setupDeliverStatus:(DeliveryStatus)status {
    CGFloat heighShowViewDelivery = 90;
    switch (status) {
        case DeliveryStatusFail:
            self.heightContraintDeliveryView.constant = heighShowViewDelivery;
            self.statusDeliveryLabel.textColor = [UIColor colorWithRed:189/255.f green:95/255.f blue:76/255.f alpha:1.f];
            self.statusDeliveryLabel.text = @"Giao hàng thất bại";
            self.descriptionDeliveryLabel.text = @"Hãy liên hệ với người nhận hoặc tổng đài hỗ trợ của VATO";
            self.viewStatusDelivery.backgroundColor = [UIColor colorWithRed:245/255.f green:236/255.f blue:243/255.f alpha:1.f];
            break;
        case DeliveryStatusSuccess:
            self.statusDeliveryLabel.textColor = [UIColor colorWithRed:136/255.f green:173/255.f blue:80/255.f alpha:1.f];
            self.heightContraintDeliveryView.constant = heighShowViewDelivery;
            self.statusDeliveryLabel.text = @"Giao hàng thành công";
            self.descriptionDeliveryLabel.text = @"Chuyến giao hàng của bạn đã hoàn thành";
            self.viewStatusDelivery.backgroundColor = [UIColor colorWithRed:237/255.f green:242/255.f blue:228/255.f alpha:1.f];
            break;
        case DeliveryStatusNone:
            self.heightContraintDeliveryView.constant = 0;
            break;
        default:
            break;
    }
}

- (void)updateTextSenderPay:(NSString *)string {
    self.senderPayLabel.text = string;
}

- (void)bindingDataFood {
    self.foodStackView.hidden = NO;
    
    [_viewGeneral setHidden:YES];
    
    self.orderFeeTransportValueLabel.text = [self formatPrice:[self.book getShipFeeOderFood]];
    if (self.book.info.payment == PaymentMethodCash) {
        self.lblClientPay.text = [self formatPrice:[self.book getTotalPriceClientPay]];
    } else {
        self.lblClientPay.text = @"0";
    }
    
    self.driverRevenueLabel.text = [self formatPrice:[self.book getDriverRevenue]];
    self.discountShippingFee.text = [self formatPrice:self.book.info.vatoDiscountShippingFee];
    self.totalLabel.text = [self formatPrice:[self.book getTotalPriceOderFood]];
    
    FCBookExtraData* extraData = self.book.extraData;
    if (extraData != nil && extraData.partnerTipping > 0) {
        self.bonusView.hidden = NO;
        self.bonusFoodLabel.text = [self formatPrice: extraData.partnerTipping];
        self.bonusFoodTextLabel.text = extraData.partnerTippingName;
    } else {
        self.bonusView.hidden = YES;
    }
    
    if (self.book.info.payment != PaymentMethodCash) {
        [_viewOrderFee removeFromSuperview];
        [_discountAmountView removeFromSuperview];
    } else {
        self.orderFeeValueLabel.text = [self formatPrice:[self.book getPriceOderFood]];
        self.promotionValueLabel.text = [self formatPrice:self.book.info.discountAmount];
    }
    
    if (self.book.info.vatoDiscountShippingFee <= 0) {
        [_discountShippingFeeView removeFromSuperview];
        self.textOrderFeeTransport.text = @"Phí vận chuyển";
    } else {
        self.textOrderFeeTransport.text = @"Phí vận chuyển (đã trừ KM)";
    }
    
    if (self.book.info.discountAmount <= 0) {
        [_discountAmountView removeFromSuperview];
         self.textOrderFeeValue.text = @"Phí đơn hàng";
    } else {
        self.textOrderFeeValue.text = @"Phí đơn hàng (đã trừ KM)";
    }
}

- (void)setBook:(FCBooking *)book {
    _book = book;
    if (book && book.info.serviceId == VatoServiceSupply) {
        long v = book.info.supplyInfo.estimatedPrice;
        NSString *price = [book formatPrice:v];
        NSString *text = [NSString stringWithFormat:@"Đơn hàng có giá trị ước tính là <b>%@</b>. Tài xế thu lại đúng <b>giá trị thực của đơn hàng</b> khi mua.", price];
        NSAttributedString *new = [NSString generateWithText:text tag:@"b" color:[UIColor blackColor] font:[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]];
        _lblSupplyDescription.attributedText = new;
    }
}

@end


