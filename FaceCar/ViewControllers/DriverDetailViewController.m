//
//  DriverDetailViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/4/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "DriverDetailViewController.h"
#import "NavigatorHelper.h"
#import "ProfileViewController.h"
#import "DriverTripsViewController.h"
#import "AppDelegate.h"
#import "TripMapsViewController.h"
#import "CRToast.h"
#import "MBCircularProgressBarView.h"

#define waiting_timeout 30

@interface DriverDetailViewController ()

@property (strong, nonatomic) FCFavorite* favInfo;
@property (strong, nonatomic) FCClient* client;
@property (strong, nonatomic) FCMCar* car;
@property (assign, nonatomic) BOOL isWaitingTripBook;
@property (strong, nonatomic) FCTripBook* tripbook;
@property (strong, nonatomic) NSTimer* timeout;
@property (strong, nonatomic) MBCircularProgressBarView* timerCircleView;

@end

@implementation DriverDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    [self initView];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Inits
- (void) initView {
    
    [self.avatar layoutIfNeeded];
    self.avatar.layer.borderColor = [[UIColor blueColor] CGColor];
    self.avatar.layer.borderWidth = 0.5f;
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width/2;
    self.avatar.clipsToBounds = YES;
    self.iconFav.hidden = TRUE;
    self.btnBook.layer.cornerRadius = 5.0f;
    self.carImgIndicator.hidden = true;
    
    // timer view
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    int size = 150;
    self.timerCircleView = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake(screenSize.width/2 - size/2, screenSize.height/2 - size/2, size, size)];
    self.timerCircleView.progressColor = [UIColor whiteColor];
    self.timerCircleView.progressStrokeColor = [UIColor whiteColor];
    self.timerCircleView.progressAngle = 100;
    self.timerCircleView.clipsToBounds = YES;
    self.timerCircleView.backgroundColor = [UIColor grayColor];
    self.timerCircleView.fontColor = [UIColor whiteColor];
    self.timerCircleView.progressLineWidth = 10;
    self.timerCircleView.unitString = @"s";
    self.timerCircleView.unitFontSize = 35;
    self.timerCircleView.valueFontSize = 40;
    self.timerCircleView.maxValue = waiting_timeout;
    self.timerCircleView.value = waiting_timeout;
    [self.view addSubview:self.timerCircleView];
    self.timerCircleView.hidden = true;
    
    
    // init icon profile
    // always apply ?
//    if (((AppDelegate*)[UIApplication sharedApplication].delegate).currentSetting.isApply) {
        self.navigationItem.rightBarButtonItem = nil;
//    }
    
    self.name.text = self.driver.name;
    if (self.driver.feeling.length > 0) {
        self.feeling.text = self.driver.feeling;
    }
    else {
        self.feeling.textColor = [UIColor lightGrayColor];
    }
    if (self.driver.phone.length > 0) {
        self.phone.text = self.driver.phone;
    }
    else {
        self.phone.textColor = [UIColor lightGrayColor];
    }
    
    // status
    if ([self.driver.status isEqualToString:DRIVER_BUSY]) {
        self.status.text = @"ĐANG BẬN";
    }
    else if ([self.driver.status isEqualToString:DRIVER_READY]) {
        self.status.text = @"SẴN SÀNG";
    }
    else {
        self.status.text = @"CHƯA SẴN SÀNG";
    }
    
    [self.avatar setImageWithURL:[NSURL URLWithString:self.driver.avatarUrl] placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    // get client info
    self.client = [[FirebaseHelper shareInstance] currentClient];
    if (!self.client) {
        [[FirebaseHelper shareInstance] getClient:^(FCClient * client) {
            self.client = client;
        }];
    }
    
    // get car info
    [[FirebaseHelper shareInstance] getCarsDetail:self.driver.carId handler:^(FCMCar * car) {
        if (car) {
            NSString* code = [car.code stringByReplacingCharactersInRange:NSMakeRange(car.code.length-3, 3) withString:@"XXX"];
            self.car = car;
            self.carcode.text = [NSString stringWithFormat:@"Biển số: %@", code];
            self.carname.text = [NSString stringWithFormat:@"Tên xe: %@",  car.name];
//            self.carmodel.text = [NSString stringWithFormat:@"Dòng xe: %@", car.model.name];
//            self.carNoOfSeat.text = [NSString stringWithFormat:@"Số chỗ: %ld", (long)car.noOfSeats];
            
            [self.carimage setImageWithURL:[NSURL URLWithString:car.imageUrl]
                                 placeholderImage:[UIImage imageNamed:@"car-holder"]];
        }
        else {
            self.carImgIndicator.hidden = TRUE;
        }
    }];
    
    // get fav info
    [[FirebaseHelper shareInstance] getFavoriteInfo:self.driver handler:^(FCFavorite * fav) {
        if (fav) {
            self.favInfo = fav;
            if (fav.isFavorite) {
                self.iconFav.image = [UIImage imageNamed:@"fav-yellow"];
                self.iconFav.hidden = FALSE;
            }
            else {
                self.iconFav.image = [UIImage imageNamed:@"backlist"];
                self.iconFav.hidden = FALSE;
            }
        }
    }];
}

- (void) notifyDriverAccept: (FCTripBook*) trip {
    self.isWaitingTripBook = false;
    [self performSegueWithIdentifier:SEGUE_SHOW_TRIP_MAPS sender:trip];
    
    // stop check timeout
    [self.timeout invalidate];
    
    // reset timer
    [self resetTimerView];
}

- (void) notifyDriverReject: (FCTripBook*) trip {
    [UIAlertView showWithTitle:@"Phản hồi đặt xe" message:[NSString stringWithFormat:@"Chuyến đi của bạn đến '%@' bị từ chối. Vui lòng chọn tài xế khác!", trip.end.name] style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            self.isWaitingTripBook = false;
            [[FirebaseHelper shareInstance] deleteTripBook:trip];
            [self.navigationController popViewControllerAnimated:true];
        }
    }];
    
    // stop check timeout
    [self.timeout invalidate];
    
    // reset timer
    [self resetTimerView];
}

#pragma mark - Handler actions
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_DRIVER_TRIPS]) {
        DriverTripsViewController * des = segue.destinationViewController;
        des.driver = self.driver;
    }
    else if ([segue.identifier isEqualToString:SEGUE_SHOW_TRIP_MAPS]) {
        TripMapsViewController* mapsTrip = segue.destinationViewController;
        mapsTrip.tripbook = sender;
    }
}

- (IBAction)backPressed:(id)sender {
    if (self.isWaitingTripBook) {
        [UIAlertView showWithTitle:@"Tiếp tục chờ phản hồi đặt xe từ tài xế" message:nil cancelButtonTitle:@"Huỷ chuyến" otherButtonTitles:@[@"Đồng ý"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [[FirebaseHelper shareInstance] deleteTripBook:self.tripbook];
                [self.navigationController popViewControllerAnimated:TRUE];
                
                // cancel check timeout
                [self.timeout invalidate];
                
                // reset timer
                [self resetTimerView];
            }
        }];
        
        return;
    }
    
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)moreActionsPressed:(id)sender {
    NSArray* buttons = @[@"Gửi yêu cầu yêu thích", @"Thêm vào danh sách đen"];
    if (self.favInfo && !self.favInfo.isFavorite) {
        buttons = @[@"Gửi yêu cầu yêu thích", @"Xoá khỏi danh sách đen"];
    }
    
    [UIActionSheet presentOnView:self.view withTitle:nil cancelButton:@"Bỏ qua" destructiveButton:nil otherButtons:buttons onCancel:^(UIActionSheet * view) {
        
    } onDestructive:^(UIActionSheet * view) {
        
    } onClickedButton:^(UIActionSheet * view, NSUInteger buttonIndex) {
        if (buttonIndex == 0) {
            if (!self.favInfo) {
                [self favoritePressed];
            }
            else {
                if (!self.favInfo.isFavorite) {
                    [self removeFromBacklist];
                }
                else {
                    [self addDriverToBackList];
                }
            }
        }
        else if (buttonIndex == 1) { // backlist
            if (self.favInfo && !self.favInfo.isFavorite) {
                [self removeFromBacklist];
            }
            else {
                [self addDriverToBackList];
            }
        }
    }];
}

- (void) createBookTrip:(FCClient*) client {
    if (client.phone.length == 0) {
        [UIAlertView showWithTitle:@"Bạn cần phải cập nhật số điện thoại cá nhân để đặt xe" message:@"Cập nhật số điện thoại ngay?" cancelButtonTitle:@"Không" otherButtonTitles:@[@"Đồng ý"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                UIViewController* profile = [[NavigatorHelper shareInstance] getViewControllerById: NSStringFromClass([ProfileViewController class])];
                [self.navigationController pushViewController:profile animated:TRUE];
            }
        }];
        return;
    }
    
    NSString* message = [NSString stringWithFormat:@"ĐÓN: %@\n\nĐẾN: %@\n\nGÍA: %ld vnđ", self.placeStart.name, self.placeEnd.name, (long)self.price];
    [UIAlertView showWithTitle:@"Xác nhận đặt xe" message:message cancelButtonTitle:@"Không" otherButtonTitles:@[@"Đồng ý"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            [IndicatorUtils show];
            FCTripBook* trip = [[FCTripBook alloc] init];
            trip.id = [self getCurrentTimeStamp];
            trip.client = client;
            trip.driver = self.driver;
            trip.start = self.placeStart;
            trip.end = self.placeEnd;
            trip.price = self.price;

            self.tripbook = trip;
            
            // start timeout
            [self startBookingTimeout:trip];
            
            // save to db
            [[FirebaseHelper shareInstance] bookTrip:trip withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nullable ref) {
                [IndicatorUtils dissmiss];
                
                NSString* message;
                if (!error) {
                    self.isWaitingTripBook = true;
                    message =  @"Gửi yêu cầu đặt xe thành công. \nChờ phản hổi từ tài xế hoặc bạn có thể gọi trực tiếp cho tài xế để xác nhận.";
                    
                }
                else {
                    message =  @"Xảy ra lỗi.\nBạn hãy thử lại lần nữa hoặc có thể gọi trực tiếp cho tài xế để xác nhận.";
                }
                
                NSDictionary *options = @{
                                          kCRToastTextKey :message,
                                          kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                          kCRToastBackgroundColorKey : [UIColor lightGrayColor],
                                          kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                          kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                          kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
                                          kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight),
                                          kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar)
                                          };
                
                [CRToastManager showNotificationWithOptions:options
                                            completionBlock:^{
                                                
                                            }];
            }];
            
            
            // listener tripbook changed accept status
            [[FirebaseHelper shareInstance] listenerBookTripStatusChanged:trip withCompleted:^(FIRDataSnapshot * snapshot) {
                
                if ([snapshot.key isEqualToString:@"driverAccepted"]) {
                    BOOL driverAccepted = [snapshot.value boolValue];
                    if (driverAccepted) {
                        [self notifyDriverAccept:trip];
                    }
                    else  {
                        [self notifyDriverReject:trip];
                    }
                }
                else if ([snapshot.key isEqualToString:@"driverRejected"] && [snapshot.value boolValue]) {
                    [self notifyDriverReject:trip];
                }
            }];
        }
    }];
}

- (void) favoritePressed {
    FCFavorite* fav = [[FCFavorite alloc] init];
    fav.id = self.driver.id;
    fav.driver = self.driver;
    fav.isFavorite = TRUE;
    
    [[FirebaseHelper shareInstance] requestAddFavorite:fav withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        [UIAlertView showWithTitle:@"Thành công" message:@"Một yêu cầu thêm vào yêu thích đã được gửi đến tài xế" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }];
}

- (void) addDriverToBackList {
    if (!self.driver) {
        return;
    }
    
    FCFavorite* fav = [[FCFavorite alloc] init];
    fav.id = self.driver.id;
    fav.driver = self.driver;
    fav.isFavorite = FALSE;
    
    [[FirebaseHelper shareInstance] requestAddFavorite:fav withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nullable ref) {
        if (error == nil) {
            [UIAlertView showWithTitle:@"Thành công" message:@"Đã thêm tài xế này vào danh sách đen" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        }
        
    }];
}

- (void) removeFromBacklist {
    if (!self.favInfo) {
        return;
    }
    
    [[FirebaseHelper shareInstance] removeFromBacklist:self.favInfo handler:^(NSError * _Nullable error, FIRDatabaseReference * _Nullable ref) {
        if (error == nil) {
            self.iconFav.hidden = TRUE;
        }
    }];
}

- (IBAction)bookPressed:(id)sender {
    [self createBookTrip: self.client];
}

#pragma mark - Booking timeout
- (void) startBookingTimeout: (FCTripBook*) book {
    self.timeout = [NSTimer scheduledTimerWithTimeInterval:waiting_timeout target:self selector:@selector(bookTimeOut:) userInfo:book repeats:YES];
    
    // start timer
    self.timerCircleView.hidden = false;
//    [self.timerCircleView setValue:0.f
//               animateWithDuration:waiting_timeout];
    [UIView animateWithDuration:waiting_timeout animations:^{
        self.timerCircleView.value = 0.f;
    }];
    
    self.tableView.userInteractionEnabled = false;
}

- (void) bookTimeOut: (NSTimer*) timer {
    [self notifyDriverReject:(FCTripBook*)timer.userInfo];
}

- (void) resetTimerView {
    self.timerCircleView.value = waiting_timeout;
    self.timerCircleView.hidden = true;
    self.tableView.userInteractionEnabled = true;
}

#pragma mark - TableView Delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // phone click
    if (indexPath.section == 1 && indexPath.row == 1 && self.driver.phone.length > 0) {
        [self callPhone:self.driver.phone];
    }
}

@end
