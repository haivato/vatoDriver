    //
//  TripMapsViewController+FoodDelivery.m
//  FC
//
//  Created by vato. on 2/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

#import "TripMapViewController+FoodDelivery.h"

@implementation TripMapViewController (FoodDelivery)

- (void)showFoodReceivePackage {
    self.foodReceivePackageWrapper = [[FoodReceivePackageObjcWrapper alloc] initWith:self];
    self.foodReceivePackageWrapper.listener = self;
    [self.foodReceivePackageWrapper presentWithBookInfo:self.booking.info
                                         bookingService:self.bookingService
                                                   type:FoodReceivePackageTypeActionReceivePackage];
}

- (void)viewPackageDetail {
    self.foodReceivePackageWrapper = [[FoodReceivePackageObjcWrapper alloc] initWith:self];
    self.foodReceivePackageWrapper.listener = self;
    [self.foodReceivePackageWrapper presentWithBookInfo:self.booking.info
                                         bookingService:self.bookingService
                                                   type:FoodReceivePackageTypeViewDetail];
}

- (void)didSelectActionWithAction:(enum FoodReceivePackageAction)action {
    switch (action) {
        case FoodReceivePackageActionCall:
            [self didSelectCall];
            break;
        case FoodReceivePackageActionMessage:
            [self didSelectChat];
            break;
        case FoodReceivePackageActionFinishStep:
            self.viewInfoExpress.hidden = NO;
            self.hViewShadowFoodDetail.constant = 40;
            self.heightOfViewBottom.constant = 190;
//            self.viewContentDetail1.hidden = NO;
            self.stackViewFood.hidden = NO;
            [self startTrip];
            break;
        default:
            break;
    }
}

- (void)deliveryFailFoodOder {
    if ([self.booking deliveryFoodMode]) {
        if (self.booking.last.status >= BookStatusDeliveryReceivePackageSuccess) {
            self.typeFeedBack = FeedbackCancelResonTypeDeliveryFoodFail;
        } else {
            self.typeFeedBack = FeedbackCancelResonTypeCancelDeliveryFood;
        }
        
    } else if (self.booking.info.serviceId == VatoServiceSupply) {
        self.typeFeedBack = FeedbackCancelResonTypeDeliveryFoodFail;
    } else {
        self.typeFeedBack = FeedbackCancelResonTypeCancelTrip;
    }
    
    self.feedbackObjcWrapper = [[FeedbackObjcWrapper alloc] initWith:self];
    [self.feedbackObjcWrapper presentVCWithTripId:self.booking.info.tripCode ?: @""
                                      serviceType:self.booking.info.serviceId ?: 0
                                         selector:self.booking.info.clientUserId ?:0
                                             type:self.typeFeedBack
                                   bookingService: self.bookingService];
    if (self.booking.info.serviceId == VatoServiceSupply) {
        @weakify(self)
        [self.feedbackObjcWrapper setDidSelectConfirm:^(NSString *description, NSInteger reasonId, NSArray<NSURL *> *urls) {
            @strongify(self)
            [IndicatorUtils show];
            CancelReason *reason = [[CancelReason alloc] init];
            reason.id = reasonId;
            reason.message = description;
            [self.bookingService updateCancelReason:reason];
            @weakify(self)
            [self.bookingService updateLastestBookingInfo:self.bookingService.book block:^(NSError *error) {
                @strongify(self)
                [IndicatorUtils dissmiss];
                [self playsound:@"cancel"];
                if (self.typeFeedBack == FeedbackCancelResonTypeCancelDeliveryFood) {
                    [self.bookingService updateBookStatus:BookStatusDriverCancelIntrip complete:nil];
                    [self hideView];
                } else {
                    [self.bookingService updateBookStatus:BookStatuDeliveryFail complete:nil];
                    self.isFoodFail = YES;
                    [self showReceiptView];
                }
            }];
        }];
    } else {
        @weakify(self)
        [self.feedbackObjcWrapper setDidSelectConfirm:^(NSString *description, NSInteger reasonId, NSArray<NSURL *> *urls) {
            @strongify(self)
            [IndicatorUtils show];
            CancelReason *reason = [[CancelReason alloc] init];
            reason.id = reasonId;
            reason.message = description;
            [self.bookingService updateCancelReason:reason];
            @weakify(self)
            [self.bookingService updateLastestBookingInfo:self.bookingService.book block:^(NSError *error) {
                @strongify(self)
                [IndicatorUtils dissmiss];
                [self playsound:@"cancel"];
                [self.bookingService updateBookStatus:BookStatuDeliveryFail complete:nil];
                self.isFoodFail = YES;
                [self showReceiptView];
            }];

        }];

    }
}

@end
