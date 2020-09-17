//
//  BookViewController.m
//  FC
//
//  Created by Son Dinh on 3/28/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "BookViewController.h"
#import "MBCircularProgressBarView.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "KYDrawerController.h"
#import "TripMapViewController.h"
#import "APICall.h"
#import "NSObject+Helper.h"
#import "GoogleMapsHelper.h"
#import "UIView+Border.h"
#import "FCGGMapView.h"
#import "FCBookingService+UpdateStatus.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
@import GoogleMaps;
extern NSDate const* _Nullable expiredReceiveTrip;
@interface BookViewController ()
{
    FCBookInfo *currentTripBook;
    NSTimer *currentTimer;
    BOOL isStopTimer, canAcceptBook, isDigitalTrip;
    FIRDatabaseHandle currentBookingListenerHandler;
    NSInteger requireAmount;
}

@property (weak, nonatomic) IBOutlet FCGGMapView *mapView;
@property (strong, nonatomic) IBOutlet MBCircularProgressBarView *timer;
@property (strong, nonatomic) IBOutlet UIButton *buttonAccept;

// address
@property (strong, nonatomic) IBOutlet UILabel *labelNameFrom;
@property (strong, nonatomic) IBOutlet UILabel *labelAddressFrom;
@property (strong, nonatomic) IBOutlet UILabel *labelNameTo;
@property (strong, nonatomic) IBOutlet UILabel *labelAddressTo;
@property (weak, nonatomic) IBOutlet UIView *viewAddressTo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consAddressToHeight;

// increase price
@property (weak, nonatomic) IBOutlet UIView *viewIncreasePrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consIncreasePriceHeight;

// promotion view
@property (weak, nonatomic) IBOutlet UIView *viewPromotion;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consPromotionHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleTipAndIncrease; // Thưởng chuyến đi xxx đ (cố định), Chuyến đi có tăng giá (1 chạm)
@property (weak, nonatomic) IBOutlet UILabel *lblTitlePromotionValue; // VATO thưởng xxx đ (cố định), Chuyến đi có thưởng (1 chạm)

// payment method
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) NSTimer* loadingTimer;

// info view
@property (weak, nonatomic) IBOutlet UILabel *lblService;
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceAndDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet FCLabel *lblPaymentMethod;
@property (weak, nonatomic) IBOutlet FCLabel *lblPromotion;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImage;
@property (weak, nonatomic) IBOutlet FCLabel *totalPricePackage;
@property (weak, nonatomic) IBOutlet UIView *viewBonus;
@property (weak, nonatomic) IBOutlet UILabel *lblBonus;

@end

@implementation BookViewController {
    FCBookingService* _bookService;
}

+ (BookViewController *) createVC {
    BookViewController *vc = [[BookViewController alloc] initWithNibName:@"BookFoodViewController" bundle:nil];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[TOManageCommunication shared] start];
    isStopTimer = NO;
    self.timer.value = WAITING_SECOND;
    FCAppConfigure* appConfigure = [FirebaseHelper shareInstance].appConfigure;
    NSInteger timeoutConfig = appConfigure.booking_configure.driver_request_booking_timeout;
    if (timeoutConfig > 0) {
        NSTimeInterval current = timeoutConfig;
        if (expiredReceiveTrip) {
            NSTimeInterval timeServer = MIN(timeoutConfig, [expiredReceiveTrip timeIntervalSinceNow]);
            if (timeServer > 0) {
                current = timeServer;
            }
        }
        self.timer.value = current;
    }
    
    _bookService = [FCBookingService shareInstance];
    
    //load data
    FCBookInfo *tripBook = _bookService.book.info;
    if (tripBook)
    {
        currentTripBook = tripBook;
    }
    
    //update round button
    [self.timer circleView:[UIColor clearColor]];
    [self setViewRoundCorner:_buttonAccept withRadius:5.0f];
    
    [self playsound:@"tripbook" withVolume:1.0f isLoop:NO];
    
    isDigitalTrip = (currentTripBook.tripType == BookTypeOneTouch);
    
    // checking can accept book or not
//    [_bookService getAmountRequire:^(CGFloat amount) {
//        if (amount == 0) {
//            @try {
//                amount = [FirebaseHelper shareInstance].appConfigs.amountRequire;
//            } @catch (NSException *exception) {
//                amount = MIN_AMOUNT_REQUIRE;
//            } @finally {
//
//            }
//        }
//        NSInteger driverAmount = extra.driverCash;
        FCBookExtra *extra = _bookService.book.extra;
        if (/*driverAmount < amount &&*/ !extra.satisfied) {
//            requireAmount = amount;
            canAcceptBook = NO;
            [_bookService updateBookStatus:BookStatusDriverDontEnoughMoney
                                  complete:nil];
        } else {
            canAcceptBook = YES;
            [self startTimer];
        }
    
        [_viewBonus setHidden: YES];
        FCBookExtraData *extraData = _bookService.book.extraData;
        if (extraData != nil) {
            [_viewBonus setHidden: NO];
            [self updateUIWithTripBonus:extraData];
        }
        [self updateButtonAccept];
        [self updateUIWithTripBook:currentTripBook];
//    }];

    // color
    self.buttonAccept.backgroundColor = NewOrangeColor;
    self.timer.backgroundColor = UIColorFromRGB(0x004D2A);
    
    //show appp information
    FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
    [self.labelAppVersion setText:[NSString stringWithFormat:@"%li | %@ | %@", (long)driver.user.id, APP_VERSION_STRING, _bookService.book.info.tripId]];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) updateButtonAccept {
    if (!canAcceptBook) {
        [self.buttonAccept setTitle:@"Số dư không đủ nhận chuyến" forState:UIControlStateNormal];
        self.timer.hidden = YES;
        
        if (_bookService.book.info.serviceId == VatoServiceExpress) {
            [self.buttonAccept setTitle:[@"Số dư không đủ nhận đơn" uppercaseString] forState:UIControlStateNormal];
        }
    }
    else {
        [self.buttonAccept setTitle:[@"Nhận chuyến" uppercaseString] forState:UIControlStateNormal];
        self.timer.hidden = NO;
        
        if (_bookService.book.info.serviceId == VatoServiceExpress) {
            [self.buttonAccept setTitle:[@"Nhận đơn" uppercaseString] forState:UIControlStateNormal];
        }
    }
}

- (void) notifyAcceptBookFailed {
    _alertView = [UIAlertController showAlertInViewController:self
                                       withTitle:@"Nhận chuyến thất bại"
                                         message:@"Nhận chuyến thất bại. Khách hàng đã huỷ chuyến này."
                               cancelButtonTitle:@"Đóng"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            _alertView = nil;
                                            [self hideView];
                                        }];
}

- (void) updateUIWithTripBonus:(FCBookExtraData*)extra
{
    double bonus = extra.partnerTipping;
    if (bonus > 0) {
        _lblBonus.text = [NSString stringWithFormat:@"%@ %@đ", extra.partnerTippingName, [self formatPrice:bonus withSeperator:@","]];
    } else {
        [_viewBonus setHidden: YES];
    }
}

- (void) updateUIWithTripBook:(FCBookInfo*)trip
{
    [self.lblService setText:[NSString stringWithFormat:@"%@",[trip localizeServiceName]]];
    [self showPriceView:trip];
    [self showAddressView:trip];
    [self showPromotionView:trip.fareDriverSupport > 0];
    [self showPaymentMethodView:trip.payment];
    [self showIncreasePriceView:(trip.farePrice != 0 && trip.farePrice > trip.price) || trip.additionPrice > 0];
    [self showMapView: trip];
    
//    self.qrCodeImage.image = [Utils generateQRCodeFrom:trip.tripId];
    self.qrCodeImage.image = [trip getIConService];
    if ([trip foodMode] == YES) {
        self.totalPricePackage.hidden = NO;
        if (trip.payment == PaymentMethodCash) {
            self.totalPricePackage.text = [NSString stringWithFormat:@" %@ ",[self formatPrice:[trip getTotalPriceOderFood]]];
        } else {
            self.totalPricePackage.text = @"  Đã thanh toán  ";
            self.totalPricePackage.backgroundColor = GREEN_COLOR;
        }
        
    } else {
        self.totalPricePackage.hidden = YES;
    }
    NSAttributedString *att = [NSString generateNoteSupplyWithStr:trip.noteTrip];
    self.noteLabel.attributedText = att;
    // promotion
    if (trip.promotionCode.length == 0 && trip.fareClientSupport == 0) {
        self.lblPromotion.hidden = YES;
        self.lblPromotion.text = EMPTY;
    }
    if (trip.getDiscountAmount > 0) {
        self.lblPromotion.hidden = NO;
        self.lblPromotion.text = @" Khuyến Mãi ";
    }
    
    // tip, promotion, increase
    if (trip.tripType == BookTypeFixed) {
        NSInteger increaseAndTip = trip.additionPrice + MAX(0, trip.farePrice - trip.price);
        NSInteger promotionValue = MIN(trip.promotionValue + trip.fareClientSupport, [trip getBookPrice]);
        
        if (increaseAndTip) {
            self.lblTitleTipAndIncrease.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:increaseAndTip withSeperator:@","]];
        }
        
        if (trip.fareDriverSupport > 0) {
            self.lblTitlePromotionValue.text = [NSString stringWithFormat:@"VATO thưởng %@đ", [self formatPrice:trip.fareDriverSupport withSeperator:@","]];
        }
    }
}

- (void) showPriceView: (FCBookInfo*) trip {
    FCAppConfigure* appConfigure = [FirebaseHelper shareInstance].appConfigure;
    BOOL hideDestination = appConfigure.booking_configure.hide_destination;
    
    if (hideDestination || isDigitalTrip) {
        self.lblPrice.hidden = YES;
        self.lblPrice.text = EMPTY;
        [self.view layoutIfNeeded];
    }
    else {
        NSInteger bookPrice = [trip getBookPrice];
        [self.lblPrice setHidden:(BOOL)bookPrice == 0];
        NSInteger offerPrice = (bookPrice + trip.additionPrice);
        [self.lblPrice setText:[NSString stringWithFormat:@"%@đ", [self formatPrice:offerPrice withSeperator:@","]]];
    }
}

- (void) showAddressView: (FCBookInfo*) trip {
    FCAppConfigure* appConfigure = [FirebaseHelper shareInstance].appConfigure;
    BOOL hideDestination = appConfigure.booking_configure.hide_destination ;

    [self.labelNameFrom setText:[trip.startName uppercaseString]];
    [self.labelAddressFrom setText:trip.startAddress];
    
    if (hideDestination) {
        self.viewAddressTo.hidden = YES;
        self.consAddressToHeight.constant = 0;
    }
    else {
        self.viewAddressTo.hidden = NO;
        self.consAddressToHeight.constant = 65;
        
        if (isDigitalTrip) {
            self.labelNameTo.text = @"CHUYẾN ĐI CHƯA CÓ ĐIỂM ĐẾN";
            self.labelAddressTo.text = EMPTY;
        } else if (currentTripBook.tripType == BookTypeDigital) {
            self.labelNameTo.text = @"CHUYẾN ĐI ĐỒNG HỒ";
            self.labelAddressTo.text = EMPTY;
        }
        else {
            if (trip.endLat == 0 && trip.endLon == 0) {
                self.labelNameTo.text = @"Chuyến đi không có điểm đến";
            } else {
                self.labelNameTo.text = [trip.endName uppercaseString];
                
            }
            self.labelAddressTo.text = trip.endAddress;
        }
    }
}

- (void) showIncreasePriceView: (BOOL) show {
    if (show) {
        self.viewIncreasePrice.hidden = NO;
        self.consIncreasePriceHeight.constant = 50;
    }
    else {
        self.viewIncreasePrice.hidden = YES;
        self.consIncreasePriceHeight.constant = 0;
    }
}

- (void) showPromotionView: (BOOL) show {
    if (show) {
        self.viewPromotion.hidden = NO;
        self.consPromotionHeight.constant = 50;
    }
    else {
        self.viewPromotion.hidden = YES;
        self.consPromotionHeight.constant = 0;
    }
}

- (void)showPaymentMethodView:(PaymentMethod)paymentMethod {
    switch (paymentMethod) {
        case PaymentMethodVisa:
        case PaymentMethodMastercard:
        case PaymentMethodATM:
            self.lblPaymentMethod.text = @"  Thẻ  ";
            self.lblPaymentMethod.textColor = UIColor.whiteColor;
            self.lblPaymentMethod.backgroundColor = ORANGE_COLOR;
            break;

        case PaymentMethodVATOPay:
            self.lblPaymentMethod.text = @"  VATOPay  ";
            self.lblPaymentMethod.textColor = UIColor.whiteColor;
            self.lblPaymentMethod.backgroundColor = ORANGE_COLOR;
            break;

        default:
            self.lblPaymentMethod.text = @"  Tiền mặt  ";
            self.lblPaymentMethod.textColor = UIColor.blackColor;
            self.lblPaymentMethod.backgroundColor = LIGHT_GRAY;
            break;
    }
}

- (void) showMapView: (FCBookInfo*) trip {
    CLLocationCoordinate2D end;
    end.latitude = trip.startLat;
    end.longitude = trip.startLon;
    CLLocationCoordinate2D start = [GoogleMapsHelper shareInstance].currentLocation.coordinate;
    
    // add driver marker
    UIImage* driverIcon = [UIImage imageNamed:[NSString stringWithFormat:@"m-car-%lu-12", (long)trip.serviceId]];
    if (driverIcon == nil) {
        FCUCar* car = [[UserDataHelper shareInstance] getCurrentUser].vehicle;
        if (car.type == VehicleTypeBike) {
            driverIcon = [UIImage imageNamed:@"m-car-8-12"];
        } else {
            driverIcon = [UIImage imageNamed:@"m-car-32-12"];
        }
    }
    
    
    [self.mapView addMarker:driverIcon location:start];
    self.mapView.padding = UIEdgeInsetsMake(0, 0, 16, 0);
    // add customer marker
    [self.mapView addMarker:[UIImage imageNamed:@"client-marker"] location:end];
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:start coordinate:end];
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
//        [[GoogleMapsHelper shareInstance] getDirection:start
//                                                 andAt:end
//                                             completed:^(FCRouter * router) {
//                                                 if (router) {
//                                                     NSString* mins = [[[router.durationText lowercaseString] stringByReplacingOccurrencesOfString:@"min" withString:@"phút"] stringByReplacingOccurrencesOfString:@"mins" withString:@"phút"];
//                                                     NSString* distance = [NSString stringWithFormat:@"%0.2f km", router.distance*1.0f / 1000.0f];
//                                                     [_lblDistanceAndDuration setText:[NSString stringWithFormat:@"%@  |  %@", mins, distance]];
//                                                     [_bookService trackingEstimateReceiveDis:router.distance
//                                                                                   receiveDur:router.duration];
//                                                     [_bookService updateBookExtra:router];
//                                                     [self.mapView drawPolyline:router.polylineEncode];
//                                                 }
//                                             }];
    if (!trip.estimatedReceiveDuration && !trip.estimatedReceiveDistance) {
        double distanceReceiveDistance = [self distanceWhenEstimateReceiveNil:&start end:&end] / 1000;
        NSString* distance = [NSString stringWithFormat:@"%0.2f km", distanceReceiveDistance*1.0f];
        NSString* tripMins = [NSString stringWithFormat:@"%0.0fmin", (distanceReceiveDistance / 30)*1.0f * 60.0f];
        NSString* mins = [[[tripMins lowercaseString] stringByReplacingOccurrencesOfString:@"min" withString:@"phút"] stringByReplacingOccurrencesOfString:@"mins" withString:@"phút"];
        [_lblDistanceAndDuration setText:[NSString stringWithFormat:@"%@  |  %@", mins, distance]];
        return;
    }
    
    NSString* tripMins = [NSString stringWithFormat:@"%0.0fmin", trip.estimatedReceiveDuration*1.0f / 60.0f];
    NSString* mins = [[[tripMins lowercaseString] stringByReplacingOccurrencesOfString:@"min" withString:@"phút"] stringByReplacingOccurrencesOfString:@"mins" withString:@"phút"];
    NSString* distance = [NSString stringWithFormat:@"%0.2f km", trip.estimatedReceiveDistance*1.0f / 1000.0f];
    [_lblDistanceAndDuration setText:[NSString stringWithFormat:@"%@  |  %@", mins, distance]];
}
- (double) distanceWhenEstimateReceiveNil: (CLLocationCoordinate2D*) start
              end: (CLLocationCoordinate2D*) end {
    if (!start && !end) {
        return 0;
    }
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:start->latitude longitude:start->longitude];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:end->latitude longitude:end->longitude];
    double distanceNotGet = [startLocation distanceFromLocation:endLocation];
    return distanceNotGet;
}

- (void)startTimer
{
    self.timer.value = WAITING_SECOND;
    FCAppConfigure* appConfigure = [FirebaseHelper shareInstance].appConfigure;
    NSInteger timeoutConfig = appConfigure.booking_configure.driver_request_booking_timeout;
    if (timeoutConfig > 0) {
        NSTimeInterval current = timeoutConfig;
        if (expiredReceiveTrip) {
            NSTimeInterval timeServer = MIN(timeoutConfig, [expiredReceiveTrip timeIntervalSinceNow]);
            if (timeServer > 0) {
                current = timeServer;
            }
        }
        self.timer.value = current;
    }
    
    FCBooking *copyBook = _bookService.book.copy;
    currentTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self
                                                   selector:@selector(playSoundAlertBook:)
                                                   userInfo:copyBook
                                                    repeats:YES];
    [currentTimer fire];
}

- (void)playSoundAlertBook: (NSTimer *)timerInfo {
    FCBooking* copyBook = (FCBooking*)[timerInfo userInfo];
    if (isStopTimer) {
        if (currentTimer)
        {
            [currentTimer invalidate];
            currentTimer = nil;
        }
        
        return;
    }
    self.timer.value -= 1.0f;
    if (self.timer.value <= 0.0f) {
        [currentTimer invalidate];
        currentTimer = nil;
        
        if (self.presentedViewController) {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
        [self hideView];
        
        [_bookService showPopupMissBook: copyBook];
        
    }
    
    if ((int)self.timer.value % 2 == 1) //vibrate 5 times from 15 -> 10
    {
        [self vibrateDevice];
    }
}

- (void)stopTimer {
    isStopTimer = YES;
    if (currentTimer) {
        [currentTimer invalidate];
        currentTimer = nil;
    }
    
    self.timer.hidden = YES;
}

- (IBAction)onBtnIgnore:(id)sender {
    _alertView = [UIAlertController showAlertInViewController:self
                                       withTitle:@"Xác nhận huỷ chuyến"
                                         message:@"Bạn thực sự muốn huỷ chuyến đi này"
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"Không"
                               otherButtonTitles:@[@"Đồng ý"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            _alertView = nil;
                                            if (buttonIndex == 2) {
                                                [_bookService updateBookStatus:BookStatusDriverCancelInBook
                                                 complete:nil];
                                                [self hideView];
                                            }
                                        }];
}

- (IBAction)onCannotAcceptBook:(id)sender {
    NSString* mess = @"Số dư VATOPAY không đủ để nhận chuyến. Vui lòng nạp thêm tiền vào tiền tín dụng nhận chuyến .";

    _alertView = [UIAlertController showAlertInViewController:self
                                       withTitle:@"Thông báo"
                                         message:mess
                               cancelButtonTitle:@"Đóng"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            _alertView = nil;
                                            if (buttonIndex == 0) {
                                                [self hideView];
                                            }
                                        }];
}

- (IBAction)onBtnAccept:(id)sender
{
    if (!canAcceptBook) {
        [self stopTimer];
        [self stopSound];
        return [self onCannotAcceptBook:sender];
    }
    
    if ([self isNetworkAvailable]) {
        [self stopTimer];
        [self stopSound];
        self.buttonAccept.hidden = YES;
        self.timer.hidden = YES;
        
        [IndicatorUtils showWithMessage:@"Đang kết nối ..."];
        [_bookService updateBookStatus:BookStatusDriverAccepted complete:^(BOOL success) {
            if (!success) {
                [_bookService showAcceptedFailed];
            } else {
                [[TOManageCommunication shared] cancelQueueWhenReceiveOtherTrip];
            }
        }];
    }
    else {
        [self showMessageBanner:@"Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra để tiếp tục nhận chuyến."
                         status:NO];
    }
}

- (void) hideView {
    [self stopSound];
    [self stopTimer];
    [self dismissLoading];
    [self dismissView];
}

- (void) hideAnyPopup:(void (^)(void))completed {
    if (_alertView && _alertView.presentedViewController != nil) {
        [_alertView dismissViewControllerAnimated:YES
                                       completion:^{
                                           _alertView = nil;
                                           if (completed) {
                                               completed();
                                           }
                                       }];
    }
    else if (completed) {
        _alertView = nil;
        completed();
    }
}

- (void) dismissView {
    [_bookService hideBookAlertView];
}

#pragma mark - Loading
- (void) showLoading {
    self.progressView.hidden = NO;
    [self startLoadProgressBar];
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(startLoadProgressBar) userInfo:nil repeats:TRUE];
    self.buttonAccept.enabled = NO;
}

- (void) dismissLoading {
    [IndicatorUtils dissmiss];
    [self.loadingTimer invalidate];
    [self.progressView setProgress:0.0 animated:NO];
    self.progressView.hidden = TRUE;
}

- (void) startLoadProgressBar {
    [self.progressView setProgress:0.0 animated:TRUE];
    [UIView animateWithDuration:5 animations:^{
        [self.progressView setProgress:1.0 animated:TRUE];
    } completion:^(BOOL finished) {
        
    }];
}

@end
