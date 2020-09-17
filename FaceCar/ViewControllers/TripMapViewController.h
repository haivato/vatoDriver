//
//  TripMapViewController.h
//  FC
//
//  Created by Son Dinh on 4/11/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FCBooking.h"
#import "ReceiptView.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

@interface TripMapViewController : UIViewController <CLLocationManagerDelegate>
@property(nonatomic, strong) FCBooking *booking;
@property(nonatomic, strong) ReceiptView* receiptView;
@property (nonatomic) FoodReceivePackageObjcWrapper *foodReceivePackageWrapper;
@property (nonatomic) FCBookingService* bookingService;
@property (weak, nonatomic) IBOutlet UIView *viewInfoExpress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hViewShadowFoodDetail;
@property (nonatomic) FeedbackObjcWrapper *feedbackObjcWrapper;
@property (nonatomic) FeedbackCancelResonType *typeFeedBack;
@property (weak, nonatomic) IBOutlet UIView *viewContentDetail1;
@property (nonatomic) BOOL *isFoodFail;
@property (weak, nonatomic) IBOutlet UIView *stackViewFood;

- (void) hideAlertView: (void (^) (void)) completed;
- (void) dismissChat;
- (void) dismissPackageVC: (void (^)(void))completion;
- (void) dismissDeliveryFailVC: (void (^)(void))completion;
- (void) endTrip;
- (void) didSelectCall;
- (void) didSelectChat;
- (void) startTrip;
- (void) hideView;
- (void) showReceiptView;
@end

