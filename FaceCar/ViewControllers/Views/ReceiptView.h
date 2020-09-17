//
//  ReceiptView.h
//  FC
//
//  Created by Son Dinh on 6/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DeliveryStatusFail,
    DeliveryStatusSuccess,
    DeliveryStatusNone,
} DeliveryStatus;

@protocol ReceipViewDelegate <NSObject>

@optional
- (void)onCloseReceipt;
@end

@interface ReceiptView : UIView
- (void) updateAddressFrom:(NSString*)address;
- (void) updateAddressTo:(NSString*)address;
- (void) updateDistance:(CGFloat)distance;
- (void) updateTime:(NSInteger)time;
- (void) updatePrice:(NSInteger)price;
- (void) updateNoteView;


@property (strong, nonatomic) id<ReceipViewDelegate> delegate;
@property (strong, nonatomic) FCBooking* book;

- (void) updatePaymentMethodTitle;
- (void)updateTextSenderPay:(NSString *)string;
- (void)setupDeliverStatus:(DeliveryStatus)status;
@end
