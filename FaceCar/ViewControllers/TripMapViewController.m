//
//  TripMapViewController.m
//  FC
//
//  Created by Son Dinh on 4/11/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "TripMapViewController.h"
#import "MBSliderView.h"
#import "AppDelegate.h"
#import "NSObject+Helper.h"
#import "UIAlertController+Blocks.h"
#import "ClientProfileViewController.h"
#import "FacecarNavigationViewController.h"
#import "GoogleMapsHelper.h"
#import "ReceiptView.h"
#import "UIView+Border.h"
#import "GoogleAutoCompleteViewController.h"
#import "GoogleMapsHelper.h"
#import <FCChatHeads/FCChatHeads.h>
#import "FCChatView.h"
#import "FCGGMapView.h"
#import "TimeUtils.h"
#import "FCFareModifier.h"
#import "FCFareService.h"
#import "FirebasePushHelper.h"
#import "UIAlertController+Label.h"
#import "UITapGestureRecognizer+Tap.h"
#import "UILabel+Link.h"
#import "DigitalClockViewController.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
#import "FirebaseHelper+WaitingClientAccept.h"
#import "FCBookingService+BookStatus.h"
#import "TripMapViewController+FoodDelivery.h"
#import <SDWebImage/SDWebImage.h>
@import GoogleMaps;
#define heightViewAddressFull 248
#define heightViewAddressDefault 180
@import FirebaseAnalytics;
@import Masonry;
@import CoreLocation;
extern NSString *DriverWantToCancelTripNotification;
@interface TripMapViewController () <MBSliderViewDelegate, ReceipViewDelegate, FCChatHeadsControllerDatasource, FCChatHeadsControllerDelegate, PackageInfoListener, ExpressSuccessListener, FoodReceivePackageWrapperProtocol>
{
    BOOL isFirstTimeLoadMap;
    BOOL hasStartTrip;
    BOOL sentNotifyToCustomer;
    GMSMarker* markerStart;
    GMSMarker* markerEnd;
    GMSMarker* markerDriver;
    GMSPolyline* polyline;
    CLLocation* lastLocation;
    CGFloat zoomLevel;
    FIRDatabaseHandle currentBookingListenerHandler;
    UNUserNotificationCenter* localPushDriver;
    
    //digital trip
    BOOL isDigitalTrip;
    NSTimer *currentTimer;
    FCDigitalClockTrip* clockTrip;
    NSInteger _lastestTime;
    NSInteger _deltaDistance;
    FCFareModifier* _fareModifier;
    
    TripMapInfoView *_tripMapInfoView;
    AppDelegate* _appDelegate;
    ViewShowService *_viewShowService;
       
}

//mapview
@property (strong, nonatomic) IBOutlet FCButton *buttonLocation;
@property (strong, nonatomic) IBOutlet UIButton *buttonDirection;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiverNameLabel;

@property (weak, nonatomic) UINavigationController *naviPackageVC;
@property (weak, nonatomic) UINavigationController *deliveryFailVC;
//topview
@property (strong, nonatomic) IBOutlet UIView *topViewNormal;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelNamePickup;
@property (strong, nonatomic) IBOutlet UILabel *labelAddressPickup;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceAndPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblService;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet FCLabel *lblPaymentMethod;
@property (weak, nonatomic) IBOutlet FCLabel *lblPromotion;

@property (strong, nonatomic) IBOutlet UILabel *labelNameDestination;
@property (strong, nonatomic) IBOutlet UILabel *labelAddressDestination;
//digital trip
@property (strong, nonatomic) IBOutlet UIView *topViewDigitalClock;
@property (strong, nonatomic) IBOutlet UIView *parameterView;
@property (strong, nonatomic) IBOutlet UILabel *labelPrice;
@property (strong, nonatomic) IBOutlet UILabel *labelDistance;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UILabel *viewOderFoodLabel;

@property (strong, nonatomic) FCFareSetting *receipt;
@property (strong, nonatomic) NSArray<FCFarePredicate*> *predecates;
@property (strong, nonatomic) NSArray<FCFareModifier*> *modifiers;

//bottom view
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *labelClientName;
@property (strong, nonatomic) IBOutlet FCGGMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *sliderViewContainer;
@property (strong, nonatomic) MBSliderView *sliderView;
@property (strong, nonatomic) IBOutlet UIView *stackView;
@property (strong, nonatomic) IBOutlet UIView *cancelTripView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *avatarWidthConstraintHalf;
@property (weak, nonatomic) IBOutlet FCLabel *lblBadeChatExpress;
@property (weak, nonatomic) IBOutlet FCLabel *lblBadgeChat;

@property (strong, nonatomic) CLLocationManager* locationManager;

@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UIView *noteView;

@property (weak, nonatomic) IBOutlet UIView *lineService;
@property (weak, nonatomic) IBOutlet UIView *linePrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintViewAddress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintViewDigitalClock;
@property (weak, nonatomic) IBOutlet UIImageView *viewDot;
@property (weak, nonatomic) IBOutlet UIImageView *iconAddress;

@property (weak, nonatomic) IBOutlet UILabel *labelAppVersion;
@property (weak, nonatomic) IBOutlet UILabel *labelAppVersionExpress;
@property (nonatomic) BOOL isProcessFinishTrip;
@property (weak, nonatomic) IBOutlet UILabel *viewOderFoodDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblDetailPay;
@property (weak, nonatomic) IBOutlet UILabel *viewOderFoodDetail1;
@property (weak, nonatomic) IBOutlet UIView *viewFoodDetail;
@property (weak, nonatomic) IBOutlet UIButton *buttonCallMerchant;
@property (weak, nonatomic) IBOutlet UIView *vShadowFoodDetail;
@property (weak, nonatomic) IBOutlet UIView *viewFoodDetailBottom;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageViewFood;
@property (weak, nonatomic) IBOutlet UILabel *lblClientNameFood;
@property (weak, nonatomic) IBOutlet FCLabel *lbBadgetChatFood;
@property (weak, nonatomic) IBOutlet UIView *cancelTripViewFood;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarFoodWidthConstraintHalf;
@property (weak, nonatomic) IBOutlet FCView *viewDigitalClock;
@property (weak, nonatomic) IBOutlet UIView *vButtonDirection;
@property (strong, nonatomic) UILabel *showTextSerivce;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleExpress;
@property (assign, nonatomic) PaymentMethod currentMethod;
@end

@implementation TripMapViewController {
    FCChatView* _chatView;
    FCChatViewModel* _chatViewModel;
    FCClient* _client;
    UIAlertController* _alertView;
   
}

- (BOOL)isAPIFareSettings {
    return [FirebaseHelper shareInstance].appConfigure.api_fare_settings;
}

- (void)setBooking:(FCBooking *)booking {
    _booking = booking;
    _currentMethod = booking.info.payment;
    NSAssert(booking, @"Check logic");
    NSAssert(booking.info, @"Check info");
}

- (void) setupDisplay {
    if (self.booking != nil)
    {
        // add marker on maps
        [self addMarkerDriver];
        [self addMarkerStart];
        
        isDigitalTrip = (self.booking.info.tripType == BookTypeOneTouch);
        
        //client info
        [self.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.avatarImageViewFood setContentMode:UIViewContentModeScaleAspectFill];
        [[FirebaseHelper shareInstance] getClient: self.booking.info.clientFirebaseId
                                          handler:^(FCClient * client) {
                                              _client = client;
                                              
                                              //avatar
                                              [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:client.photo] placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
                                              
                                              _avatarImageView.layer.cornerRadius = _avatarImageView.frame.size.height /2;
                                              _avatarImageView.layer.masksToBounds = YES;
                                              _avatarImageView.layer.borderWidth = 0;
            
            [_avatarImageViewFood sd_setImageWithURL:[NSURL URLWithString:client.photo] placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
            
            _avatarImageViewFood.layer.cornerRadius = _avatarImageViewFood.frame.size.height /2;
            _avatarImageViewFood.layer.masksToBounds = YES;
            _avatarImageViewFood.layer.borderWidth = 0;

                                              [_labelClientName setText:[client.user getDisplayName]];
            self.lblClientNameFood.text = self.labelClientName.text;
            
                                          }];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        [self updatePriceView: [self.bookingService isTripStarted: self.booking]];
        [self updateNoteView];
        
        if ([self.booking deliveryMode]) {
            self.senderNameLabel.text = self.booking.info.senderName;
            self.receiverNameLabel.text = self.booking.info.receiverName;
        }
        
        if (self.booking.info.serviceId == VatoServiceSupply) {
            _lblTitleExpress.text = @"Thông tin người đặt";
        }
        if ([self.bookingService isTripStarted:self.booking]) {
            [[AddDestinationCommunication shared] listenChangeDestination];
        }
    } else {
        NSAssert(NO, @"CHeck Logic");
    }
    
    MBSliderView *sliderView = [[MBSliderView alloc] initWithFrame:CGRectZero];
    
    UIColor *color = [UIColor clearColor];
    [sliderView setBackgroundColor:color];
    [sliderView setFont:[UIFont fontWithName:@"Roboto-Regular" size:21.0f]];
    [sliderView setThumbImage:[UIImage imageNamed:@"logo-transparent"]];
    [sliderView setTextAlignment:NSTextAlignmentCenter];
    sliderView.shouldAlignSliderThumb = NO;
    [sliderView setDelegate:self];
    self.sliderView = sliderView;
    [self.sliderViewContainer addSubview:sliderView];
    
    self.sliderViewContainer.backgroundColor = NewOrangeColor;
    //update round corner
    [self setViewRoundCorner:self.sliderViewContainer withRadius:self.sliderViewContainer.frame.size.height/2];
    
    // register notification
    [self registerNotification];
    
    if (!isDigitalTrip)
    {
        [_addressView removeFromSuperview];
        [_topViewDigitalClock removeFromSuperview];
    }
    
    // load lastest trip status
    // checking trip is starting or receive visitor
    [self loadLastestTripStatus];
    
    //show appp information
    FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
    [self.labelAppVersion setText:[NSString stringWithFormat:@"%li | %@ | %@", (long)driver.user.id, APP_VERSION_STRING, self.booking.info.tripId]];
    [self.labelAppVersionExpress setText:[NSString stringWithFormat:@"%li | %@ | %@", (long)driver.user.id, APP_VERSION_STRING, self.booking.info.tripId]];
    
    if ([self.booking deliveryFoodMode]) {
        self.heightOfViewBottom.constant = 190;
        self.hViewShadowFoodDetail.constant = 40;
    } else {
        self.heightOfViewBottom.constant = 190;
        self.hViewShadowFoodDetail.constant = 0;
    }
    
    if (self.booking.info.tripType == BookTypeDigital) {
        self.stackView.hidden = YES;
        self.viewDigitalClock.hidden = NO;
    }
    
    [self isStatusStartedAndServiceFood];
    
    [self.view layoutIfNeeded];
    

    UIColor *orangeColor = [UIColor colorWithRed:238/255.0 green:82/255.0 blue:32/255.0 alpha:1.0];
    
    NSString *priceFood = [self formatPrice:[self.booking getMerchantFinalPrice]];

    self.viewOderFoodDetail1.text = [NSString stringWithFormat:@"Xem đơn hàng - %@", priceFood];
    
    self.vShadowFoodDetail.backgroundColor = [UIColor clearColor];
    self.vShadowFoodDetail.layer.shadowOpacity = 0.7;
    self.vShadowFoodDetail.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.vShadowFoodDetail.layer.shadowColor = [UIColor blackColor].CGColor;
    self.vShadowFoodDetail.layer.shadowRadius = 4.0f;
    self.viewFoodDetailBottom.backgroundColor = [UIColor whiteColor];
    self.viewFoodDetailBottom.layer.cornerRadius = self.viewFoodDetailBottom.frame.size.height/2;

    self.viewOderFoodDetail.text = [NSString stringWithFormat:@"Xem đơn hàng - %@", priceFood];
    self.lblDetailPay.text = (self.booking.info.payment != PaymentMethodCash) ?  @"Đã thanh toán" : @"Trả tiền hàng cho cửa hàng";
    self.lblDetailPay.text = self.lblDetailPay.text.uppercaseString;
    self.lblDetailPay.textColor = (self.booking.info.payment != PaymentMethodCash) ? orangeColor : [UIColor darkGrayColor];
    self.viewFoodDetail.hidden = ![self.booking deliveryFoodMode];
    [self checkChangeBookInfo];
    
    [self.buttonDirection setTitleColor:orangeColor forState:UIControlStateNormal];
    self.buttonDirection.backgroundColor = [UIColor whiteColor];
    self.buttonDirection.clipsToBounds = YES;
    self.buttonDirection.layer.cornerRadius = 21;
    self.vButtonDirection.backgroundColor = [UIColor clearColor];
    self.vButtonDirection.layer.shadowOpacity = 0.2;
    self.vButtonDirection.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.vButtonDirection.layer.shadowColor = [UIColor blackColor].CGColor;
    self.vButtonDirection.layer.shadowRadius = 4.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showTextSerivce = [[UILabel alloc] init];
    _showTextSerivce.backgroundColor = [UIColor whiteColor];
    self.showTextSerivce.text = @"";
    self.viewDigitalClock.hidden = YES;
    self.stackViewFood.hidden = YES;
    self.buttonCallMerchant.hidden = YES;
    self.heightConstraintViewAddress.constant = heightViewAddressDefault;
    self.heightConstraintViewDigitalClock.constant = heightViewAddressDefault;
    [self.viewDot setHidden:true];
    
    isFirstTimeLoadMap = NO;
    hasStartTrip = NO;
    lastLocation = [GoogleMapsHelper shareInstance].currentLocation;
    self.bookingService = [FCBookingService shareInstance];
    self.viewInfoExpress.hidden = YES;
    self.viewContentDetail1.hidden = YES;
    [self initMaps];
    [self initTripMapInfoView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupDisplay];
    });
    
    self.hViewShadowFoodDetail.constant = 0;
    self.avatarImageViewFood.layer.cornerRadius = self.avatarImageViewFood.frame.size.height / 2;
}

- (void) hideAlertView {
    [self hideAlertView:nil];
}

- (void) hideAlertView: (void (^) (void)) completed {
    if (_alertView) {
        [_alertView dismissViewControllerAnimated:YES
                                       completion:^{
                                           if (completed) {
                                               completed ();
                                           }
                                       }];
    }
    else if (completed) {
        completed ();
    }
}

- (void) registerNotification {
    
    if (isDigitalTrip) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate:) name:NOTIFICATION_UPDATE_LOCATION_RAPIDLY object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate:) name:NOTIFICATION_UPDATE_LOCATION object:nil];
    }
}

- (void) removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_UPDATE_LOCATION_RAPIDLY
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_UPDATE_LOCATION
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_RESUME_APP
                                                  object:nil];
}

- (void)viewDidLayoutSubviews
{
    CGRect rect = self.sliderViewContainer.frame;
    [self.sliderView setFrame:CGRectMake(10.0f, 0.0f, rect.size.width - 20.0f, rect.size.height)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_cancelTripView == nil) {
        _avatarWidthConstraintHalf.active = YES;
    }
    if (_cancelTripViewFood == nil) {
        _avatarFoodWidthConstraintHalf.active = YES;
    }
    
    if (!_chatView) {
        [self initChatView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_LOCATION object:nil];
}

- (void)initTripMapInfoView {
    _tripMapInfoView = [[[NSBundle mainBundle] loadNibNamed:@"TripMapInfoView" owner:self options:nil] firstObject];
    [_tripMapInfoView initRibWrapperWithController:self];
    _tripMapInfoView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = @{
        @"tripMapInfoView" : _tripMapInfoView
    };
    
    [self.view addSubview:_tripMapInfoView];
    
    NSArray* c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tripMapInfoView]-0-|" options:kNilOptions metrics:nil views:viewsDictionary];
    NSArray* c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tripMapInfoView]" options:kNilOptions metrics:nil views:viewsDictionary];
    [self.view addConstraints:c1];
    [self.view addConstraints:c2];
    [self.view layoutIfNeeded];
    
    [self.topViewNormal setHidden:YES];
    [_tripMapInfoView setupDisplayWithItem:self.booking];
    [_tripMapInfoView setHidden:NO];
    if (self.booking.info.serviceId == VatoServiceSupply) {
        TripMapSupplyInfoView *new = [TripMapSupplyInfoView showIn:self.view after:_tripMapInfoView price:self.booking.info.supplyInfo.estimatedPrice description:self.booking.info.supplyInfo.productDescription];
        @weakify(self);
        [[new.btnReview rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            TripNoteDetailVC *vc = (TripNoteDetailVC *)[[UIStoryboard storyboardWithName:@"TripManager" bundle:nil] instantiateViewControllerWithIdentifier:@"TripNoteDetailVC"];
            vc.booking = self.booking;
            FacecarNavigationViewController *navi = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
            navi.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navi animated:YES completion:nil];
        }];
    }
    
    @weakify(self);
    [_tripMapInfoView setShowAlert:^(UITapGestureRecognizer * tap) {
         @strongify(self);
        [self showAlertNote:tap];
    }];
    
    if (_viewShowService == nil) {
        _viewShowService = [[[NSBundle mainBundle] loadNibNamed:@"ViewShowService"  owner:self options:nil] firstObject];
        [self.view addSubview:_viewShowService];
        [_viewShowService mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tripMapInfoView.mas_left).inset(16);
            make.top.equalTo(_tripMapInfoView.mas_bottom).inset(16);
            make.height.mas_equalTo(66);
            make.width.mas_equalTo(66);
        }];
        UIImage *btnImage = [self.booking.info getIConService];
        [_viewShowService.btService setImage:btnImage forState:UIControlStateNormal];
        _viewShowService.txService = [NSString stringWithFormat:@"Đây là dịch vụ\n%@",[self.booking.info localizeServiceName]];
        
    }
    
    [_viewShowService setOpen:^{
        @strongify(self);
        [self openShowService];
    }];
    
    [_viewShowService setClose:^{
        @strongify(self);
        [self closeShowService];
    }];
    
    if (self.booking.info.serviceId != 512) {
        [[[[FCBookingService shareInstance] changePaymentMethod] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            FCBooking *book = [FCBookingService shareInstance].book;
            [_tripMapInfoView updatePriceViewWithStarted:[self.bookingService isTripStarted: book] booking:book hideTarget:NO];
            if ([book last].status >= BookStatusStarted) {
                [_tripMapInfoView startTripWithItem:book];
            } 
            
        }];
    }
}

- (void) openShowService {
    [UIView animateWithDuration:0.5 animations:^{
        [_viewShowService mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@200);
        }];
        [self.view layoutIfNeeded];
    }];
}
- (void) closeShowService {
    [UIView animateWithDuration:0.5 animations:^{
        [_viewShowService mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@66);
        }];
        [self.view layoutIfNeeded];
    }];
}

- (void) showAlertNote:(UITapGestureRecognizer*) tap {
    [self scanerPhoneNumber:self.booking.info.note complete:^(NSString *phone, NSRange range) {
        if (phone.length > 0) {
            if ([tap didTapAttributedTextInLabel:_tripMapInfoView.lbNote inRange:range]) {
                [self callPhone:phone];
                return;
            }
        }
        
        [self hideAlertView:^{
            _alertView = [UIAlertController showAlertInViewController:self
                                                            withTitle:self.booking.info.note
                                                              message:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"OK"
                                                    otherButtonTitles:nil
                                                             tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex) {
                                                                 _alertView = nil;
                                                             }];
            
            _alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
            _alertView.messageLabel.userInteractionEnabled = YES;
            
            NSString* text = self.booking.info.note;
            if (phone.length > 0) {
                [_alertView.messageLabel underlineText:text atRange:range];
                UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topupPhoneClick)];
                [_alertView.messageLabel addGestureRecognizer:tap];
            }
        }];
    }];
}

#pragma mark - Complete book handler

- (void) prefinishedTrip {
    // update lastest book's info (price, distance, duration, start, end)
    @weakify(self)
    [self.bookingService updateLastestBookingInfo:self.booking
                                            block:^(NSError *error) {
        @strongify(self)
        if (error) {
            [self notifyFinishedError];
        }
        else {
            [self.bookingService recheckValidateEstimate];
            [self.bookingService updateBookStatus:BookStatusCompleted complete:nil];
            ActiveFavoriteModeModel *activeFavoriteModeModel = [FavoritePlaceManager.shared activeFavoriteModeModel];
            if (activeFavoriteModeModel != nil
                && [activeFavoriteModeModel getIsActive] == YES) {
                __weak typeof(self) selfWeak = self;
                [FavoritePlaceManager.shared turnOffFavoriteModeWithTripId:self.booking.info.tripId complete:^(NSError *error) {
                    if (error != nil) {
                        [AlertVC showErrorFor:selfWeak message:error.localizedDescription];
                    } else {
                        FavoritePlaceManager.shared.activeFavoriteModeModel = nil;
                        [NSNotificationCenter.defaultCenter postNotificationName:Update_Favorite_Mode object:nil];
                    }
                }];
            }
        }
    }];
    [self showReceiptView];
}

- (void) notifyFinishedError {
    [self showMessageBanner:@"Xảy ra lỗi xác thực thông tin chuyến đi. Bạn vui lòng kiểm tra lại kết nối và thử lại!"
                     status:NO];
    
}

#pragma mark - Maps
- (void) initMaps {
    [self.mapView addLocationButton: self.buttonLocation];
    self.buttonLocation.backgroundColor = [UIColor clearColor];
    CLLocation *location = [GoogleMapsHelper shareInstance].currentLocation;

    //update address
    if (isDigitalTrip && clockTrip.startLocation == nil)
    {
        [[GoogleMapsHelper shareInstance] getAddressOfLocation:location.coordinate withCompletionBlock:^(GMSReverseGeocodeResponse* response, NSError* error) {
            if (error) {
                DLog(@"Cannot get address of current location: %@", error);
            }
            else {
                GMSAddress* address = response.firstResult;
                
                FCPlace *startLocation = [[FCPlace alloc] init];
                [startLocation setLocation:[[FCLocation alloc] initWithLat:location.coordinate.latitude
                                                                       lon:location.coordinate.longitude]];
                [startLocation setName:address.lines.firstObject];
                clockTrip.startLocation = startLocation;
            }
        }];
    }
}

/*
 - Clear maps when get driver data success
 - Readd all maker start, end, polyline if have before
 */
- (void) resetMaps {
    [self.mapView clear];
}
- (void) updateMaps:(CLLocationCoordinate2D) lo {
    FCConfigs* config = [FirebaseHelper shareInstance].appConfigs;
    if (!config) {
        CLLocation *currentLoc = self.mapView.myLocation;
        [self.mapView animateToLocation:currentLoc.coordinate];
    }
    else
    {
        [self.mapView animateToLocation:lo];
    }
}

- (void)showError:(NSString*)message
{
    if (message)
    {
        [self hideAlertView];
        _alertView = [UIAlertController showAlertInViewController:self
                                           withTitle:@""
                                             message:message
                                   cancelButtonTitle:@"OK"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex){
                                                _alertView = nil;
                                                [self hideView];
                                            }];
    }
}

- (void) hideView {
    [self dismissChat];
    
    // clear digital clock info
    [[UserDataHelper shareInstance] removeCurrentDigitalClockTrip:self.booking];
    
    // dismiss view
    [self.bookingService hideTripMapView: nil];
    
    [self removeNotification];
    [[TOManageCommunication shared] startObserWhenFinishTrip];
}

#pragma mark - Polyline
- (void) createRealPolyline: (id) locations {
    
    // polyline
    NSMutableArray* listLocation = [[GoogleMapsHelper shareInstance] decodePolyline:clockTrip.polyline];
    if (!listLocation) {
        listLocation = [[NSMutableArray alloc] init];
    }
    if ([locations isKindOfClass:[CLLocation class]]) {
        [listLocation addObject:locations];
    }
    else if ([locations isKindOfClass:[NSMutableArray class]]) {
        [listLocation addObjectsFromArray:locations];
    }
    
    clockTrip.polyline = [[GoogleMapsHelper shareInstance] encodeStringWithCoordinates:listLocation];
    [self drawRealPolyline];
    
    DLog(@"Polyline: %@", clockTrip.polyline)
}

- (void) drawRealPolyline {
    NSString* decode = clockTrip.polyline;
    if (decode) {
        if (polyline) {
            polyline.map = nil;
            self.mapView.polyline = nil;
        }
        
        [self drawPath:decode];
    }
}

- (void) drawPolylineFrom:(CLLocationCoordinate2D)startPosition
                       to:(CLLocationCoordinate2D)endPosition
               completion:(void(^)(FCRouter *))handler
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:startPosition coordinate:endPosition];
    NSInteger screenW = [UIScreen mainScreen].bounds.size.width;
    NSInteger screenH = [UIScreen mainScreen].bounds.size.height;
    NSInteger w = screenW / 5;
    NSInteger top = (screenH - (screenW - w*2)) / 2;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
        withEdgeInsets:UIEdgeInsetsMake(top, w, top, w)]];
    });
    
    
//    NSLog(@"!!!!!c1 :%@, c2 :%@", startPosition, endPosition);
    
    [[GoogleMapsHelper shareInstance] getDirection:startPosition
                                             andAt:endPosition
                                         completed:^(FCRouter * router) {
                                             
//                                             if (polyline) {
//                                                 polyline.map = nil;
//                                             }
//                                             [[FCBookingService shareInstance] updateBookExtra:router];
//                                             [self drawPath:router.polylineEncode];
                                             if (handler) {
                                                 handler(router);
                                             }
                                         }];
}

- (void) drawPath: (NSString*) decode {
    if (self.mapView.polyline) {
        self.mapView.polyline.map = nil;
        self.mapView.polyline = nil;
    }
    GMSPath *path =[GMSPath pathFromEncodedPath:decode];
    polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = [UIColor orangeColor];
    polyline.strokeWidth = 2;
    polyline.map = self.mapView;
    self.mapView.polyline = polyline;
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    
    NSInteger screenW = [UIScreen mainScreen].bounds.size.width;
    NSInteger screenH = [UIScreen mainScreen].bounds.size.height;
    NSInteger w = screenW / 5;
    NSInteger top = (screenH - (screenW - w * 2)) / 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                                          withEdgeInsets:UIEdgeInsetsMake(top, w, top, w)]];
    });
}


#pragma mark - Action

- (IBAction) onClientAvatar:(id)sender {
//    if (_client) {
//        [IndicatorUtils showWithAllowDismiss:NO];
//        
//        ClientProfileViewController *vc = [[UIStoryboard storyboardWithName:@"ClientProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"ClientProfileViewController"];
//        vc.client = _client;
//        
//        FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
//        [self presentViewController:navController animated:YES completion:^{
//            [IndicatorUtils dissmiss];
//        }];
//    }
}

- (void) onCloseReceipt
{
    [self playsound:@"success"];
    
    [self hideView];
}

- (IBAction)onCancelTrip:(id)sender {
    [self hideAlertView];
    
    if (![self isConnection]) {
        return;
    }
    
    if ([self.booking deliveryMode]) {
        DeliveryFailVC *vc = [DeliveryFailVC generateTypeCancelBooking];
        [vc setTripIDWith:self.booking.info.tripId];
        @weakify(self)
        @weakify(vc)
        [vc setDidSelectConfirm:^(NSDictionary<NSString *,id> *result) {
            @strongify(self)
            @strongify(vc)
            [self.bookingService updateEndReason:result];
            [IndicatorUtils show];
            [self.bookingService updateLastestBookingInfo:self.bookingService.book block:^(NSError *error) {
                [vc dismissViewControllerAnimated:true completion:nil];
                [IndicatorUtils dissmiss];
                [self playsound:@"cancel"];
                [self.bookingService updateBookStatus:BookStatusDriverCancelIntrip complete:nil];
                [self hideView];
            }];
        }];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        self.deliveryFailVC = navi;
        [navi setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:navi animated:true completion:nil];
        return;
    }
    
    FeedbackCancelResonType type;
    if ([self.booking deliveryFoodMode]) {
        type = FeedbackCancelResonTypeCancelDeliveryFood;
    } else if (self.booking.info.serviceId == VatoServiceSupply) {
        type = FeedbackCancelResonTypeDeliveryFoodFail;
    } else {
        type = FeedbackCancelResonTypeCancelTrip;
    }
    
    self.feedbackObjcWrapper = [[FeedbackObjcWrapper alloc] initWith:self];
    [self.feedbackObjcWrapper presentVCWithTripId:self.booking.info.tripCode ?: @""
                                      serviceType:self.booking.info.serviceId ?: 0
                                         selector:self.booking.info.clientUserId ?:0
                                             type:type
                                   bookingService: self.bookingService];
    
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
            [self.bookingService updateBookStatus:BookStatusDriverCancelIntrip complete:nil];
            [self hideView];
        }];
    }];
    
//
//    @weakify(self)
//    _alertView = [UIAlertController showAlertInViewController:self
//                                       withTitle:@"Xác nhận"
//                                                      message:@"Hủy chuyến quá nhiều sẽ ảnh hưởng đến điểm tài khoản của bạn.\nBạn vẫn muốn huỷ chuyến đi này?"
//                               cancelButtonTitle:nil
//                          destructiveButtonTitle:@"Giữ chuyến đi"
//                               otherButtonTitles:@[@"Huỷ chuyến"]
//                                        tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex) {
//                                            @strongify(self)
//                                            _alertView = nil;
//                                            if (buttonIndex == 2) {
//                                                [self playsound:@"cancel"];
//                                                [_bookingService updateBookStatus:BookStatusDriverCancelIntrip complete:nil];
//                                                [self hideView];
//                                            }
//                                        }];
}


- (IBAction)onCallClient:(id)sender {
    
    NSString *phone = self.booking.info.contactPhone;
    
    if (self.booking.info.serviceId == VatoServiceExpress) {
        phone = self.booking.info.senderPhone;
    }
    
    if ([self.booking deliveryFoodMode]) {
        phone = self.booking.info.receiverPhone;
    }
    if (phone.length == 0) {
        return;
    }
    
    NSString *phoneNumber = [@"tel://" stringByAppendingString:phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}



- (IBAction)onChatClicked:(id)sender {
    [self showChatView];
}

- (IBAction)onDirectionButton:(id)sender {
    
    CLLocationCoordinate2D startCoordinate = kCLLocationCoordinate2DInvalid;
    CLLocationCoordinate2D endCoordinate = kCLLocationCoordinate2DInvalid;
    
    if ([self.bookingService isTripStarted: self.booking])
    {
        if (self.booking.info.tripType == BookTypeFixed)
        {
            startCoordinate = CLLocationCoordinate2DMake(self.booking.info.startLat, self.booking.info.startLon);
            endCoordinate = CLLocationCoordinate2DMake(self.booking.info.endLat, self.booking.info.endLon);
        }
        else
        {
            startCoordinate = lastLocation.coordinate;
            endCoordinate = CLLocationCoordinate2DMake(clockTrip.endLocation.location.lat, clockTrip.endLocation.location.lon);
        }
    }
    else if ([self.bookingService isInTrip: self.booking])
    {
        startCoordinate = lastLocation.coordinate;
        endCoordinate = CLLocationCoordinate2DMake(self.booking.info.startLat, self.booking.info.startLon);
    }
    
    [GoogleMapsHelper openMapWithStart:startCoordinate andEnd:endCoordinate];
}

- (IBAction)noteClicked: (UITapGestureRecognizer*) gesture {
    [self scanerPhoneNumber:self.lblNote.text complete:^(NSString *phone, NSRange range) {
        if (phone.length > 0) {
            if ([gesture didTapAttributedTextInLabel:self.lblNote inRange:range]) {
                [self callPhone:phone];
                return;
            }
        }
        
        [self hideAlertView:^{
            _alertView = [UIAlertController showAlertInViewController:self
                                                            withTitle:@"Ghi chú chuyến đi"
                                                              message:self.booking.info.note
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"OK"
                                                    otherButtonTitles:nil
                                                             tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex) {
                                                                 _alertView = nil;
                                                             }];
            
            _alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
            _alertView.messageLabel.userInteractionEnabled = YES;
            
            NSString* text = self.booking.info.note;
            if (phone.length > 0) {
                [_alertView.messageLabel underlineText:text atRange:range];
                UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topupPhoneClick)];
                [_alertView.messageLabel addGestureRecognizer:tap];
            }
        }];
    }];
}

- (IBAction)didTouchChatExpress:(id)sender {
    [self onChatClicked:nil];
}

- (IBAction)didTouchCallSender:(id)sender {
    NSString *phone = self.booking.info.contactPhone;
    if (self.booking.info.serviceId == VatoServiceExpress) {
        phone = self.booking.info.senderPhone;
    }
    if ([self.booking deliveryFoodMode]) {
        phone = self.booking.info.receiverPhone;
    }
    if (self.booking.info.contactPhone.length == 0) {
        return;
    }
    
    NSString *phoneNumber = [@"tel://" stringByAppendingString:phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)callShop:(id)sender {
    NSString *phone = self.booking.info.contactPhone;
    if (self.booking.info.contactPhone.length == 0) {
        return;
    }
    
    NSString *phoneNumber = [@"tel://" stringByAppendingString:phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)didTouchCallReceiver:(id)sender {
    if (self.booking.info.receiverPhone.length == 0) {
        return;
    }
    
    NSString *phoneNumber = [@"tel://" stringByAppendingString:self.booking.info.receiverPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)didTouchExpressSuccess:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PackageInfo" bundle:nil];
    UINavigationController *navi = [sb instantiateViewControllerWithIdentifier:@"ExpressSuccessNavi"];
    if ([navi.topViewController isKindOfClass:[ExpressSuccessVC class]] ) {
        ExpressSuccessVC *vc = (ExpressSuccessVC *)navi.topViewController;
        vc.bookingService = self.bookingService;
        vc.listener = self;
    }
    [navi setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:navi animated:YES completion:NULL];
}

- (IBAction)didTouchExpressFail:(id)sender {
    if ([self.booking deliveryFoodMode] || self.booking.info.serviceId == VatoServiceSupply) {
        [self deliveryFailFoodOder];
        return;
    }
    
    DeliveryFailVC *vc = [[DeliveryFailVC alloc] init];
    vc.bookingService = self.bookingService;
    [vc setTripIDWith:self.booking.info.tripId];
    @weakify(self)
    @weakify(vc)
    [vc setDidSelectConfirm:^(NSDictionary<NSString *,id> *result) {
        @strongify(self)
        @strongify(vc)
        [self confirmDeliveryFail:result viewController:vc];
    }];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    self.deliveryFailVC = navi;
    [navi setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:navi animated:true completion:nil];
}

- (IBAction)viewOderFood:(id)sender {
    [self viewPackageDetail];
}

- (void) topupPhoneClick {
    NSString* text = self.booking.info.note;
    [self scanerPhoneNumber:text complete:^(NSString *phone, NSRange range) {
        if (phone.length > 0) {
            [self callPhone:phone];
        }
    }];
}

- (void)showPackageVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PackageInfo" bundle:nil];
    UINavigationController *navi; //= [storyboard instantiateInitialViewController];
    if (self.booking.info.serviceId == VatoServiceSupply) {
        navi = [storyboard instantiateViewControllerWithIdentifier:@"SupplyFood"];
    } else {
        navi = [storyboard instantiateInitialViewController];
    }
    if ([navi.topViewController isKindOfClass:[PackageInfoVC class]] ) {
        PackageInfoVC *vc = (PackageInfoVC *)navi.topViewController;
        vc.bookingService = self.bookingService;
        vc.listener = self;
    }
    self.naviPackageVC = navi;
    [navi setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:navi animated:NO completion:nil];
}

- (void) showDigitalClockTrip {
    [self.bookingService updateBookStatus:BookStatusStarted complete:nil];
    FCDigitalClockTrip *clock = [[UserDataHelper shareInstance] getLastDigitalClockTrip:self.booking];
    DigitalClockViewController *vc = [[DigitalClockViewController alloc] initWithNibName:@"DigitalClockViewController" bundle:nil];
    [vc setClockTrip:clock];
    [vc setBooking:self.booking];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark - Slider Delegate, MBSliderViewDelegate
- (void) sliderDidSlide:(MBSliderView *)sliderView shouldResetState:(BOOL *)reset {
    if (self.booking.info.tripType == BookTypeOneTouch) {
        self.booking.info.tripType = BookTypeFixed;
    }
    [FIRAnalytics logEventWithName:@"user_slide_action" parameters:@{}];
    if ([self.booking deliveryMode]) {
        [FIRAnalytics logEventWithName:@"user_slide_action_delivery" parameters:@{}];
        [self showPackageVC];
        *reset = YES;
        return;
    }
    
    if ([self.booking deliveryFoodMode]) {
        [FIRAnalytics logEventWithName:@"user_slide_action_delivery_food" parameters:@{}];
        [self showFoodReceivePackage];
        *reset = YES;
        return;
    }
    
    if (self.booking.info.tripType == BookTypeDigital) {
        [self showDigitalClockTrip];
        return;
    }
    
    if (hasStartTrip) //end trip
    {
        [FIRAnalytics logEventWithName:@"user_slide_action_finish_trip" parameters:@{}];
        DLog(@"End trip...");
        *reset = YES;
        
        [self endTrip];
    }
    else //start trip
    {
        DLog(@"Start trip...");
        [FIRAnalytics logEventWithName:@"user_slide_action_start_trip" parameters:@{}];
        *reset = YES;
        
        [self startTrip];
    }
}

#pragma mark - Trip book
- (void) loadLastestTripStatus {
    NSLog(@"Command Status: loadLastestTripStatus");
    if (isDigitalTrip) {
        clockTrip = [[UserDataHelper shareInstance] getLastDigitalClockTrip:self.booking];
        
        [self updateDistance:clockTrip.totalDistance];
        
        // load current location update
        if ([GoogleMapsHelper shareInstance].currentLocation) {
            [self locationUpdate:[NSNotification notificationWithName:NOTIFICATION_UPDATE_LOCATION_RAPIDLY object:[GoogleMapsHelper shareInstance].currentLocation]];
        }
    }
    
    BOOL loaded = NO;
    for (FCBookCommand *command in self.booking.command) {
        if (command.status == BookStatusDriverAccepted) {
            loaded = YES;
        } else {
            continue;
        }
    }
    
    if (loaded) {
        [self receiveVisitor];
    }
    
    if ([self.bookingService isInTrip: self.booking] && ![self.bookingService isTripStarted: self.booking]) {
        [self receiveVisitor];
    }
    else if ([self.bookingService isTripStarted: self.booking]) {
        [self startTrip];
        if ([self.booking deliveryMode]) {
            self.viewInfoExpress.hidden = NO;
            self.stackViewFood.hidden = YES;
        }
        
        if ([self.booking deliveryFoodMode]) {
            self.viewInfoExpress.hidden = NO;
            self.heightOfViewBottom.constant = 190;
            self.stackViewFood.hidden = NO;
        }
        
        if ([self.booking deliveryFoodMode]) {
            self.hViewShadowFoodDetail.constant = 40;
            self.stackViewFood.hidden = NO;
            
        }
        
        
    }
    else if ([self.bookingService isTripCompleted: self.booking]) {
        [self showReceiptView];
    }
    
    [self checkStatusDriverAccept];
}

- (void)checkStatusDriverAccept {
    double time = TIME_OUT_UPDATE_STATUS;
    @weakify(self);
    [SVProgressHUD show];
    [[[[self.bookingService checkWaitingStatus:BookStatusDriverAccepted] take:1] timeout:time onScheduler:[RACScheduler scheduler]] subscribeNext:^(id x) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self checkStatusClientAccept];
        });
    } error:^(NSError *error) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            _alertView = [UIAlertController showAlertInViewController:self
                                                            withTitle:@""
                                                              message:@"Kết nối mạng không ổn định, Bạn có muốn thử lại không?"
                                                    cancelButtonTitle:@"Huỷ Chuyến"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@[@"Thử lại"]
                                                             tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                                 @strongify(self);
                                                                 if (buttonIndex == 0) {
                                                                     [self playsound:@"cancel"];
                                                                     [self.bookingService updateBookStatus:BookStatusDriverCancelIntrip complete:nil];
                                                                     [self hideView];
                                                                 } else if (buttonIndex == 2) {
                                                                     [self checkStatusDriverAccept];
                                                                 }
                                                             }];
        });
    }];
}

- (void)checkChangeBookInfo {
     @weakify(self);
    [[self.bookingService checkChangeBookInfo] subscribeNext:^(FCBookInfo* info) {
        @strongify(self);
        self.booking.info = info;
        [_tripMapInfoView setupDisplayWithItem:self.booking];
    }];
    
    
    [[[[self.bookingService checkChangeBookInfo] map:^NSNumber *(FCBookInfo* info) {
        NSInteger bookPrice = [info getBookPrice];
        NSInteger offerPrice = bookPrice + info.additionPrice;
        return [NSNumber numberWithInteger:offerPrice];
    }] distinctUntilChanged] subscribeNext:^(NSNumber *newPrice) {
        [_tripMapInfoView updateLastPriceViewWithPrice:[newPrice integerValue]];
    }];
    
}

- (void)checkStatusClientAccept {
    double time = WAITING_CLIENT_AGREE_TIMEOUT;
    FCAppConfigure* appConfigure = [FirebaseHelper shareInstance].appConfigure;
    if (appConfigure.booking_configure.waiting_client_agree_timeout > 0) {
        time = appConfigure.booking_configure.waiting_client_agree_timeout;
    }
    
    @weakify(self);
    [[[[[self.bookingService checkWaitingStatus:BookStatusClientAgreed] filter:^BOOL(NSNumber *value) {
        return [value boolValue];
    }] take:1] timeout:time onScheduler:[RACScheduler scheduler]] subscribeError:^(NSError *error) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            _alertView = [UIAlertController showAlertInViewController:self
                                                            withTitle:@""
                                                              message:@"Không liên lạc được khách hàng, vui lòng gọi điện để xác nhận chuyến đi "
                                                    cancelButtonTitle:@"Đóng"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil
                                                             tapBlock:nil];
        });
    }];
}

- (void) receiveVisitor {
    
    [self updateUIByTripStatus: NO];
    
    self.heightConstraintViewAddress.constant = heightViewAddressFull;
    self.heightConstraintViewDigitalClock.constant = heightViewAddressFull;
    self.buttonCallMerchant.hidden = ![self.booking deliveryFoodMode];
    
    [self.viewDot setHidden:false];
    self.iconAddress.image = [UIImage imageNamed:@"iconBookingPickup"];

    [_tripMapInfoView receiveVisitorWithItem:self.booking];
    [_labelTitle setText:@"ĐÓN KHÁCH"];
    [_sliderView setText:@"TRƯỢT ĐỂ BẮT ĐẦU"];
    
    if (self.booking.info.serviceId == VatoServiceSupply) {
        [_labelTitle setText:@"Đang đi mua hàng"];
        [_sliderView setText:[@"Đã đến của hàng" uppercaseString]];
    } else if ([self.booking deliveryMode]) {
        [_labelTitle setText:@"Đang đi nhận hàng"];
        [_sliderView setText:@"BẮT ĐẦU NHẬN HÀNG"];
    } else if ([self.booking deliveryFoodMode]) {
        [_labelTitle setText:@"Đang đến cửa hàng"];
        [_sliderView setText:@"ĐÃ ĐẾN CỬA HÀNG"];
    }
    
    [_labelNamePickup setText:[self.booking.info.startName uppercaseString]];
    [_labelAddressPickup setText:self.booking.info.startAddress];
    
    if (self.booking.info.tripType == BookTypeFixed) {
        [_labelNameDestination setText:[self.booking.info.endName uppercaseString]];
        [_labelAddressDestination setText:self.booking.info.endAddress];
    } else {
        [_labelNameDestination setText:@"Theo lộ trình thực tế"];
        [_labelAddressDestination setText:@"Khách hàng chưa chọn điểm đến"];
    }
    
    if (self.bookingService.book.extra.polylineReceive.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawPath:self.bookingService.book.extra.polylineReceive];
        });
        
    }
    else {
        double endLat = self.bookingService.book.info.startLat;
        double endLon = self.bookingService.book.info.startLon;
        
        @weakify(self);
        CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(endLat, endLon);
        CLLocationCoordinate2D driverCoord = [VatoLocationManager shared].location.coordinate;
        [self drawPolylineFrom:driverCoord
                            to:startCoord completion:^(FCRouter *router) {
            @strongify(self);
            if (router) {
                [self.bookingService trackingEstimateReceiveDis:router.distance
                                              receiveDur:router.duration];
                [self.bookingService updateBookExtra:router];
            }
        }];
    }
}

- (void) startTrip
{
    if (self.booking.info.endLat == 0 && self.booking.info.endLon == 0) {
        [UIAlertController showAlertInViewController:self
                     withTitle:@""
                       message:@"Bạn cần phải chọn điểm đến"
             cancelButtonTitle:@"OK"
        destructiveButtonTitle:nil
             otherButtonTitles:nil
                      tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex){
                      }];
        return;
    }
    
    [self playsound:@"success"];
    
    // update book status
    @weakify(self);
    [self.bookingService updateBookStatus:BookStatusStarted complete:^(BOOL success) {
        @strongify(self);
        if (success) {
            [self updateUIInTrip];
        } else {
            [_sliderView resetDefaultState];
        }
    }];
    
}

- (void) updateUIInTrip {
    hasStartTrip = YES;
    
    [IndicatorUtils showWithAllowDismiss:NO];
    
    self.heightConstraintViewAddress.constant = heightViewAddressDefault;
    self.heightConstraintViewDigitalClock.constant = heightViewAddressDefault;
    self.buttonCallMerchant.hidden = YES;
    if (markerStart)
    {
        markerStart.icon = [UIImage imageNamed:@"marker-start"];
    }
    
    [self updateUIByTripStatus:YES];

    // remove current polyline
    if (polyline) {
        polyline.map = nil;
        self.mapView.polyline = nil;
    }
    
    if (isDigitalTrip) {
        CLLocation* location = [GoogleMapsHelper shareInstance].currentLocation;
        FCUCar* car = [[UserDataHelper shareInstance] getCurrentUser].vehicle;
        [[FirebaseHelper shareInstance] getFareDetail:self.booking.info.serviceId
                                             tripType:[self.booking.info getType]
                                           atLocation:location
                                            taxiBrand: car.taxiBrand
                                              handler:^(FCFareSetting *receipt, NSArray<FCFarePredicate*> *predecates, NSArray<FCFareModifier*> *modifiers) {
            [IndicatorUtils dissmiss];
            
            if (receipt)
            {
                self.receipt = receipt;
                self.predecates = predecates;
                self.modifiers = modifiers;
                
                if (clockTrip == nil)
                {
                    clockTrip = [[FCDigitalClockTrip alloc] init];
                    
                    CLLocationCoordinate2D currentLoc = [GoogleMapsHelper shareInstance].currentLocation.coordinate;
                    clockTrip.lastLocation = [[FCLocation alloc] initWithLat:currentLoc.latitude lon:currentLoc.longitude];
                }
                
                [self startTimer];
                
                if (clockTrip.startLocation == nil)
                {
                    FCPlace* place = [[FCPlace alloc] init];
                    place.name = self.booking.info.startName;
                    place.location = [[FCLocation alloc] initWithLat:self.booking.info.startLat
                                                                 lon:self.booking.info.startLon];
                    clockTrip.startLocation = place;
                }
                
                //enable marker end & draw polyline from start to end (if exist)
                if (clockTrip.endLocation != nil)
                {
                    [self addMarkerEnd:CLLocationCoordinate2DMake(clockTrip.endLocation.location.lat, clockTrip.endLocation.location.lon)];
                    
                    [self drawPolylineFrom:markerStart.position to:markerEnd.position completion:nil];
                    
                    [self.labelAddress setText:clockTrip.endLocation.name];
                    
                    [self.buttonDirection setHidden:NO];
                }
                else
                {
                    [self.buttonDirection setHidden:YES];
                }
            }
            else
            {
                [self showError:@"Có lỗi xảy ra"];
            }
        }];
    }
    else
    {
        [IndicatorUtils dissmiss];
        self.iconAddress.image = [UIImage imageNamed:@"iconBookingDestination"];
        
        [self.viewDot setHidden:true];
        
        [_labelNamePickup setText:[self.booking.info.endName uppercaseString]];
        [_labelAddressPickup setText:self.booking.info.endAddress];
        
        //enable marker end
        [self addMarkerEnd];
        
        //draw polyline from start to end
        if (self.bookingService.book.extra.polylineIntrip.length > 0) {
            [self drawPath:self.bookingService.book.extra.polylineIntrip];
        }
        else {
            @weakify(self);
            [self drawPolylineFrom:markerStart.position
                                to:markerEnd.position completion:^(FCRouter *router) {
                @strongify(self);
                if (router) {
                    [self.bookingService setDataToDatabase:@"extra" json:@{@"polylineIntrip": router.polylineEncode ?: @""} update:YES];
                }
            }];
        }
    }
    
    //update UI
    
    [_cancelTripView removeFromSuperview];
    _cancelTripView = nil;
    
    [_cancelTripViewFood removeFromSuperview];
    _cancelTripViewFood = nil;
    
    _avatarWidthConstraintHalf.active = YES;
    _avatarFoodWidthConstraintHalf.active = YES;
    
    [_tripMapInfoView startTripWithItem:self.booking];

    [_labelTitle setText:@"TRẢ KHÁCH"];
    if ([self.booking deliveryMode] || [self.booking deliveryFoodMode]) {
        [_labelTitle setText:@"Đang đi giao hàng"];
    }
    [_sliderView setText:@"TRƯỢT ĐỂ KẾT THÚC"];
    
    [self dismissChat];
    
    // listen change destination
    [[AddDestinationCommunication shared] listenChangeDestination];
    [_tripMapInfoView useLast];
    
}


- (void) endTrip
{
    // check network
    if (![self isConnection]) {
        return;
    }
    
    if (self.isProcessFinishTrip == true) {
        return;
    } else {
        self.isProcessFinishTrip = true;
    }
    
    [self playsound:@"success"];
    
    [self stopTimer];
    
    //remove saved digital trip
    [[UserDataHelper shareInstance] removeCurrentDigitalClockTrip:self.booking];
    
    
    if (isDigitalTrip)
    {
        [self calculateDigitalPrice: YES];
        self.booking.info.distance = clockTrip.totalDistance;
        self.booking.info.duration = clockTrip.totalTime;
        
        // end info
        CLLocationCoordinate2D coordinate = [GoogleMapsHelper shareInstance].currentLocation.coordinate;
        if (clockTrip.endLocation == nil) {
            clockTrip.endLocation = [[FCPlace alloc] init];
        }
        [clockTrip.endLocation setLocation:[[FCLocation alloc] initWithLat:coordinate.latitude
                                                                       lon:coordinate.longitude]];
        
        // save lastest trip info
        self.booking.info.endLat = coordinate.latitude;
        self.booking.info.endLon = coordinate.longitude;
        
        [self prefinishedTrip];
        
        // get end place info
        [[GoogleMapsHelper shareInstance] getAddressOfLocation:coordinate withCompletionBlock:^(GMSReverseGeocodeResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error) {
                GMSAddress* address = response.firstResult;
                [clockTrip.endLocation setName:address.lines.firstObject];
                self.booking.info.endName = address.lines.firstObject;
                self.booking.info.endAddress = address.lines.firstObject;
                if (_receiptView) {
                    [_receiptView updateAddressTo:self.booking.info.endAddress];
                }
                
                // update for end name
                [self.bookingService updateLastestBookingInfo:self.booking
                                                    block:^(NSError *error) {
                                                    }];
            }
        }];

    }
    else
    {
        // update status 49
        [self prefinishedTrip];
    }
    
    [[AddDestinationCommunication shared] stopListenNotification];
}

- (BOOL) isConnection {
    if (![self isNetworkAvailable]) {
        [self hideAlertView];
        _alertView = [UIAlertController showAlertInViewController:self
                                                        withTitle:@"Thông báo"
                                                          message:@"Đường truyền mạng trên thiết bị đã bị mất kết nối.\n\nVui lòng kiểm tra lại để tiếp tục."
                                                cancelButtonTitle:@"Đồng ý"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil
                                                         tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex) {
                                                             _alertView = nil;
                                                             if (buttonIndex == 0) {
                                                                 if ([[UIApplication sharedApplication] canOpenURL:[NSURL    URLWithString:UIApplicationOpenSettingsURLString]]) {
                                                                     [[UIApplication sharedApplication]
                                                                      openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                 }
                                                             }
                                                         }];
        return NO;
    }
    
    return YES;
}

- (void) updateTime
{
    long long time = [TimeUtils uptime];
    clockTrip.totalTime += 1;
    long total = clockTrip.totalTime;
    
    [self.labelTime setText:[self getHourAndMinuteAndSecond:total*1000]];
    [[UserDataHelper shareInstance] saveCurrentDigitalClockTrip:clockTrip forBook:self.booking];
    
    
    // only update price if dis greater 100m or duration greater 60 sec
    if (_deltaDistance >= 100 || (time - _lastestTime) >= 60 || _lastestTime == 0) {
        _lastestTime = time;
        _deltaDistance = 0;
        
        //price
        [self calculateDigitalPrice: NO];
    }
}

- (void) calculateDigitalPrice: (BOOL) finishedTrip {
    if (!clockTrip || !_receipt) {
        return;
    }
    
    NSInteger originPrice = [self caculatePrice:self.receipt
                                       distance:clockTrip.totalDistance
                                    timeRunning:clockTrip.totalTime
                                       finished:finishedTrip];
    if (self.booking.info.promotionCode.length > 0) {
        self.booking.info.promotionValue = [self caculatePromotionValue: originPrice];
    }
    
    self.booking.info.price = originPrice;
    [self updatePrice:originPrice];

    /* Condition validation: any pre 5.7.6 (5.7.43) version will not send client credit amount */
    if (self.booking && self.booking.info.payment == PaymentMethodVATOPay && self.booking.extra && self.booking.extra.clientCreditAmount) {
        double_t clientCreditAmount = self.booking.extra.clientCreditAmount.doubleValue;
        [self checkClientVatoPayCredit:clientCreditAmount withFarePrice:originPrice];
    }

    // get fare modifier for trip
    if ([self isAPIFareSettings]) {

        [[FirebaseHelper shareInstance] getServerTime:^(NSTimeInterval timestamp) {
            NSMutableArray *listPredecates = [NSMutableArray arrayWithArray:self.predecates];
            NSMutableArray *listModifiers = [NSMutableArray arrayWithArray:self.modifiers];
            FCFareService *instance = [FCFareService shareInstance];

            FCFareModifier *modifier = [instance getFareModifier:_booking
                                                         service:_booking.info.serviceId
                                                    listModifier:listModifiers
                                                   listPredicate:listPredecates
                                                       timestamp:timestamp];
            _fareModifier = modifier;

            NSInteger newFare = originPrice;
            if (_fareModifier) {
                NSArray* fare = [FCFareService getFareAddition:originPrice
                                                  additionFare:0
                                                      modifier:_fareModifier];
                newFare = [[fare objectAtIndex:0] integerValue];
                NSInteger driverSupport = [[fare objectAtIndex:1] integerValue];
                NSInteger clientSupport = [[fare objectAtIndex:2] integerValue];

                self.booking.info.fareClientSupport = clientSupport;
                self.booking.info.fareDriverSupport = driverSupport;
                self.booking.info.modifierId = _fareModifier.id;
            }

            self.booking.info.farePrice = newFare;
            [self updatePrice:newFare];

            /* Condition validation: any pre 5.7.6 (5.7.43) version will not send client credit amount */
            if (self.booking && self.booking.info.payment == PaymentMethodVATOPay && self.booking.extra && self.booking.extra.clientCreditAmount) {
                double_t clientCreditAmount = self.booking.extra.clientCreditAmount.doubleValue;
                [self checkClientVatoPayCredit:clientCreditAmount withFarePrice:newFare];
            }

            // re-calculate if has increase price
            if (self.booking.info.promotionCode.length > 0) {
                self.booking.info.promotionValue = [self caculatePromotionValue: newFare];
            }
        }];
    } else {
        @weakify(self);
        [[FCFareService shareInstance] getFareModifier:_booking complete:^(FCFareModifier * modifier) {
            @strongify(self);
            _fareModifier = modifier;

            NSInteger newFare = originPrice;
            if (_fareModifier) {
                NSArray* fare = [FCFareService getFareAddition:originPrice
                                                  additionFare:0
                                                      modifier:_fareModifier];
                newFare = [[fare objectAtIndex:0] integerValue];
                NSInteger driverSupport = [[fare objectAtIndex:1] integerValue];
                NSInteger clientSupport = [[fare objectAtIndex:2] integerValue];

                self.booking.info.fareClientSupport = clientSupport;
                self.booking.info.fareDriverSupport = driverSupport;
                self.booking.info.modifierId = _fareModifier.id;
            }

            self.booking.info.farePrice = newFare;
            [self updatePrice:newFare];

            /* Condition validation: any pre 5.7.6 (5.7.43) version will not send client credit amount */
            if (self.booking && self.booking.info.payment == PaymentMethodVATOPay && self.booking.extra && self.booking.extra.clientCreditAmount) {
                double_t clientCreditAmount = self.booking.extra.clientCreditAmount.doubleValue;
                [self checkClientVatoPayCredit:clientCreditAmount withFarePrice:newFare];
            }

            // re-calculate if has increase price
            if (self.booking.info.promotionCode.length > 0) {
                self.booking.info.promotionValue = [self caculatePromotionValue: newFare];
            }
        }];
    }
}

- (void)checkClientVatoPayCredit:(double_t)clientCreditAmount withFarePrice:(NSInteger)farePrice {
    /* Condition validation: client credit must greater than fare price */
    NSInteger estimatePrice = fmax(farePrice, _receipt.min);
    if (estimatePrice < clientCreditAmount) {
        return;
    }

    // Switch to cash payment
    [[FirebaseHelper shareInstance] updateTrip:_booking.info.tripId payment:PaymentMethodCash];
    _booking.info.payment = PaymentMethodCash;

    // Notify driver
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_alertView) {
            [_alertView dismissViewControllerAnimated:true completion:nil];
        }
        _alertView = [UIAlertController showAlertInViewController:self
                                                        withTitle:@"Xác nhận KH thanh toán bằng tiền mặt"
                                                          message:@"Số dư tài khoả của khách hàng không đủ để thanh toán chuyến đi. Thu tiền mặt của khách hàng khi kết thúc chuyến đi."
                                                cancelButtonTitle:@"Đóng"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil
                                                         tapBlock:nil];
    });


    // Send push
    [[FirebaseHelper shareInstance] getClient:_booking.info.clientFirebaseId handler:^(FCClient *client) {
        [FirebasePushHelper sendPushTo:client.deviceToken
                                  type:NotifyNotEnoughVatoPay
                                 title:@"Số dư VATOPAY không đủ"
                               message:@"Số dư VATOPAY của bạn không đủ để thực hiện thanh toán chuyến đi. Hãy thanh toán chuyến đi bằng tiền mặt."];
    }];
}

- (NSInteger) caculatePromotionValue: (NSInteger) tripPrice {
    FCBookInfo* info = self.booking.info;
    NSInteger discount = tripPrice * info.promotionRatio + info.promotionDelta;
    discount = MAX(discount, info.promotionMin);
    discount = MIN(discount, info.promotionMax);
    
    NSInteger last = (discount / 1000) * 1000;
    return last;
}

- (void) showReceiptView {
    _receiptView = [[NSBundle mainBundle] loadNibNamed:@"ReceiptView" owner:self options:nil].firstObject;
    _receiptView.delegate = self;
    _receiptView.book = self.booking;
    [self.view addSubview:_receiptView];
    [self.view bringSubviewToFront:_receiptView];
    
    // load data
    if (self.booking.info.tripType == BookTypeFixed) {
        NSInteger bookPrice = [self.booking.info getBookPrice];
        [_receiptView updateAddressFrom:self.booking.info.startName];
        [_receiptView updateAddressTo:self.booking.info.endName];
        [_receiptView updatePrice:bookPrice + self.booking.info.additionPrice];
        [_receiptView updateDistance:self.booking.info.distance];
        [_receiptView updateTime:self.booking.info.duration];
        
        DeliveryStatus status = DeliveryStatusNone;
        if ([self.bookingService.book deliveryMode] || [self.bookingService.book deliveryFoodMode]) {
            if ([self.bookingService isDeliveryFail:_booking]) {
                status = DeliveryStatusFail;
            } else {
                status = DeliveryStatusSuccess;
            }
        }
        
        if (self.isFoodFail) {
            status = DeliveryStatusFail;
        }
        
        [_receiptView setupDeliverStatus:status];
        if ([self.bookingService.book deliveryMode]) {
            [_receiptView updateTextSenderPay:@"Người gửi đã trả"];
        }
    }
    else {
        [_receiptView updateAddressFrom:self.booking.info.startName];
        [_receiptView updateAddressTo:self.booking.info.endName];
        [_receiptView updatePrice:self.booking.info.price];
        [_receiptView updateDistance:self.booking.info.distance];
        [_receiptView updateTime:self.booking.info.duration];
    }
    [_receiptView updateNoteView];
}

- (void) isStatusStartedAndServiceFood {
   if ([self.booking deliveryFoodMode]) {
       self.heightOfViewBottom.constant = 200;
       self.hViewShadowFoodDetail.constant = 40;
       
    } else {
        self.heightOfViewBottom.constant = 230;
        self.hViewShadowFoodDetail.constant = 0;
    }
}

- (void) updatePriceView: (BOOL) started {
    [_tripMapInfoView updatePriceViewWithStarted:started booking:self.booking hideTarget:NO];
    
    self.lblService.text = [NSString stringWithFormat:@" %@ ", [self.booking.info localizeServiceName]];
    
    // payment method
    switch (self.booking.info.payment) {
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
    
    // promotion
    if (self.booking.info.promotionCode.length == 0) {
        self.lblPromotion.text = EMPTY;
        self.lblPromotion.hidden = YES;
    }
    
    if (isDigitalTrip) {
        [self.lblServiceAndPrice setText:[NSString stringWithFormat:@"%@", [self.booking.info localizeServiceName]]];

        // hide price
        self.lblPrice.text = EMPTY;
        self.lblPrice.hidden = YES;
    }
    else {
        NSInteger bookPrice = [self.booking.info getBookPrice];
        NSInteger offerPrice = bookPrice + self.booking.info.additionPrice;

        BOOL hideTarget = [FirebaseHelper shareInstance].appConfigure.booking_configure.hide_destination;
        if (hideTarget && !started) {
            [self.lblServiceAndPrice setText:[NSString stringWithFormat:@"%@", [self.booking.info localizeServiceName]]];

            // hide price
            self.lblPrice.text = EMPTY;
            self.lblPrice.hidden = YES;
        }
        else {
            [self.lblServiceAndPrice setText:[NSString stringWithFormat:@"%@ > Cước %@",
                                              [self.booking.info localizeServiceName],
                                              [self formatPrice:offerPrice]]];

            // hide price
            self.lblPrice.text = [NSString stringWithFormat:@" %@đ ", [self formatPrice:offerPrice withSeperator:@","]];
            self.lblPrice.hidden = NO;
        }
    }
    
}

#pragma mark - Location Delegate

- (void)locationUpdate:(NSNotification*)notification
{
    if ([notification.object isKindOfClass:[NSString class]])
    {
        return;
    }

    CLLocation *location = notification.object;
    
    //digital trip
    if (isDigitalTrip)
    {
        FCLocation *curLocation = [[FCLocation alloc] initWithLat:location.coordinate.latitude lon:location.coordinate.longitude];
        if (clockTrip.lastLocation)
        {
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:clockTrip.lastLocation.lat
                                                         longitude:clockTrip.lastLocation.lon];
            CGFloat distance = [location distanceFromLocation:loc];
            
            // nếu khoảng cách quá lớn thì tính theo google (> 500m)
            if (distance > 500 && [self isNetworkAvailable]) {
                
                [[GoogleMapsHelper shareInstance] googleApiGetListLocation:CLLocationCoordinate2DMake(clockTrip.lastLocation.lat, clockTrip.lastLocation.lon)
                                                                     toEnd:location.coordinate
                                                                 completed:^(NSMutableArray * listLocation, NSInteger dis) {
                                                                     
                                                                     clockTrip.totalDistance += dis;
                                                                     _deltaDistance += dis;
                                                                     
                                                                     //distance
                                                                     [self updateDistance:clockTrip.totalDistance];
                                                                     
                                                                     //price
                                                                     [self calculateDigitalPrice: NO];
                                                                     
                                                                     // polyline
                                                                     [self createRealPolyline:listLocation];
                                                                 }];
            }
            else {
                clockTrip.totalDistance += distance;
                _deltaDistance += distance;
                
                //distance
                [self updateDistance:clockTrip.totalDistance];
                
                //price
                [self calculateDigitalPrice: NO];
                
                // polyline
                [self createRealPolyline:location];
            }
        }
        
        clockTrip.lastLocation = curLocation;
        
    }
    

    // update marker on map: position and rotation
    [self updateMarkerOnMap:markerDriver atCurrent:location];
    lastLocation = location;
    
    GMSCoordinateBounds *bound = [[GMSCoordinateBounds alloc] initWithRegion:self.mapView.projection.visibleRegion];
    if (![bound containsCoordinate:location.coordinate])
    {
        [self.mapView animateToLocation:location.coordinate];
    }
    
    if ([self.bookingService isInTrip: self.booking] && ![self.bookingService isTripStarted: self.booking]) {
        [self checkGoingToCustomer:location];
    }
}

/**
 Kiểm tra xem tài xế gần đến điểm đón khách chưa, nếu gần thì báo cho khách hàng
 */
- (void) checkGoingToCustomer: (CLLocation*) driverLocation {
    if (sentNotifyToCustomer) {
        return;
    }
    
    CLLocation* clientLocation = [[CLLocation alloc] initWithLatitude:_booking.info.startLat longitude:_booking.info.startLon];
    double dis = [driverLocation distanceFromLocation:clientLocation];
    if (dis < 100) {
        NSString* message = @"[Tin nhắn tự động] Tài xế sắp đến điểm đón. Bạn vui lòng chờ trong giây lát.";
        if ([self.booking deliveryFoodMode]) {
            message = @"Bác tài sắp tới quán. Bạn chờ xíu nha! 😉";
        }
        if ([self.booking deliveryMode]) {
            message = @"Bác tài sắp tới điểm nhận hàng 😉";
        }
        if (!_chatViewModel) {
            [self initChatView];
        }
        [_chatViewModel sendMessage:message];
        sentNotifyToCustomer = YES;

        [[FirebaseHelper shareInstance] getClient:_booking.info.clientFirebaseId handler:^(FCClient * client) {
            if (client.deviceToken.length > 0) {
                [FirebasePushHelper sendPushTo:client.deviceToken
                                          type:NotifyTypeNewBooking
                                         title:@"Tài xế sắp đến"
                                       message:message];

            }
        }];
        
        if (!localPushDriver) {

            UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
            content.title = [NSString localizedUserNotificationStringForKey:@"Thông báo" arguments:nil];
            content.body = [NSString localizedUserNotificationStringForKey:@"Bạn đang sắp đến điểm đón"
                        arguments:nil];
            content.sound = [UNNotificationSound defaultSound];

            UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                        triggerWithTimeInterval:1 repeats:NO];
            UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"PickUp"
                        content:content trigger:trigger];
            
            localPushDriver = [UNUserNotificationCenter currentNotificationCenter];
            [localPushDriver addNotificationRequest:request withCompletionHandler:nil];
        }
    }

}


#pragma mark - Marker

- (void) addMarkerStart
{
    if (markerStart) {
        markerStart.map = nil;
    }
    markerStart = [[GMSMarker alloc] init];
    markerStart.icon = [UIImage imageNamed:@"marker-start"];
    markerStart.map = self.mapView;
    markerStart.position = CLLocationCoordinate2DMake(self.booking.info.startLat, self.booking.info.startLon);
}

- (void) addMarkerEnd
{
    if (self.booking.info.endLat == 0 || self.booking.info.endLon == 0)
    {
        DLog(@"Error location end, don't add marker end")
        return;
    }
    
    [self addMarkerEnd:CLLocationCoordinate2DMake(self.booking.info.endLat, self.booking.info.endLon)];
}

- (void) addMarkerEnd:(CLLocationCoordinate2D) coordinate
{
    if (!CLLocationCoordinate2DIsValid(coordinate) || (coordinate.latitude == 0 && coordinate.longitude == 0))
    {
        return;
    }
    
    if (markerEnd) {
        markerEnd.map = nil;
    }
    markerEnd = [[GMSMarker alloc] init];
    markerEnd.icon = [UIImage imageNamed:@"marker-end"];
    markerEnd.position = coordinate;
    markerEnd.map = self.mapView;
}

- (void) addMarkerDriver
{
    if (markerDriver) {
        markerDriver.map = nil;
    }
    markerDriver = [[GMSMarker alloc] init];
    markerDriver.map = self.mapView;
    markerDriver.icon = [UIImage imageNamed:[NSString stringWithFormat:@"m-car-%ld-12", (long)self.booking.info.serviceId]];
    if (markerDriver.icon == nil) {
        FCUCar* car = [[UserDataHelper shareInstance] getCurrentUser].vehicle;
        if (car.type == VehicleTypeBike) {
            markerDriver.icon = [UIImage imageNamed:@"m-car-8-12"];
        } else {
            markerDriver.icon = [UIImage imageNamed:@"m-car-32-12"];
        }
    }
    markerDriver.position = [FirebaseHelper shareInstance].currentDriverLocation.coordinate;
    markerDriver.flat = true;
    markerDriver.groundAnchor = CGPointMake(0.5f, 0.5f);
    markerDriver.rotation = arc4random() % 360;
}

- (void) updateMarkerOnMap:(GMSMarker*) marker atCurrent:(CLLocation*) newsLoc {
    if (!marker) {
        [self addMarkerDriver];
    }
    
    CLLocation* prev = [[CLLocation alloc] initWithLatitude:marker.position.latitude longitude:marker.position.longitude];
    double bearing = [prev bearingToLocation:newsLoc];
    
    if (bearing != 0) {
        marker.rotation = bearing;
    }
    marker.position = newsLoc.coordinate;
}

#pragma mark - Digital Trip

- (void) updateDistance:(CGFloat)distance
{
    NSString *distanceStr = [NSString stringWithFormat:@"%.1f km", distance / 1000];
    distanceStr = [distanceStr stringByReplacingOccurrencesOfString:@"." withString:@","];
    [self.labelDistance setText:distanceStr];
}

- (void) updatePrice:(NSInteger)price
{    
    [self.labelPrice setText:[self formatPrice:price withSeperator:@","]];
}

- (void) startTimer
{
    [self stopTimer];
    
    [[FirebaseHelper shareInstance] getServerTime:^(NSTimeInterval time) {
        if (clockTrip.timeStarted == 0) {
            clockTrip.timeStarted = time;
        }
        else {
            clockTrip.totalTime = MAX(time - clockTrip.timeStarted, 0);
        }
        
        // make sure run on main
        dispatch_async(dispatch_get_main_queue(), ^{
            currentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
            [currentTimer fire];
        });
    }];
}

- (void) updateNoteView {
    self.lblNote.text = self.booking.info.note;
    self.noteView.hidden = self.booking.info.note.length == 0;

    NSString* text = self.booking.info.note;
    [self scanerPhoneNumber:text complete:^(NSString *phone, NSRange range) {
        if (phone && range.length > 0)
            [self.lblNote underlineText:text atRange:range];
    }];
    
}

- (void) stopTimer
{
    if (currentTimer)
    {
        // make sure run on main
        dispatch_async(dispatch_get_main_queue(), ^{
            [currentTimer invalidate];
            currentTimer = nil;
        });
    }
}

#pragma mark - Places

- (IBAction)onAddressViewTouched:(id)sender {
    [self loadPlacePickerView:nil];
    
}

- (void) loadPlacePickerView:(id) sender {
    GoogleAutoCompleteViewController* vc = [[GoogleAutoCompleteViewController alloc] initViewController];
    [vc setMapview:self.mapView];
    [RACObserve(vc.googleViewModel, place) subscribeNext:^(FCPlace* x) {
        if (x) {
            [self handlerPlaceAutoComplete:x error:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) handlerPlaceAutoComplete: (FCPlace*) place error: (NSError*) er {
    // move camera
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(place.location.lat, place.location.lon);
    [self updateMaps:coordinate];

    // choose place
    if (clockTrip.endLocation == nil) {
        clockTrip.endLocation = [[FCPlace alloc] init];
    }
    
    [clockTrip.endLocation setLocation:[[FCLocation alloc] initWithLat:coordinate.latitude lon:coordinate.longitude]];
    [clockTrip.endLocation setName:place.name];
    [[UserDataHelper shareInstance] saveCurrentDigitalClockTrip:clockTrip
                                                        forBook:self.booking];
    
    [self addMarkerEnd:coordinate];
    [self.buttonDirection setHidden:NO];
    
    CLLocation *start = [[CLLocation alloc] initWithLatitude:self.booking.info.startLat
                                                   longitude:self.booking.info.startLon];
    [self drawPolylineFrom:start.coordinate
                        to:coordinate
                completion:nil];
    [self.labelAddress setText:place.address];
}

#pragma mark - constraint
- (void)updateUIByTripStatus: (BOOL) started
{
    if (self.booking.info.tripType == BookTypeOneTouch)
    {
        if (started)
        {
            [_topViewNormal setHidden:YES];
            [_tripMapInfoView setHidden:YES];
            [_noteView setHidden:YES];
            [_topViewDigitalClock setHidden:NO];
            [_topViewDigitalClock setAlpha:1.0f];
            
            [_addressView setHidden:NO];
            [_addressView setAlpha:1.0f];
        }
        else
        {
//            [_topViewNormal setAlpha:1.0f];
//            [_topViewNormal setHidden:NO];
            [_tripMapInfoView setHidden:NO];
            [_topViewDigitalClock setHidden:YES];
        }
    }
    else {
        [self updatePriceView: started];
    }
}

#pragma mark - Chats
- (void) initChatView {
    if (self.booking.info.tripType == BookTypeDigital) {
        return;
    }
    
    _chatViewModel = [[FCChatViewModel alloc] init];
    _chatViewModel.booking = self.booking;
    [_chatViewModel startChat];
    [self listenerNewChats];
    
    _chatView = [[FCChatView alloc] init];
    _chatView.chatViewModel = _chatViewModel;
    _chatView.ishidden = YES;
    [_chatView bindingData];
    [self showChatBadge:0]; // hide
}

- (void) showChatView {
    FCImageView* avatarView = [[FCImageView alloc] initWithImage:[UIImage imageNamed:@"avatar-placeholder"]];
    [[FirebaseHelper shareInstance] getClient:self.booking.info.clientFirebaseId
                                      handler:^(FCClient * client) {
                                          if (client) {
                                              _chatView.client = client;
                                              [avatarView sd_setImageWithURL:[NSURL URLWithString:client.photo] placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
                                              [avatarView circleView];
                                          }
                                      }];
    [avatarView circleView];
    [ChatHeadsController presentChatHeadWithView:avatarView
                                          chatID:self.booking.info.tripId];
    ChatHeadsController.datasource = self;
    ChatHeadsController.delegate = self;
    [ChatHeadsController expandChatHeadsWithActiveChatID:self.booking.info.tripId];
}

- (void) dismissChat {
    // hide chat
    [ChatHeadsController collapseChatHeads];
    [ChatHeadsController dismissAllChatHeads:YES];
}

- (void) dismissPackageVC: (void (^)(void))completion {
//    @weakify(self)
    if (self.presentedViewController) {
//        [self.presentedViewController dismissViewControllerAnimated:YES completion:completion];
        [self dismissViewControllerAnimated:YES completion:completion];
    } else {
        completion();
//        if (self.naviPackageVC == nil) {
//            completion();
//            return;
//        }
//        [self.naviPackageVC dismissViewControllerAnimated:NO completion:completion];
    }
//    [self dismissDeliveryFailVC:^{
//        @strongify(self)
//        if (self.naviPackageVC == nil) {
//            completion();
//            return;
//        }
//        [self.naviPackageVC dismissViewControllerAnimated:NO completion:completion];
//    }];
}

- (void) dismissDeliveryFailVC: (void (^)(void))completion {
    if (self.deliveryFailVC == nil) {
        completion();
        return;
    }
    [self.deliveryFailVC dismissViewControllerAnimated:NO completion:completion];
}

- (void) showChatBadge: (NSInteger) badge {
    [self.lblBadgeChat setHidden:badge == 0];
    [self.lblBadeChatExpress setHidden:badge == 0];
    [self.lbBadgetChatFood setHidden:badge == 0];
    if (badge > 9)
        [self.lblBadgeChat setText:[NSString stringWithFormat:@"%ld+", (long)badge]];
    else
        [self.lblBadgeChat setText:[NSString stringWithFormat:@"%ld", (long)badge]];
    
    [self.lblBadeChatExpress setText:self.lblBadgeChat.text];
    [self.lbBadgetChatFood setText:self.lblBadgeChat.text];
//    self.lbBadgetChatFood.text = @"9";
}

- (void) listenerNewChats {
    [RACObserve(_chatViewModel, chat) subscribeNext:^(FCChat* x) {
        if (x) {
            if (!_chatView || _chatView.ishidden) {
                _chatViewModel.noChats ++;
                [self notifyNewChat:x];
            }
            else {
                _chatViewModel.noChats = 0;
            }
            
            [ChatHeadsController setUnreadCount:_chatViewModel.noChats
                          forChatHeadWithChatID:self.booking.info.tripId];
            [self showChatBadge:_chatViewModel.noChats];
        }
    }];
}

- (void) notifyNewChat: (FCChat*) chat {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
    }
    else {
        [self playsound:@"message"
                 ofType:@"wav"
             withVolume:1.0f
                 isLoop:NO];
    }
}

- (UIView*) chatHeadsController:(FCChatHeadsController *)chatHeadsController viewForPopoverForChatHeadWithChatID:(NSString *)chatID {
    return _chatView;
}

- (void) chatHeadsControllerDidDisplayChatView:(FCChatHeadsController *)chatHeadsController {
    if (_chatView) {
        _chatViewModel.noChats = 0;
        [ChatHeadsController setUnreadCount:_chatViewModel.noChats
                      forChatHeadWithChatID:self.booking.info.tripId];
        _chatView.ishidden = NO;
        [self showChatBadge:0];
    }
}

- (void) chatHeadsController:(FCChatHeadsController *)chController didDismissPopoverForChatID:(NSString*) chatID {
    if (_chatView) {
        _chatView.ishidden = YES;
        [self dismissChat];
    }
}

- (void) chatHeadsController:(FCChatHeadsController *)chController didRemoveChatHeadWithChatID:(NSString*) chatID {
    if (_chatView) {
        _chatView.ishidden = YES;
    }
}

/// PackageInfoListener
#pragma mark - PackageInfoListener
- (void)didSelectCall {
    [self onCallClient:nil];
}

- (void)didSelectChat {
    [self onChatClicked:nil];
}

- (void)packageInfoDidSelectContinueWithSender:(PackageInfoVC *)sender {
    self.viewInfoExpress.hidden = NO;
    if ([self.booking deliveryFoodMode]) {
        self.hViewShadowFoodDetail.constant = 40 ;
        self.heightOfViewBottom.constant = 190;
        self.stackViewFood.hidden = NO;
    }
    
    [self startTrip];
   /*
    [sender dismissViewControllerAnimated:false completion:nil];
    [IndicatorUtils show];
    [_bookingService updateBookStatus:BookStatusDeliveryReceivePackageSuccess complete:^(BOOL success) {
        [IndicatorUtils dissmiss];
        [_bookingService updateInfoReceiveImages:[arrLinks map:^NSString * _Nonnull(NSURL * _Nonnull object) {
            return object.absoluteString;
        }]];
        [_bookingService updateLastestBookingInfo:_bookingService.book block:nil];
    }];
    */
}

/// ExpressSuccessListener
#pragma mark - ExpressSuccessListener
- (void)expressSuccessDidSelectContinueWithSender:(ExpressSuccessVC *)sender {
    [sender dismissViewControllerAnimated:true completion:nil];
    [self endTrip];
}

/// DeliveryFailVCDelegate
#pragma mark - DeliveryFailVCDelegate

- (void)confirmDeliveryFail:(NSDictionary<NSString *,id> *)param viewController:(UIViewController*) vc {
    [self.bookingService updateEndReason:param];
    [IndicatorUtils show];
    @weakify(self);
    [self.bookingService updateLastestBookingInfo:self.bookingService.book block:^(NSError *error) {
        @strongify(self);
        if (error != nil) {
            [AlertVC showErrorFor:self error:error];
        } else {
            [self playsound:@"cancel"];
            [self.bookingService updateBookStatus:BookStatuDeliveryFail complete:nil];
            @weakify(self);
            [vc dismissViewControllerAnimated:true completion:^{
                @strongify(self);
//                [self hideView];
                [self showReceiptView];
            }];
        }
        [IndicatorUtils dissmiss];
    }];
}


@end
