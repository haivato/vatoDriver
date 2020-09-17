//
//  FCCreateCarViewController.m
//  FC
//
//  Created by facecar on 5/9/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCCreateCarViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCServiceCollectionViewCell.h"
#import "FCNotifyBannerView.h"
#import "FCCreateCar+RegisterService.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
#define CAR_CODE_FIRST_REGULAR @"([0-9]{2})([A-Za-z]{1})([0-9]{1})?"
#define CAR_CODE_SECOND_REGULAR @"([0-9]{4,5})"
#define CELL @"FCServiceCollectionViewCell"

#define COLLECTION_CELL_HEIGHT 50
#define TABLEVIEW_CELL_INFO_HEIGHT 74
#define TABLEVIEW_CELL_BUTTON_HEIGHT 66

#define SECTION_INFO 0
#define SECTION_SERVICE 1

#define TABLEVIEW_CELL_SERVICE 0

typedef enum : NSUInteger {
    CarBranch,
    CarMaker,
    CarName,
    CarColor
} FCCarView;

@interface FCCreateCarViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FCServiceDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblCarBranch;
@property (weak, nonatomic) IBOutlet UILabel *lblCarMarker;
@property (weak, nonatomic) IBOutlet UILabel *lblCarName;
@property (weak, nonatomic) IBOutlet UILabel *lblCarCorlor;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstCode;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionSerivceView;
@property (weak, nonatomic) IBOutlet FCButton *continueButton;
@property (strong, nonatomic) RequesterObjc *request;
@property (strong, nonatomic) NSMutableArray<FCMService>* listService;

@end

@implementation FCCreateCarViewController {
    NSInteger _currentStatus;
}

- (instancetype) initView {
    id vc = [[NavigatorHelper shareInstance] getViewControllerById:@"FCCreateCarViewController" inStoryboard:@"FCCreateCarViewController"];

    return vc;
}

- (void) setCar:(FCUCar *)car {
    _car = car;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.request = [RequesterObjc new];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithImage:[UIImage imageNamed:@"back"]
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Thông tin xe";
    
    // setup color button continue
    self.continueButton.backgroundColor = NewOrangeColor;
    
    [self.collectionSerivceView registerNib:[UINib nibWithNibName:CELL bundle:nil]
                 forCellWithReuseIdentifier:CELL];
    self.collectionSerivceView.delegate = self;
    self.collectionSerivceView.dataSource = self;
    
    if (self.car) {
        self.listService = [NSMutableArray new];
        for (FCMService *service in self.car.availableServices) {
            [self.listService addObject:[service clone]];
        }
        [self loadData];
    }
    
    _currentStatus = self.homeViewModel.onlineStatus.status;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) loadData {
    if (self.car.type == VehicleTypeBike) {
        self.lblCarBranch.text = @"Xe máy";
    }
    else {
        self.lblCarBranch.text = @"Ô tô";
    }

    self.lblCarMarker.text = self.car.brand;
    self.lblCarName.text = self.car.marketName;
    self.tfFirstCode.text = self.car.plate;
    self.lblCarCorlor.backgroundColor = UIColorFromRGB([self getColorCodeFromString:self.car.colorCode]);
}


/**
 Nếu sửa xe (list service != nil) thì kiểm tra danh sách dịch vụ đang dùng để tìm những dịch vụ đang chọn.
 Ngược lại thì mặc định là chọn

 @param service : dịch vụ cần kiểm tra có đang sử dụng không
 @return YES -> đang sử dụng
 */

- (BOOL) isChooseCell: (FCMService*) service {
    return service.enable; //&& service.active;
}

- (void) closePressed: (id)sender {
    if (_currentStatus == DRIVER_READY) {
        [[FirebaseHelper shareInstance] driverReady];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continuePressed:(id)sender {
    NSMutableArray<FCMService *>* listService = [[NSMutableArray alloc] init];
    NSInteger service = 0;
    NSInteger mainServiceId = 0; // dich vụ cao nhất mà user chọn (7c, car+,car, -> = 7c)
    NSInteger primaryServiceId = 0; // chỉ bao gồm car, bike. KHÔNG gồm fast
    for (FCMService *_service in self.listService) {
        if (_service.enable) {
            service += _service.serviceId;

            if (mainServiceId < _service.serviceId) {
                mainServiceId = _service.serviceId;
            }
            
            if (_service.serviceId != VatoServiceFast7 && _service.serviceId != VatoServiceFast4 && primaryServiceId < _service.serviceId) {
                primaryServiceId = _service.serviceId;
            }
        }
    }
    
    // Nếu xe đăng ký dịch vụ car, fast, thì mainservice được ưu tiên lấy car, ngược lại lấy fast
    if (primaryServiceId != 0) {
        mainServiceId = primaryServiceId;
    }
    
    if (mainServiceId == 0) {
        [[FCNotifyBannerView banner] show:nil
                                  forType:FCNotifyBannerTypeError
                                 autoHide:YES
                                  message:@"Bạn vui lòng chọn ít nhất 1 dịch vụ để tiếp tục!"
                               closeClick:nil
                              bannerClick:nil];
        return;
    }
    
    FCMService* mainService;
    for (FCMService* ser in self.listService) {
        if (ser.serviceId == mainServiceId) {
            mainService = ser;
        }
    }
    
    NSDictionary* body = @{@"service": @(service),
                           @"vehicle_id": @(self.car.id)
                           };
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_UPDATE_CAR_SERVICE
                               body:body
                           complete:^(FCResponse *response, NSError *e) {
                               [IndicatorUtils dissmiss];
                               if (response.status == APIStatusOK) {
                                   [self finished: mainService totalService:listService];
                               }
                           }];
}

- (void) finished: (FCMService*) mainService totalService: (NSArray<FCMService>*) services {
    // Save car to driverv4
    self.car.service = mainService.serviceId;
    self.car.availableServices = services;
    self.car.serviceName = mainService.name;
    NSMutableArray *listServices = [NSMutableArray array];
    for (FCMService* ser in self.listService) {
        if (ser.enable) {
            [listServices addObject:[NSNumber numberWithInteger:ser.serviceId]];
        }
    }
    self.car.services = listServices;
    [[FirebaseHelper shareInstance] updateCar:self.car];
    
    // show message
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Thông báo"
                                         message:@"Bạn đã cập nhật thông tin xe thành công. Hãy tiếp tục trực tuyến để nhận chuyến cùng VATO."
                               cancelButtonTitle:@"Đồng ý"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController* controller, UIAlertAction* action, NSInteger buttonIndex) {
                                            [self.navigationController dismissViewControllerAnimated:YES
                                                                                          completion:nil];
                                        }];
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    
    return 50;
}

#pragma mark - Table view delegagte
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;

    if (section == SECTION_INFO) {
        return TABLEVIEW_CELL_INFO_HEIGHT;
    } else if (section == SECTION_SERVICE) {
        if (row == TABLEVIEW_CELL_SERVICE) {
            return self.listService.count * COLLECTION_CELL_HEIGHT;
        }
    }


    return TABLEVIEW_CELL_BUTTON_HEIGHT;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.car) {
        return;
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.car) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Collecion Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, 40);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listService.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FCMService* service = [self.listService objectAtIndex:indexPath.row];
    FCServiceCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL forIndexPath:indexPath];
    cell.delegate = self;
    cell.service = service;
    cell.lblName.text = service.displayName;
    [cell.swChoose setOn:[self isChooseCell:service]];
    if (cell.service.active) {
        cell.backgroundColor = [UIColor whiteColor];
        [cell.swChoose setOn:[self isChooseCell:service]];
        cell.lbRegister.text = @"";
    } else {
        cell.lblName.textColor = [UIColor grayColor];
        [cell.swChoose setOn:NO];
        [cell.swChoose setEnabled:NO];
        cell.lbRegister.text = @"Nhấn để đăng kí";
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCMService* service = [self.listService objectAtIndex:indexPath.row];
    if (!service.active) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FCMService* service = [self.listService objectAtIndex:indexPath.row];
    if (!service.active) {
        [self showFoodReceivePackage:self.car];
    }
}

- (void) checkAgreement:(NSInteger)serviceId completed: (void(^)(BOOL)) handler {
    NSString *token = [FirebaseTokenHelper instance].token;
    NSString *p = [NSString stringWithFormat:@"user/services/%ld/agreement", (long)serviceId];
    [_request requestWithToken:token
                          path:p
                        method:@"GET"
                        header:nil
                        params:nil
                 trackProgress:YES
                       handler:^(NSDictionary<NSString *,id> * _Nullable json, NSError * _Nullable error) {
        if (!json || error != nil) {
            if (handler) {
                handler(NO);
            }
            return;
        }
        NSDictionary *dict = [NSDictionary castFrom:[json objectForKey:@"data"]];
        NSNumber *value = [NSNumber castFrom:[dict objectForKey:@"accept"]];
        if (handler) {
            handler([value boolValue]);
        }
    }];
}

- (void) updateAgreement:(NSInteger)serviceId completed: (void(^)(BOOL)) handler {
    NSString *token = [FirebaseTokenHelper instance].token;
    NSString *p = [NSString stringWithFormat:@"user/services/%ld/agreement", (long)serviceId];
    [_request requestWithToken:token
                          path:p
                        method:@"PUT"
                        header:nil
                        params:@{ @"accept": @(YES) }
                 trackProgress:YES
                       handler:^(NSDictionary<NSString *,id> * _Nullable json, NSError * _Nullable error) {
    }];
}



-(void)serviceCell:(FCServiceCollectionViewCell *)sender onChoosed:(BOOL)choose service:(FCMService *)service {
//    if ((service.active == false) && choose == true) {
//        [sender.swChoose setOn:false animated:true];
//        [UIAlertController showAlertInViewController:self
//                                           withTitle:@"Thông Tin"
//                                             message:@"Quý đối tác vui lòng đăng ký chạy dịch vụ VATO tại văn phòng của VATO. Gọi 1900 6667 để được hỗ trợ."
//         // @"Quý đối tác vui lòng đăng ký chạy dịch vụ VATO Giao Hàng tại văn phòng của VATO. Gọi 1900 6667 để được hỗ trợ."
//                                   cancelButtonTitle:@"Đóng"
//                              destructiveButtonTitle:nil
//                                   otherButtonTitles:nil
//                                            tapBlock:nil];
//        return;
//    }
    @weakify(self);
    void(^Run)(void) = ^{
        @strongify(self);
        NSIndexPath *indexPath = [self.collectionSerivceView indexPathForCell:sender];
        if (indexPath.row >= 0 && indexPath.row < self.listService.count) {
            ((FCMService *)self.listService[indexPath.row]).enable = choose;
        }
    };
    
    if (choose) {
        @weakify(sender);
        [self checkAgreement:service.serviceId completed:^(BOOL agreed) {
            @strongify(self);
            if (agreed) {
                Run();
            } else {
                [UIAlertController showAlertUseSupplyServiceOn:self
                                                          path:@"https://vato.vn/tai-xe-quy-dinh-thuc-hien-cam-ket-va-bo-quy-tac-ung-xu-su-dung-dich-vu-vato-market/"
                                                        cancel:^(UIAlertAction * _Nonnull action) {
                    @strongify(sender);
                    [sender.swChoose setOn:NO animated:true];
                } completed:^(UIAlertAction * _Nonnull action)
                {
                    [self updateAgreement:service.serviceId completed:nil];
                    Run();
                }];
            }
        }];
    } else {
        Run();
    }
}

@end
