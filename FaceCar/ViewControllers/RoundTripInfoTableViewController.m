//
//  RoundTripInfoTableViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/23/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "RoundTripInfoTableViewController.h"
#import "ProfileViewController.h"
#import "DriverDetailViewController.h"

@interface RoundTripInfoTableViewController ()
@property(strong, nonatomic) FCDriver* driver;
@end

@implementation RoundTripInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.driverAvatar layoutIfNeeded];
    self.driverAvatar.layer.cornerRadius = self.driverAvatar.frame.size.width/2;
    self.driverAvatar.clipsToBounds = YES;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.roundTrip) {
        [IndicatorUtils show];
//        [[FirebaseHelper shareInstance] getDriver:self.roundTrip.driverId handler:^(FCDriver * driver) {
//            [IndicatorUtils dissmiss];
//            [self loadView: driver];
//        }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) loadView: (FCDriver*) driver {
    self.driver = driver;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.driverAvatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:driver.avatarUrl]] placeholderImage:[UIImage imageNamed:@"avatar"] success:nil failure:nil];
    self.drvierName.text = driver.name;
    [self.driverPhone setTitle:driver.phone forState:UIControlStateNormal];
    self.driverMessage.text = driver.feeling && driver.feeling.length > 0 ? driver.feeling : @"Tâm trạng tài xế";
    self.lblStartName.text = self.roundTrip.startPlace.name;
    self.lblEndNAme.text = self.roundTrip.endPlace.name;
    self.lblTimeStart.text = [self getTimeString:self.roundTrip.timeStart];
    if (self.roundTrip.message.length > 0) {
        self.driverMessage.text = self.roundTrip.message;
        self.driverMessage.textColor = [UIColor blueColor];
    }
      
    // get car info
    [[FirebaseHelper shareInstance] getCarsDetail:driver.carId handler:^(FCMCar * car) {
        if (car) {
            self.lblCarCode.text = [NSString stringWithFormat:@"Biển số: %@", car.code];
            self.lblCarName.text = [NSString stringWithFormat:@"Tên xe: %@",  car.name];
//            self.lblCarType.text = [NSString stringWithFormat:@"Dòng xe: %@", car.model.name];
//            self.lblCarNoSeat.text = [NSString stringWithFormat:@"Số chỗ: %ld", (long)car.noOfSeats];
            
            [self.carIndicator startAnimating];
            __weak typeof(self) weakSelf = self;
            [self.carImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:car.imageUrl]] placeholderImage:[UIImage imageNamed:@"car-holder"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                weakSelf.carImage.image = image;
                weakSelf.carIndicator.hidden = TRUE;
                [weakSelf.carIndicator stopAnimating];
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                weakSelf.carIndicator.hidden = TRUE;
                [weakSelf.carIndicator stopAnimating];
            }];
        }
        else {
            self.carIndicator.hidden = TRUE;
        }
    }];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)driverPhoneClicked:(id)sender {
    [self callPhone:self.driver.phone];
}

- (IBAction)bookPressed:(id)sender {
    // get client info
    FCClient* client = [[FirebaseHelper shareInstance] currentClient];
    if (!client) {
        [[FirebaseHelper shareInstance] getClient:^(FCClient * client) {
            [self createBookTrip:client];
        }];
    }
    else {
        [self createBookTrip:client];
    }
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
    
    NSString* addr = [FirebaseHelper shareInstance].currentClientLocationAddress;
    if (addr.length == 0) {
        [UIAlertView showWithTitle:@"Bạn cần phải chọn địa điểm khởi hành để gửi yêu cầu chuyến đi cho tài xế" message:nil
                cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
    }
    
    [UIAlertView showWithTitle:@"Xác nhận điểm đón" message:addr cancelButtonTitle:@"Không" otherButtonTitles:@[@"Đồng ý"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [IndicatorUtils show];
            FCTripBook* trip = [[FCTripBook alloc] init];
            trip.id = [self getCurrentTimeStamp];
            trip.client = client;
            trip.driver = self.driver;
            trip.start = self.start;
            trip.end = self.end;
            trip.price = self.price;
            
            
            // save to db
            [[FirebaseHelper shareInstance] bookTrip:trip withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nullable ref) {
                [IndicatorUtils dissmiss];
                if (!error) {
                    [UIAlertView showWithTitle:@"Gửi yêu cầu đặt xe thành công" message:@"Chờ phản hổi từ tài xế hoặc bạn có thể gọi trực tiếp cho tài xế để xác nhận." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                }
                else {
                    [UIAlertView showWithTitle:@"Xảy ra lỗi" message:@"Bạn hãy thử lại lần nữa hoặc có thể gọi trực tiếp cho tài xế để xác nhận." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                }
            }];
        }
    }];
}

#pragma mark - Table view data source

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {// driver profile
//        if (self.driver) {
//            UIViewController* vc = [[NavigatorHelper shareInstance] getViewControllerById:NSStringFromClass([DriverDetailViewController class])];
//            ((DriverDetailViewController*)vc).driver = self.driver;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
    }
    else if (indexPath.section == 1 && indexPath.row == 3) { // direction -> open maps
        NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%f,%f&saddr=%f,%f",self.roundTrip.startPlace.location.lat,self.roundTrip.startPlace.location.lon, self.roundTrip.endPlace.location.lat, self.roundTrip.endPlace.location.lon];
        
        DLog(@"Goto Map: %@", url)
        
        if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"http://maps.apple.com/"]]) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
        } else {
            
        }
    }
}

@end
