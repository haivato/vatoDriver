//
//  HomeViewController.m
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "HomeViewController.h"
#import "KYDrawerController.h"
#import "AppDelegate.h"
#import "GoogleMapsHelper.h"
#import "NSObject+Helper.h"
#import "JTMaterialSwitch.h"
#import "FCCreateCarViewController.h"
#import "FacecarNavigationViewController.h"
#import "MenusTableViewController.h"
#import "DigitalClockViewController.h"
#import "UIAlertController+Blocks.h"
#import "LinkAlertController.h"
#import "APICall.h"
#import "FCVatoPayViewController.h"
#import "FCBlockAccountView.h"
#import "TripMapViewController.h"
#import "CarManagementViewController.h"
#import "FCBalance.h"
#import "FCNotifyBannerView.h"
#import "XOREncryption.h"
#import "TimeUtils.h"
#import "FCWarningNofifycationView.h"
#import "FCPromotionPopupView.h"
#import "FCNewWebViewController.h"
#import "FCNotificationDetailViewController.h"
#import "FCBlock.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
#import <SDWebImage/SDWebImage.h>

#define ONLINE @"Trực tuyến"
#define OFFLINE @"Ngoại tuyến"
#define Height_View_Auto_Receive_Trip 74
#define Height_View_Action 200
@import Masonry;
extern NSString *DriverWantToCancelTripNotification;
@interface HomeViewController () <GMSMapViewDelegate, JTMaterialSwitchDelegate, FCPromotionPopupViewDelegate, HandlerPushProtocol, ShortcutDelegateProtocol, ListMarketingPointViewProtocol>
{
    GMSMarker* markerStart;
    GMSMarker* markerend;
    GMSPolyline* polyline;
    FirebaseHelper *firebase;
    GMSMarker* markerDriver;
}
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) UIButton *onlineStatus;
@property (weak, nonatomic) IBOutlet UIView *navigationView;

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lblCode;

@property (nonatomic, strong) NSTimer *loadingTimer;
@property (nonatomic, strong) FCWarningNofifycationView* blockView;

@property (nonatomic) UIAlertController* alertController;
// FAVORITE PLACE
@property (weak, nonatomic) IBOutlet UILabel *tipFavPlaceLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintViewAction;
@property (weak, nonatomic) IBOutlet UILabel *nameFavPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressFavPlaceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *viewTaxiMarketingPoint;

@property (weak, nonatomic) IBOutlet UIView *viewAutoReceiTrip;
@property (weak, nonatomic) IBOutlet UIButton *digitalButton;
@property (weak, nonatomic) IBOutlet UILabel *labelAppVersion;
@property (strong, nonatomic) QuickSupportDetailObjcWrapper *quickSupportDetail;
@property (strong, nonatomic) VatoShorcutView *shorcut;
@property (strong, nonatomic) ShorcurtWrapperObjC *routeShorcut;
@property (strong, nonatomic) TOOrderWrapperObjC *routeTOOrderWrapperObjC;
@property (weak, nonatomic) ListMarketingPointView *listMarketingPointView;
@property (weak, nonatomic) UIAlertView *alertReadyQueue;
@property (nonatomic) CarContractObjcWrapper *carContractObjcWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintDigitalBtn;
@property (nonatomic) NSTimer *timerReadyQueue;
@end

@implementation HomeViewController {
    BOOL isFirstTimeLoadMap;
}

- (void)loadView {
    [[VatoLocationManager shared] loadLenghtGeohash];
    [super loadView];
    [[VatoDriverUpdateLocationService shared] loadConfig];
    [[NotificationPushService instance] registerWithHandler:self];
    [[FirebaseTokenHelper instance] startUpdate];
    [[FireBaseTimeHelper default] startUpdate];
    [[BannerHelper instance] requestBanner];
}

- (void)showTripDigital {
    [self touchTripClock: nil];
}

- (void)listenCancel {
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DriverWantToCancelTripNotification object:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self listenCancel];
    self.digitalButton.hidden = YES;
    self.heightConstraintViewAction.constant = 0;
    self.view.backgroundColor = GREEN_COLOR;
    self.quickSupportDetail = [[QuickSupportDetailObjcWrapper alloc] initWith:self];
    firebase = [FirebaseHelper shareInstance];
    [_mapView setMinZoom:10 maxZoom:20];
    [[ThemeManager instance] requestThemConfig];
    
    [self initMaps];
    [self initSwithButton];
    [[ConfigManager shared] loadConfig];
    
    //driver keep alive
    [[GoogleMapsHelper shareInstance] startUpdateLocation];

    // show notification
    [self showRefferalDialog];
    
    // show driver code
    NSInteger userId = [[UserDataHelper shareInstance] getCurrentUser].user.id;
    if (userId > 0) {
        NSString* code = [XOREncryption encryptDecrypt:[NSString stringWithFormat:@"%ld", (long)userId]];
        self.lblCode.text = code;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppResume)
                                                 name:NOTIFICATION_RESUME_APP
                                               object:nil];
    __weak typeof(self) selfWeak = self;
    [self requestActiveModeFavPlaceMode];
    [NSNotificationCenter.defaultCenter addObserverForName:Update_Favorite_Mode object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [selfWeak showOrHiddenViewFavMode];
    }];
    
    // fix case user turn off net work => open app => can't request 
    [NSNotificationCenter.defaultCenter addObserverForName:NotifyNetWorkStatus object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        static BOOL isFirstEnter = YES;
        if (isFirstEnter == YES) {
            if ([selfWeak isNetworkAvailable] == true) {
                [selfWeak requestActiveModeFavPlaceMode];
                isFirstEnter = NO;
            }
        }
    }];
    
    //show appp information
    [[FirebaseHelper shareInstance] getDriver:^(FCDriver * driver) {
        if (driver) {
            [selfWeak.labelAppVersion setText:[NSString stringWithFormat:@"%li | %@", (long)driver.user.id, APP_VERSION_STRING]];
        }
    }];
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:NOTIFICATION_DIGITAL_CLOCK_CLOSE object:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:^{
            NSError *error = [NSError castFrom:x];
            if (error) {
                [UIAlertController showAlertInViewController:self
                                                   withTitle:@""
                                                     message:[error localizedDescription] ?: @"Lỗi"
                                           cancelButtonTitle:@"OK"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil
                                                    tapBlock:nil];
            }
            [[TOManageCommunication shared] startObserWhenFinishTrip];
        }];
    }];
    self.shorcut = [[VatoShorcutView alloc] initWithDescription:@"Hỗ trợ"];
    self.routeShorcut = [[ShorcurtWrapperObjC alloc] initWith:self];
    [self.view addSubview:_shorcut];
    
    self.routeTOOrderWrapperObjC = [[TOOrderWrapperObjC alloc] initWith:self];
    self.viewTaxiMarketingPoint.hidden = YES;
    if (![self.viewTaxiMarketingPoint viewWithTag:78024]) {
        ListMarketingPointView *view = [[ListMarketingPointView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300)];
        view.tag = 78024;
        self.listMarketingPointView = view;
        [self.viewTaxiMarketingPoint addSubview:view];
    }
    self.listMarketingPointView.listener = self;
    self.listMarketingPointView.parentController = self;
    FIRUser* user = [FIRAuth auth].currentUser;
    [VatoPermission.shared permissonTaxiWithUid:user.uid completion:^(BOOL permission) {
        @strongify(self);
        self.viewTaxiMarketingPoint.hidden = !permission;
        if (permission) {
            [[TOManageCommunication shared] start];
        } else {
            [[TOManageCommunication shared] stop];
        }
    }];
    [[TOManageCommunication shared] fireStoreNotify];
    UIButton *carContract = [[UIButton alloc] initWithFrame:CGRectZero];
    carContract.clipsToBounds = YES;
    carContract.layer.cornerRadius = 20;
    carContract.backgroundColor = [UIColor whiteColor];
    [carContract.titleLabel setFont:[UIFont systemFontOfSize:16 weight: UIFontWeightMedium]];
    [carContract setTitle:@" Xe hợp đồng " forState:(UIControlStateNormal)];
    [carContract setTitleColor: [UIColor colorWithRed:238/255.0 green:82/255.0 blue:34/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    [carContract addTarget:self action:@selector(touchCarContract) forControlEvents:UIControlEventTouchUpInside];
    [carContract setImage:[UIImage imageNamed:@"ic_vato_contract"] forState:(UIControlStateNormal)];
    [self.view addSubview:carContract];
    [carContract mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_shorcut.mas_centerY);
        make.left.mas_equalTo(self.view.mas_left).inset(16);
        make.size.mas_equalTo(CGSizeMake(143, 40));
    }];
    
    UILabel *lbContract = [[UILabel alloc] initWithFrame:CGRectZero];

    [TOManageCommunication.shared countContractWithCompletion:^(NSInteger count) {
        if (count > 0) {
            lbContract.text = [NSString stringWithFormat:@"  %d   ", count];
        } else {
            lbContract.text = @"";
        }
    }];
    
    lbContract.textColor = [UIColor whiteColor];
    lbContract.backgroundColor = [UIColor colorWithRed:238/255.0 green:82/255.0 blue:34/255.0 alpha:1.0];
    lbContract.font = [UIFont systemFontOfSize:10 weight: UIFontWeightBold];
    [self.view addSubview:lbContract];
    [lbContract mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(carContract);
    }];
    lbContract.clipsToBounds = YES;
    lbContract.layer.cornerRadius = 6;
    
    UIButton *currentLocation = [[UIButton alloc] initWithFrame:CGRectZero];
    [currentLocation addTarget:self action:@selector(touchCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [currentLocation setImage:[UIImage imageNamed:@"location"] forState:(UIControlStateNormal)];
    [self.view addSubview:currentLocation];
    [currentLocation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(carContract.mas_top);
        make.left.mas_equalTo(self.view.mas_left);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    
    
    
    [[ConfigManager shared] getRemoteConfigDigitalTypeWithCompletion:^(BOOL isDigital) {
        if (isDigital) {
            [VatoPermission.shared permissonTaxiWithUid:user.uid completion:^(BOOL permission) {
                @strongify(self);
                if (permission) {
                    [self.digitalButton setHidden:NO];
                    [currentLocation mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(carContract.mas_top).inset(40);
                    }];
                } else {
                    [self.digitalButton setHidden:YES];
                    [currentLocation mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(carContract.mas_top);
                    }];
                }
                [self.view layoutIfNeeded];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self.digitalButton setHidden:YES];
            });
            
        }
    }];
    [self.listMarketingPointView setRequestOnline:^{
        [AlertVC showMessageAlertFor:self title:@"Thông báo"
                             message:@"Bạn hãy Online để tham gia xếp tài"
                       actionButton1:@"Đóng"
                       actionButton2:nil
                            handler1:nil
                            handler2:nil];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"LogOutEvent" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        [self.listMarketingPointView removeFromSuperview];
        self.listMarketingPointView = nil;
    }];
    
    
    self.bottomConstraintDigitalBtn.constant = -30;
    CGFloat paddingShorcut = 20;
    // banner
    UIView *imageView = [[BannerHelper instance] loadFooterBanner];
    if (imageView != nil) {
        [self.view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.equalTo(_labelAppVersion.mas_top);
        }];
        CGFloat height = 70;
        self.mapView.padding = UIEdgeInsetsMake(0, 0, height, 0);
        paddingShorcut = paddingShorcut + height;
        self.bottomConstraintDigitalBtn.constant = -100;
    }
    
   if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        paddingShorcut = paddingShorcut + window.safeAreaInsets.bottom;
    }
    
    [_shorcut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
         make.bottom.mas_equalTo(-paddingShorcut);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    self.shorcut.layer.cornerRadius = 35;
    [[_shorcut rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self showShorcut];
    }];
    
    
    self.navigationController.navigationBarHidden = YES;
    
    [[QuickSupportManager shared] getListRequest];
    [self validateStateDriver];
//    [[FireStoreConfigDataManager shared] getConfigBuyUniform];
}

//- (void)checkSetOnOffTaxi:(BOOL) isPermission{
//    if (isPermission) {
//        [[ConfigManager shared] OnOffTaxiWithIsTaxi:isPermission complention:^(BOOL kkkk) {
//            if (isPermission) {
//
//            }
//        }];
//    } else {
//        [self.digitalButton setHidden:YES];
//    }
//}

- (void)setViewModel:(FCHomeViewModel *)viewModel{
    _viewModel = viewModel;
    @weakify(self);
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:viewModel.driver.user.avatarUrl] placeholderImage:[UIImage imageNamed:@"ic_register_default_avatar"]];
    [RACObserve(self.viewModel, driver) subscribeNext:^(FCDriver* driver) {
        @strongify(self);
        if (driver) {
            //avatar
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:driver.user.avatarUrl] placeholderImage:[UIImage imageNamed:@"ic_register_default_avatar"]];
        }
    }];
}

- (void) showShorcut {
    [self.routeShorcut present];
}

- (void)loadCurrentTrip {
    // Only check error
    @weakify(self);
    [[[FCBookingService shareInstance] loadCurrentTrip] subscribeError:^(NSError *error) {
        @strongify(self);
        [self checkingOnlineStatus:YES];
    }];
}

- (void) checkOnline {
    NSInteger status = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_LAST_ONLINE_STATE];
    [FCTrackingHelper trackEvent:@"Driver_Check_Online" value:@{@"value": @(status)}];
    switch (status) {
        case DRIVER_READY:
            if ([FCBookingService shareInstance].book != nil) {
                return;
            }
            [self checkingOnlineStatus:YES];
            break;
        case DRIVER_UNREADY:
            [self checkingOnlineStatus:NO];
            break;
        case DRIVER_BUSY:
            if ([FCBookingService shareInstance].book != nil) {
                // intrip don't need any work
            } else {
                // Find trip driver had, check in trip allow, because it didn't delete yet.
                [self loadCurrentTrip];
            }
        default:
            break;
    }
}

- (void) addListenCheck {
    RACSignal *v1 = [RACSignal return:nil];
    RACSignal *v2 = [[self rac_signalForSelector:@selector(viewWillAppear:)] takeUntil:[self rac_willDeallocSignal]];
    RACSignal *event = [RACSignal merge:@[v1, v2]];
    @weakify(self);
    [event subscribeNext:^(id x) {
        @strongify(self);
        [self checkOnline];
    }];

}

- (void)validateStateDriver {
    // if exist current trip -> move in trip
    // if not -> check state each move in
    @weakify(self);
    [[[FCBookingService shareInstance] loadCurrentTrip] subscribeNext:^(id x) {
        @strongify(self);
        [self addListenCheck];
    } error:^(NSError *error) {
        @strongify(self);
        [self addListenCheck];
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate:) name:NOTIFICATION_UPDATE_LOCATION object:nil];
    [self checkLocationPermission];
    [self updateMarker:[GoogleMapsHelper shareInstance].currentLocation];
    if (self.viewModel) {
        [self getAutoAccept];
    }
    [[TOManageCommunication shared] fireStoreNotify];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_LOCATION object:nil];
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CLLocation *currentLoc = self.mapView.myLocation;
    [self.mapView animateToLocation:currentLoc.coordinate];
    [self.mapView animateToZoom:17.0];
    
    if (self.viewModel.driver) {
        [self blockAccount:![self.viewModel.driver.active boolValue] blockInfo:self.viewModel.driver.lock];
    }
    
    if (!self.viewModel) {
        
        self.viewModel = [[FCHomeViewModel alloc] initViewModelWithViewController:self];
        [FCBookingService shareInstance].homeViewModel = self.viewModel;
        ((AppDelegate*) [UIApplication sharedApplication].delegate).homeViewModel = self.viewModel;
        
        [self bindingData];
        
        // menu view
        KYDrawerController *elDrawer = (KYDrawerController*)self.navigationController.parentViewController;
        MenusTableViewController* menuview = (MenusTableViewController*) ((FacecarNavigationViewController*) elDrawer.drawerViewController).topViewController;
        
        // favorite mode
        __weak typeof(self) selfWeak = self;
        [menuview setDidSelecFavMode:^(ActiveFavoriteModeModel *model) {
            [selfWeak didSelectFavMode:model];
        }];
        
        menuview.homeViewModel = self.viewModel;
        [menuview bindingData];
        
        // checking last online status
        // show popup notification
        [self checkPopupNotification];
        
        // handler push
        [self checkPushNotification];
    }
}

-(void)didSelectFavMode:(ActiveFavoriteModeModel *)model {
    KYDrawerController *elDrawer = (KYDrawerController*)self.navigationController.parentViewController;
    __weak typeof(self) selfWeak = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [elDrawer setDrawerState:KYDrawerControllerDrawerStateClosed animated:YES];
        [FavoritePlaceManager shared].activeFavoriteModeModel = model;
        [selfWeak showOrHiddenViewFavMode];
        if (selfWeak.onlineStatus.selected == NO) {
            [selfWeak didSelectOnlineStatus];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) onAppResume {
    [self checkLocationPermission];
}

- (void)requestActiveModeFavPlaceMode {
    __weak typeof(self) selfWeak = self;
    [[FavoritePlaceManager shared] getStatusFavModeWithComplete:^(NSError *error) {
        if (error == nil) {
            [selfWeak showOrHiddenViewFavMode];
        }
    }];
}

- (void) checkLocationPermission {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus stt = [CLLocationManager authorizationStatus];
        if (stt == kCLAuthorizationStatusDenied) {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Yêu cầu truy cập vị trí"
                                                 message:@"Điều này giúp chúng tôi định vị chính xác vị trí của bạn để giúp bạn thuận tiện trong việc đón và trả khách."
                                       cancelButtonTitle:@"Đồng ý"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                    if (buttonIndex == 0) {
                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                    }
                                                }];
        }
        else {
            @weakify(self)
            __block RACDisposable* hanlder = [RACObserve([GoogleMapsHelper shareInstance], currentLocation) subscribeNext:^(CLLocation* x) {
                if (x) {
                    [self_weak_.mapView animateToLocation:x.coordinate];
                    [self_weak_.mapView animateToZoom:17.0];
                    [self_weak_ updateMarker:x];
                    [hanlder dispose];
                }
            }];
            [[GoogleMapsHelper shareInstance] startUpdateLocation];
        }
    }
}

- (void) showOrHiddenViewFavMode {
    [self fillDataFavMode];
    
    BOOL isShow = false;
    ActiveFavoriteModeModel *activeFavoriteModeModel = [FavoritePlaceManager shared].activeFavoriteModeModel;
    if (activeFavoriteModeModel != nil && activeFavoriteModeModel.getIsActive == true) {
        isShow = true;
    } else {
        isShow = false;
    }

    if (isShow && (self.heightConstraintViewAction.constant == Height_View_Action)) {
        return;
    }
    
    self.heightConstraintViewAction.constant = isShow ? Height_View_Action : 0;
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        [self.view layoutIfNeeded];
    }];
}

- (void) bindingData {
    @weakify(self);
    [RACObserve(self.viewModel, driver) subscribeNext:^(FCDriver* driver) {
        if (driver) { 
            [self_weak_ blockAccount:![driver.active boolValue] blockInfo: driver.lock];
            
            [self_weak_ addMarkerDriver];
        }
    }];
    
    [self getAutoAccept];
        
    [RACObserve(self.viewModel, onlineStatus) subscribeNext:^(FCOnlineStatus* online) {
        if (online) {
            // set on/off status
            self.onlineStatus.selected = (online.status == DRIVER_READY);
            if (online.status == DRIVER_READY) {
                self.listMarketingPointView.isOnline = YES;
            }
//            if (online.status == DRIVER_UNREADY) {
//                ActiveFavoriteModeModel *activeFavoriteModeModel = [FavoritePlaceManager shared].activeFavoriteModeModel;
//                if (activeFavoriteModeModel != nil
//                    && activeFavoriteModeModel.getIsActive == true) {
//                    [self turnOffModeFavorite:nil];
//                }
//            }
        }
    }];
}

- (void) getAutoAccept {
    @weakify(self);
    [self.viewModel addAutoAccept:^(NSNumber* autoAccept) {
        @strongify(self);
        if (!autoAccept) {
            [UserDataHelper shareInstance].autoAccept = autoAccept;
            AutoReceiveTripManager.shared.flagAutoReceiveTripManager = NO;
            return;
        }
        
        [self checkingAutoAccept:[autoAccept boolValue]];
        [UserDataHelper shareInstance].autoAccept = autoAccept;
    }];
}

- (void) checkingAutoAccept:(BOOL) isAutoAccept {
    if (!isAutoAccept) {
        AutoReceiveTripManager.shared.flagAutoReceiveTripManager = isAutoAccept;
    }
}


- (void) blockAccount: (BOOL) block blockInfo: (FCBlock*) info {
    // remove block view first
    if (self.blockView) {
        [self.blockView removeFromSuperview];
        self.blockView = nil;
    }
    
    if (block || info.timestamp > [self getCurrentTimeStamp]) {
        
        // move to offline only in homeview
        AppDelegate* appdelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        id visiableVC = [appdelegate visibleViewController:self];
        if ([visiableVC isKindOfClass:[HomeViewController class]] ) {
            [[FirebaseHelper shareInstance] driverOffline:^(NSError * _Nullable error, FIRDatabaseReference * _Nullable ref) {
                
            }];
        }
        
        
        // block navigation
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        
        // add block view
        NSString* title = @"Tài khoản bị tạm khoá";
        NSString* message = @"Mọi chi tiết vui lòng liên hệ tổng đài 19006667 để được hỗ trợ.";
        if (info > 0 && info.timestamp > [self getCurrentTimeStamp]) {
            title = [NSString stringWithFormat:@"%@ đến: %@", title, [self getTimeString:info.timestamp withFormat:@"yyyy/MM/dd HH:mm:ss"]];
            message = info.description;
        }
        
        
        self.blockView = [[FCWarningNofifycationView alloc] intView];
        self.blockView.bgColor = [UIColor whiteColor];
        self.blockView.messColor = [UIColor darkGrayColor];
        self.blockView.alpha = 0.9;
        [self.blockView show:self.view
                       image:[UIImage imageNamed:@"block"]
                       title:title
                     message:message];
        self.blockView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
        
        [self.navigationController.view addSubview:self.blockView];
        self.navigationController.navigationBar.translucent = YES;
        
        // menu button
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"menu-b"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onMenuClicked:)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(15, 15, 40, 40)];
        [self.blockView addSubview:button];
    }
    else {
        // unblock navigation
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    }
}

- (void) checkingOnlineStatus:(BOOL) isOnline {
    self.onlineStatus.selected = isOnline;
    [self showLoading];
    if (isOnline) {
        @weakify(self);
        [firebase driverOnline:^(NSError* error, FIRDatabaseReference* ref) {
            [self_weak_ dismissLoading];
        }];
        self.navigationItem.title = ONLINE;
    }
    else {
        @weakify(self);
        [firebase driverOffline:^(NSError * _Nullable error, FIRDatabaseReference * _Nullable ref) {
            [self_weak_ dismissLoading];
        }];
        self.navigationItem.title = OFFLINE;
    }
}

- (void) showRefferalDialog {
    FCConfigs* config = [FirebaseHelper shareInstance].appConfigs;
    if (config && config.notification.active && [[UserDataHelper shareInstance] allowShowNotification]) {
        LinkAlertController *alert = [LinkAlertController alertWithTitle:@"Thông báo từ VATO" message:config.notification.message buttonTitles:@[@"Không hiển thị lại", @"Đóng"]];
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:alert animated:YES completion:nil];
        
        [[alert.alertButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            if (x) {
                if ([alert.imgCheckbox.image isEqual:[UIImage imageNamed:@"checkbox"]]) {
                    [[UserDataHelper shareInstance] cacheNotificationStatus:NO];
                }
                
                [alert dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (void) notifyCreateCar {
    if (self.alertController != nil) {
        return;
    }
    
    @weakify(self);
   self.alertController = [UIAlertController showAlertInViewController:self
                                       withTitle:@"Thông báo"
                                         message:@"Rấc tiếc, bạn chưa đăng ký xe nào trong hệ thống.\nĐăng ký ngay!"
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"Đóng"
                               otherButtonTitles:@[@"Đăng ký"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if (buttonIndex == 2) {
                                                [self_weak_ loadCreateCar];
                                            }
                                            self_weak_.onlineStatus.selected = FALSE;
                                            self_weak_.alertController = nil;
                                        }];
}

-(void) loadFavPlace {
    FavoritePlaceViewController *vc = [[FavoritePlaceViewController alloc] init];
    __weak typeof(self) selfWeak = self;
    [vc setDidSelectModel:^(ActiveFavoriteModeModel *model) {
        [FavoritePlaceManager shared].activeFavoriteModeModel = model;
        [selfWeak showOrHiddenViewFavMode];
    }];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navController animated:TRUE completion:nil];
}

- (void) loadCreateCar {
    CarManagementViewController* vc = [[CarManagementViewController alloc] initViewWithHomeViewModel:self.viewModel];
    FacecarNavigationViewController* nav = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) fillDataFavMode{
    ActiveFavoriteModeModel *activeFavoriteModeModel = [FavoritePlaceManager shared].activeFavoriteModeModel;
    if (activeFavoriteModeModel == nil) {
        return;
    }
    self.nameFavPlaceLabel.text = [activeFavoriteModeModel getNamePlace];
    self.addressFavPlaceLabel.text = [activeFavoriteModeModel getAddressPlace];
    self.iconImageView.image = [UIImage imageNamed:[activeFavoriteModeModel getIconName]];
    
    UIColor *darkBlueGreenColor =  [UIColor colorWithRed:0.0 green:97/255.f blue:61/255.f alpha:1.0];
    NSString *value = [NSString stringWithFormat:@"%lld/%lld", [activeFavoriteModeModel getNumberActiveInDay], [activeFavoriteModeModel getMaxActiveInDay]];
    NSString *text = [NSString stringWithFormat:@"Đang bật điều hướng về địa điểm cá nhân (%@)", value];
    NSInteger fromBold = text.length - 1 - value.length;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f weight:UIFontWeightRegular],                                                           NSForegroundColorAttributeName: darkBlueGreenColor, NSKernAttributeName: @(0.0)}];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:239.0f / 255.0f green:82.0f / 255.0f blue:34.0f / 255.0f alpha:1.0f] range:NSMakeRange(fromBold, value.length)];
    
    self.tipFavPlaceLable.attributedText = attributedString;
    
}

- (void) showTOOrderDriver {
    [self.routeTOOrderWrapperObjC present];
}

- (void)notifyVibrateDevice {
    [self vibrateDevice];
}

- (void) playSoundUpdateQueue {
    if (self.alertReadyQueue != nil) {
        return;
    }
    [self playsound:@"tripbook" withVolume:1.0f isLoop:YES];
    
    [self vibrateDevice];
    @weakify(self);
    self.timerReadyQueue = [NSTimer scheduledTimerWithTimeInterval:30 repeats:NO block:^(NSTimer * timer) {
        @strongify(self);
        [self stopSound];
        [self stopTimerAutoReceiveTrip];
    }];
    
    
    self.alertReadyQueue = [UIAlertView showWithTitle:@"Sẵn sàng xếp tài" message:@"Bạn đã vào danh sách sẵn sàng xếp tài. Vui lòng vào vị trí chuẩn bị đón khách" cancelButtonTitle:@"Đóng" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        @strongify(self);
        [self stopSound];
        [self stopTimerAutoReceiveTrip];
        self.alertReadyQueue = nil;
    }];
}

- (void)stopTimerAutoReceiveTrip {
    [self.timerReadyQueue invalidate];
    self.timerReadyQueue = nil;
}

#pragma mark - Popup notification
- (void) checkPopupNotification {
    AppDelegate* applegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    if (applegate.pushData) {
        return;
    }
    
    CLLocation* location = [GoogleMapsHelper shareInstance].currentLocation;
    @weakify(self);
    [[FirebaseHelper shareInstance] getZoneByLocation:location.coordinate handler:^(FCZone * zone) {
        @strongify(self);
        if (zone) {
            @weakify(self);
            [self.viewModel apiGetPromotionNow:zone.id complete:^(FCManifest *manifest, FCManifestPredicate* predicate) {
                @strongify(self);
                if (manifest) {
                    [self showPopupNotification:manifest predicate:predicate];
                }
            }];
        }
    }];
}

- (void) showPopupNotification: (FCManifest*) manifest predicate: (FCManifestPredicate*) predicate {
    AppDelegate* applegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    UIViewController* vc = [applegate visibleViewController:self];
    if (![vc isKindOfClass:[HomeViewController class]]) {
        return;
    }
    
    FCPromotionPopupView* popup = [[FCPromotionPopupView alloc] intView];
    [popup loadPromotionData:manifest predicate:predicate];
    popup.delegate = self;
    [self.navigationController.view addSubview:popup];
}

- (void) onPromotionPopupDetailClicked:(FCManifest *)manifest predicate:(FCManifestPredicate *)predicate{
    if (predicate.type == NotifyTypeLink && predicate.extra.length > 0) {
        FCNewWebViewController* webview = [[FCNewWebViewController alloc] init];
        [webview setTitle:manifest.title.length > 0 ? manifest.title:@"VATO thông báo"];
        if ([predicate.extra containsString:@"https://id"]) {
            @weakify(self);
            [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
                @strongify(self);
                @try {
                    NSString* link = [NSString stringWithFormat:@"%@?token=%@", predicate.extra, token];
                    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                    [cookieProperties setObject:@"x-access-token" forKey:NSHTTPCookieName];
                    [cookieProperties setObject:token forKey:NSHTTPCookieValue];
                    
                    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
                    
                    [self presentViewController:webview
                                       animated:YES
                                     completion:^{
                                         [webview loadWebview:link];
                                     }];
                }
                @catch (NSException* e) {
                    DLog(@"Error: %@", e)
                }
            }];
        }
        else {
            [self presentViewController:webview animated:YES completion:^{
                [webview loadWebview:predicate.extra];
            }];
        }
    }
}

- (void) onPromotionPopupCloseClicked {}

#pragma mark - Handler Push notification
- (void)updatePushWithInfo:(NSDictionary<NSString *,id> *)info {}

- (void) checkPushNotification {
    AppDelegate* applegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    @weakify(self);
    [RACObserve(applegate, pushData) subscribeNext:^(NSDictionary* x) {
        if (x) {
            [self_weak_ handlerPushNotification:x];
        }
    }];
}

- (void) handlerPushNotification: (NSDictionary*) pushData {
    AppDelegate* applegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    UIViewController* vc = [applegate visibleViewController:self];
    if (![vc isKindOfClass:[HomeViewController class]]) {
        return;
    }
    
    if (![pushData valueForKey:@"aps"]) {
        return;
    }
    
    NSDictionary* aps = [pushData objectForKey:@"aps"];
    if (![aps valueForKey:@"extra"]) {
        return;
    }
    
    if (![aps valueForKey:@"type"]) {
        return;
    }
    
    NSString* extra = [aps objectForKey:@"extra"];
    NSInteger type = [[aps objectForKey:@"type"] integerValue];
    if (type == NotifyTypeLink && extra.length > 0) {
        FCNewWebViewController* webview = [[FCNewWebViewController alloc] init];
        [webview setTitle:@"VATO thông báo"];
        
        if ([extra containsString:@"https://id"]) {
            @weakify(self);
            [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
                @strongify(self)
                @try {
                    NSString* link = [NSString stringWithFormat:@"%@?token=%@", extra, token];
                    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                    [cookieProperties setObject:@"x-access-token" forKey:NSHTTPCookieName];
                    [cookieProperties setObject:token forKey:NSHTTPCookieValue];
                    
                    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
                    
                    [self presentViewController:webview
                                       animated:YES
                                     completion:^{
                                         [webview loadWebview:link];
                                     }];
                }
                @catch (NSException* e) {
                    DLog(@"Error: %@", e)
                }
            }];
        }
        else {
            [self presentViewController:webview animated:YES completion:^{
                [webview loadWebview:extra];
            }];
        }
    }
    else if (extra.length > 0) {
        @weakify(self);
        [self.viewModel apiGetPromotionDetail:extra completed:^(FCNotification * notify) {
            @strongify(self);
            if (notify) {
                FCNotificationDetailViewController* vc = [[FCNotificationDetailViewController alloc] initView];
                [(FCNotificationDetailViewController*) vc setNotification:notify];
                FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
                [self  presentViewController:navController animated:TRUE completion:nil];
            }
        }];
    }
}

#pragma mark - Progress Loading

- (void) showLoading {
    self.progressView.hidden = NO;
    [self startLoadProgressBar];
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(startLoadProgressBar) userInfo:nil repeats:TRUE];
}

- (void) dismissLoading {
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

#pragma mark - Custom Switch button
- (void) initSwithButton {
    self.onlineStatus = [[UIButton alloc] init];
    [self.onlineStatus setImage:[UIImage imageNamed:@"ic_offline_status"] forState:(UIControlStateNormal)];
    [self.onlineStatus setImage:[UIImage imageNamed:@"ic_online_status"] forState:(UIControlStateSelected)];
    [self.navigationView addSubview:self.onlineStatus];
    [self.onlineStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.right.equalTo(self.navigationView.mas_right);
    }];
    [self.onlineStatus addTarget:self action:@selector(didSelectOnlineStatus) forControlEvents:UIControlEventTouchUpInside];
}

- (void) didSelectOnlineStatus {
    if (![self isNetworkAvailable]) {
        if (self.onlineStatus.state != UIControlStateSelected) {
            self.onlineStatus.selected = YES;
        } else {
            self.onlineStatus.selected = NO;
        }
        return;
    }
    
    if (!self.viewModel.driver.vehicle) {
        [self notifyCreateCar];
        self.navigationItem.title = OFFLINE;
        return;
    }
    
   
    
    if (self.listMarketingPointView.viewJoined.isHidden == false ) {
        [AlertVC showMessageAlertFor:self
                               title:@"Thông báo"
                             message:@"Ngoại tuyến khi đang trong điểm tiếp thị sẽ tự động ra khỏi điểm. Bạn có chắc chắn muốn ngoại tuyến không?"
                       actionButton1:@"Đóng"
                       actionButton2:@"OK"
                            handler1:nil
                            handler2:^{
            [[TOManageCommunication shared] leaveGroup];
            [self updateOnlineStatus];;
        }];
    } else {
        [self updateOnlineStatus];
    }

}
- (void) updateOnlineStatus {
    BOOL online = !(self.onlineStatus.selected == YES);
       // tracking
       [[FirebaseHelper shareInstance] updateTimeOnlineHistory:online];
       
       OnlineStatus nextStatus = online ? DRIVER_READY : DRIVER_UNREADY;
       NSString *title = online ? ONLINE : OFFLINE;
       self.onlineStatus.selected = online;
       self.listMarketingPointView.isOnline = online;
       @weakify(self);
       [[self updateStateDriver:nextStatus] subscribeNext:^(id value) {
           @strongify(self);
           FCOnlineStatus *stt = self.viewModel.onlineStatus;
           stt.status = nextStatus;
           self.viewModel.onlineStatus = stt;
           self.navigationItem.title = title;
           
       } error:^(NSError *error) {
           @strongify(self);
           DLog(@"%@", [error localizedDescription]);
           self.onlineStatus.selected = NO;
           self.viewModel.onlineStatus.status = DRIVER_UNREADY;
           
           [[FCNotifyBannerView banner] show:nil
                                     forType:FCNotifyBannerTypeError
                                    autoHide:NO
                                     message:@"Xảy ra lỗi TRỰC TUYẾN, bạn vui lòng thử lại sau."
                                  closeClick:nil
                                 bannerClick:nil];
       }];
}

- (RACSignal *)updateStateDriver: (OnlineStatus) status {
    @weakify(self);
    [self showLoading];
    [IndicatorUtils show];
    NSString *fmusic = status == DRIVER_READY ? @"online" : @"offline";
    [self playsound:fmusic withVolume:0.5f isLoop:NO];
    
    return [[[[self updateStatusToFirebase:status] flattenMap:^RACStream *(id value) {
        @strongify(self);
        if (!self) {
            return [RACSignal empty];
        }
        if (status != DRIVER_READY) {
            ActiveFavoriteModeModel *activeFavoriteModeModel = [FavoritePlaceManager shared].activeFavoriteModeModel;
            if (activeFavoriteModeModel != nil
                && activeFavoriteModeModel.getIsActive == true) {
                [self turnOffModeFavorite:nil];
            }
        }
        return [self updateStatusToBackend:status];
    }] doError:^(NSError *error) {
        @strongify(self);
        [IndicatorUtils dissmiss];
        [self dismissLoading];
    }] doCompleted:^{
        @strongify(self);
        [IndicatorUtils dissmiss];
        [self dismissLoading];
    }];
}

- (RACSignal *)updateStatusToFirebase: (OnlineStatus) status {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (!self) {
            [subscriber sendCompleted];
            return nil;
        }
        
        void (^blockHandler)(NSError * error, FIRDatabaseReference * ref) = ^(NSError * error, FIRDatabaseReference * ref) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:ref];
                [subscriber sendCompleted];
            }
        };
        
        FirebaseHelper *fHelper = self -> firebase;
        status == DRIVER_READY ? [fHelper driverOnline:blockHandler] : [fHelper driverOffline:blockHandler];
        return nil;
    }];
}

- (RACSignal *)updateStatusToBackend: (OnlineStatus) status {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (!self) {
            [subscriber sendCompleted];
            return nil;
        }
        
        [self.viewModel apiUpdateOnlineStatus:status handler:^(BOOL success) {
            if (success) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } else {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo: @{ NSLocalizedDescriptionKey : @" Can't update state"}];
                [subscriber sendError:error];
            }
        }];
        return nil;
    }];
}

- (void) canStartDigital: (void (^) (BOOL)) block {
    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_GET_BALANCE
                            params:nil
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                              @try {
                                  
                                  NSInteger amountRequire = MIN_AMOUNT_REQUIRE;
                                  FCBalance* balance = [[FCBalance alloc] initWithDictionary:response.data
                                                                                       error:nil];
                                  NSInteger amount = balance.credit;
                                  block(amount >= amountRequire);
                                  
                              }
                              @catch (NSException* e) {
                                  DLog(@"Error: %@", e)
                              }
                          }];
}

- (void) startDigitalTrip {
    [IndicatorUtils showWithAllowDismiss:NO];
    CLLocation *location = [GoogleMapsHelper shareInstance].currentLocation;
    FCUCar* car = [[UserDataHelper shareInstance] getCurrentUser].vehicle;
    NSInteger serviceID = 0;
    for (id item in car.services)
    {
        NSInteger object1 = [item intValue];
        if (object1 == 32) {
            serviceID = 32;
        } else if (object1 == 64) {
            serviceID = 64;
        }
    }
    [[FirebaseHelper shareInstance] getFareDetail:serviceID
                                             tripType:4
                                           atLocation:location
                                            taxiBrand: car.taxiBrand
                                              handler:^(FCFareSetting *receipt, NSArray<FCFarePredicate*> *predecates, NSArray<FCFareModifier*> *modifiers) {
            [IndicatorUtils dissmiss];
            if (receipt)
            {
                [[FCBookingService shareInstance] createDigitalBookingData];
                [[TOManageCommunication shared] cancelQueueWhenReceiveOtherTrip];
                if (self.viewModel.onlineStatus.status != DRIVER_READY) {
                    DigitalClockViewController *vc = [[DigitalClockViewController alloc] initWithNibName:@"DigitalClockViewController" bundle:nil];
                    vc.booking = [FCBookingService shareInstance].book;
                    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
                    [self presentViewController:vc
                                       animated:YES
                                     completion:^{
                                     }];
                }
            }
            else
            {
                [self showAlertError:@"Có lỗi xảy ra"];
                
            }
        }];

}

- (void) showAlertError:(NSString*)error
{
    [AlertVC showMessageAlertFor:self
                           title:@"Thông báo"
                         message:@"Chuyến đi đồng hồ thực tế không hỗ trợ. Liên hệ ban quản trị để được hỗ trợ "
                   actionButton1:@"Đóng"
                   actionButton2:nil
                        handler1:nil
                        handler2:nil];
    
}

- (void) notifyDontEnoughMoney {
    @weakify(self);
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Thông báo"
                                         message:@"Rất tiếc, số dư trong VATOPAY của bạn không đủ để sử dụng tính năng này! Bạn có muốn nạp tiền?"
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"Đóng"
                               otherButtonTitles:@[@"Đồng ý"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            @strongify(self);
                                            if (buttonIndex == 2)
                                            {
                                                FCVatoPayViewController* vc = [[FCVatoPayViewController alloc] init];
                                                FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
                                                [self presentViewController:navController   animated:YES completion:^{
                                                    
                                                }];
                                            }
                                        }];
}

#pragma mark - Handler actions

- (void) touchCarContract {
    self.carContractObjcWrapper = [[CarContractObjcWrapper alloc] initWith:self];
//    [self.carContractObjcWrapper presentVC];
    [self.carContractObjcWrapper presentListCar];
}

- (void) touchCurrentLocation {
    CLLocation *location = GoogleMapsHelper.shareInstance.currentLocation;
    if (CLLocationCoordinate2DIsValid(location.coordinate)) {
        GMSCameraPosition *currentLocation = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                                         longitude:location.coordinate.longitude
                                                                              zoom:17];
        [self.mapView setCamera:currentLocation];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

- (IBAction)touchTripClock:(id)sender {
    if (!self.viewModel.driver.vehicle) {
        [self notifyCreateCar];
        return;
    }
    @weakify(self);
    NSInteger currentStatus = self.viewModel.onlineStatus.status;
    [[FirebaseHelper shareInstance] updateDriverStatus:DRIVER_BUSY];
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Đồng hồ tính tiền"
                                         message:@"Đồng hồ điện tử giúp bạn tính cước phí theo lộ trình, thời gian thực tế của chuyến đi. Bạn có muốn sử dụng?"
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"Huỷ bỏ"
                               otherButtonTitles:@[@"Đồng ý"]
                                        tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex) {
        @strongify(self);
        if (buttonIndex == 2)
        {
            @weakify(self);
            [self canStartDigital:^(BOOL can) {
                @strongify(self);
                if (can) {
                    [self startDigitalTrip];
                }
                else {
                    [self notifyDontEnoughMoney];
                    if (currentStatus == DRIVER_READY) {
                        [[FirebaseHelper shareInstance] driverReady];
                    }
                }
            }];
        }
        else if (currentStatus == DRIVER_READY) {
            [[FirebaseHelper shareInstance] driverReady];
        }
    }];
}

- (IBAction)onMenuClicked:(id)sender {
    KYDrawerController *elDrawer = (KYDrawerController*)self.navigationController.parentViewController;
    [elDrawer setDrawerState:KYDrawerControllerDrawerStateOpened animated:YES];
}

- (IBAction)turnOffModeFavorite:(id)sender {
    __weak typeof(self) selfWeak = self;
    [IndicatorUtils show];
    [FavoritePlaceManager.shared turnOffFavoriteModeWithTripId:@"" complete:^(NSError *error) {
        if (error != nil) {
            [AlertVC showErrorFor:selfWeak message:error.localizedDescription];
        } else {
            [selfWeak showOrHiddenViewFavMode];
        }
        [IndicatorUtils dissmiss];
    }];
}

- (IBAction)didTouchButtonTurnOffFavoriteMode:(id)sender {
}

- (IBAction)didTouchButtonChangePlaceFavorite:(id)sender {
    FavoritePlaceViewController *vc = [[FavoritePlaceViewController alloc] init];
    __weak typeof(self) selfWeak = self;
    [vc setDidSelectModel:^(ActiveFavoriteModeModel *model) {
        [FavoritePlaceManager shared].activeFavoriteModeModel = model;
        [selfWeak showOrHiddenViewFavMode];
    }];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [self presentViewController:navController animated:TRUE completion:nil];
}

#pragma mark - Location Delegate
- (void)locationUpdate:(NSNotification*)notification
{
    CLLocation *location = notification.object;
    
    firebase.currentDriverLocation = location;
    
    if (!isFirstTimeLoadMap) {
        isFirstTimeLoadMap = true;
        
        [self updateMaps:location.coordinate];
    }
    
    [self updateMarker:location];
}

#pragma mark - Maps
- (void) initMaps {
    self.mapView.delegate = self;
    
    // custom map
    NSURL *nightURL = [[NSBundle mainBundle] URLForResource:@"custom-map"
                                              withExtension:@"json"];
    GMSMapStyle* nightStyle = [GMSMapStyle styleWithContentsOfFileURL:nightURL error:NULL];
    self.mapView.mapStyle = nightStyle;
    
    self.mapView.settings.rotateGestures = NO;
    self.mapView.settings.myLocationButton = NO;
    self.mapView.myLocationEnabled = YES;
    
    for (UIView *object in self.mapView.subviews) {
        if([[[object class] description] isEqualToString:@"GMSUISettingsView"] )
        {
            for(UIView *view in object.subviews) {
                if([[[view class] description] isEqualToString:@"GMSx_QTMButton"] ) {
                    [view layoutIfNeeded];
                    [view setBackgroundColor:[UIColor whiteColor]];
                    
                    UIImageView* icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gps-green"]];
                    icon.frame = CGRectMake(10, 10, 20, 20);
                    [view addSubview:icon];
                    view.frame = CGRectMake(0, 0, 40, 40);
                }
            }
            
        }
        else if([[[object class] description] isEqualToString:@"GMSUISettingsPaddingView"] ) {
            for(UIView *obj in object.subviews) {
                if([[[obj class] description] isEqualToString:@"GMSUISettingsView"] )
                {
                    for(UIView *view in obj.subviews) {
                        
                        if([[[view class] description] isEqualToString:@"GMSx_QTMButton"] ) {
                            [view layoutIfNeeded];
                            [view setBackgroundColor:[UIColor whiteColor]];
                            
                            UIImageView* icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gps-green"]];
                            icon.frame = CGRectMake(10, 10, 20, 20);
                            [view addSubview:icon];
                            view.frame = CGRectMake(0, 0, 40, 40);
                        }
                    }
                    
                }
            }
            
        }
    };
}

/*
 - Clear maps when get driver data success
 - Readd all maker start, end, polyline if have before
 */
- (void) resetMaps {
    [self.mapView clear];
}

- (void) updateMaps:(CLLocationCoordinate2D) lo {
    self.mapView.camera = [GMSCameraPosition cameraWithTarget:lo zoom:14];
}

#pragma mark - Driver Marker
- (void) addMarkerDriver {
    CLLocation* location = [GoogleMapsHelper shareInstance].currentLocation;
    if (!location || location.coordinate.latitude == 0 || location.coordinate.longitude == 0) {
        return;
    }
    
    FCUCar* car = self.viewModel.driver.vehicle;
    if (!car) {
        car = [[UserDataHelper shareInstance] getCurrentUser].vehicle;
    }
    
    if (markerDriver) {
        markerDriver.map = nil;
        markerDriver = nil;
    }
    
    if (car && !markerDriver) {
        markerDriver = [[GMSMarker alloc] init];
        markerDriver.map = self.mapView;
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"m-car-%ld-12", (long)car.service]];
        if (image == nil) {
            if (car.type == VehicleTypeBike) {
                image = [UIImage imageNamed:@"m-car-8-12"];
            } else {
                image = [UIImage imageNamed:@"m-car-32-12"];
            }
        }
        markerDriver.icon = image;
        
        markerDriver.position = [FirebaseHelper shareInstance].currentDriverLocation.coordinate;
        markerDriver.flat = true;
        markerDriver.groundAnchor = CGPointMake(0.5f, 0.5f);
        markerDriver.rotation = arc4random() % 360;
    }
}

- (void) updateMarker:(CLLocation*) newsLoc {
    if (!markerDriver) {
        [self addMarkerDriver];
    }
    else {
        CLLocation* prev = [[CLLocation alloc] initWithLatitude:markerDriver.position.latitude  longitude:markerDriver.position.longitude];
        double bearing = [prev bearingToLocation:newsLoc];
        
        if (bearing != 0) {
            markerDriver.rotation = bearing;
        }
        markerDriver.position = newsLoc.coordinate;
    }
}

@end
