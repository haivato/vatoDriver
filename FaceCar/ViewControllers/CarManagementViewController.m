//
//  CarManagementViewController.m
//  FC
//
//  Created by Son Dinh on 5/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "CarManagementViewController.h"
#import "CarManageTableViewCell.h"
#import "FCCreateCarViewController.h"
#import "FacecarNavigationViewController.h"
#import "UIView+Border.h"
#import "FCWarningNofifycationView.h"
#import "FCWebViewController.h"
#import "AppDelegate.h"
#import "FCNewWebViewController.h"

#define CELL @"CarManageTableViewCell"

@interface CarManagementViewController ()
@property (strong, nonatomic) FCDriver* driver;
@property (strong, nonatomic) NSMutableArray* listCar;
@property (weak, nonatomic) IBOutlet UIButton *btnAddNewCar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CarManagementViewController

- (instancetype) initViewWithHomeViewModel: (FCHomeViewModel*) homeViewModel {
    self = [self initWithNibName:@"CarManagementViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Gara của tôi";
    
    self.homeViewModel = homeViewModel;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnAddNewCar.backgroundColor = NewOrangeColor;
    [self.btnAddNewCar borderViewWithColor:[UIColor clearColor] andRadius:5];
    
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil] forCellReuseIdentifier:CELL];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self reloadListCar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEditCarSuccess:)
                                                 name:NOTIFICATION_EDIT_CAR_SUCCESS
                                               object:nil];
    
    self.btnAddNewCar.hidden = ![self getLinkCreateCar];
    self.navigationController.navigationBar.translucent = NO;
}

- (FCLinkConfigure*) getLinkCreateCar {
    NSArray* links = [FirebaseHelper shareInstance].appConfigure.app_link_configure;
    for (FCLinkConfigure* link in links) {
        if (link.type == LinkConfigureTypeCreateCar) {
            return link;
        }
    }
    
    return nil;
}

- (void) onEditCarSuccess: (id) sender {
    [self closePressed:nil];
}

- (IBAction)addNewCarPressed:(id)sender {
     FCLinkConfigure* link = [self getLinkCreateCar];
     FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
     [self presentViewController:vc
                        animated:YES
                      completion:^{
                          [vc loadWebviewWithConfigure:link];
                      }];
}

- (void)reloadListCar {
    [IndicatorUtils show];
    NSDictionary* body = @{@"page":@0,
                           @"size":@10};
    [[APIHelper shareInstance] get:API_GET_LIST_CAR
                            params:body
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                              
                              @try {
                                  NSMutableArray* array = [[NSMutableArray alloc] init];
                                  for (NSDictionary* dict in response.data) {
                                      FCUCar* car = [[FCUCar alloc] initWithDictionary:dict
                                                                                 error:nil];
                                      if (car) {
                                          [array addObject:car];
                                      }
                                  }
                                  self.listCar = array;
                                  [self.tableView reloadData];
                                  
                                  [self checkingData];
                              }
                              @catch (NSException* e) {
                                  DLog(@"Error: %@", e)
                              }
                          }];
}

- (void) checkingData {
    FCDriver* driver = [self.homeViewModel driver];
    if (!driver) {
        driver = [[UserDataHelper shareInstance] getCurrentUser];
    }
    if (driver.vehicle) {
        // còn tồn tại xe đang dùng thì return luôn
        if (_listCar.count > 0) {
            for (FCUCar* car in _listCar) {
                if (car.id == driver.vehicle.id) {
                    return;
                }
            }
        }
        
        [[FirebaseHelper shareInstance] driverOffline:nil];
        [[FirebaseHelper shareInstance] removeCar];
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Thông báo"
                                             message:@"Xe bạn đang đăng ký sử dụng không còn khả dụng nữa. Bạn vui lòng chọn lại xe và dịch vụ để tiếp tục TRỰC TUYẾN."
                                   cancelButtonTitle:@"Đồng ý"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:nil];
    }
    
    if (self.listCar.count == 0) {
        FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] intView];
        view.bgColor = [UIColor whiteColor];
        view.messColor = [UIColor darkGrayColor];
        [view show:self.view
             image:[UIImage imageNamed:@"car-holder-1"]
             title:nil
           message:@"Bạn chưa đăng ký xe nào cả.\nNhấn nút 'THÊM XE MỚI' bên dưới để đăng ký xe."];
        [self.tableView setScrollEnabled:NO];
        [self.view bringSubviewToFront:self.btnAddNewCar];
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listCar == nil)
    {
        return 0;
    }
    
    return self.listCar.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    cell.homeViewModel = self.homeViewModel;
    [cell loadData:[self.listCar objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCUCar* car = [self.listCar objectAtIndex:indexPath.row];
    FCCreateCarViewController* vc = [[FCCreateCarViewController alloc] initView];
    vc.homeViewModel = self.homeViewModel;
    vc.car = car;
    FacecarNavigationViewController* nav = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

@end
