//
//  FavoriteViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/2/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteTableViewCell.h"
#import "FacecarNavigationViewController.h"
#import "FCFindView.h"
#import "FCWarningNofifycationView.h"
#import "FCNotifyBannerView.h"
#import "ClientProfileViewController.h"
#import "FCUserInfo.h"

@interface FavoriteViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray* listDrivers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnAddNewOne;
@property (strong, nonatomic) FCWarningNofifycationView* nodataView;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@end

@implementation FavoriteViewController {
}

- (instancetype) initView:(FCHomeViewModel *)homeModel {
    self = [self initWithNibName:@"FavoriteViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Danh sách chặn";
    self.homeViewModel = homeModel;
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"FavoriteTableViewCell"];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // set color button add client
    self.btnAddNewOne.backgroundColor = NewOrangeColor;
    
    [RACObserve(self, listDrivers) subscribeNext:^(NSMutableArray* list) {
        if (list && list.count == 0) {
            if (!self.nodataView) {
                FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] intView];
                view.cusframe = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - 60);
                view.bgColor = [UIColor whiteColor];
                view.messColor = [UIColor darkGrayColor];
                
                [view show:self.view
                     image:[UIImage imageNamed:@"driver-icon"]
                     title:nil
                   message:@"Danh sách trống.\nĐể không gặp lại khách hàng theo ý muốn, bạn cần lưu khách hàng vào danh sách này bằng cách chọn Thêm khách hàng."];
                self.nodataView = view;
            }
            
            [self.view addSubview:self.nodataView];
            [self.tableView setScrollEnabled:NO];
            [self.view bringSubviewToFront:self.btnAddNewOne];
        }
        else {
            [self.tableView setScrollEnabled:YES];
            if (self.nodataView) {
                [self.nodataView removeFromSuperview];
                self.nodataView = nil;
            }
        }
    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [IndicatorUtils show];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRemovedFavorite:(FCFavorite *)favorite{
    [[FirebaseHelper shareInstance] removeFromBacklist:favorite handler:^(NSError * _Nullable error, FIRDatabaseReference * _Nullable ref) {
        if (error) {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeError
                                     autoHide:YES
                                      message:@"Bạn vui lòng thử lại sau!"
                                   closeClick:nil
                                  bannerClick:nil];
        }
    }];
}

- (void) getData {
    [[FirebaseHelper shareInstance] getListBackList:^(NSMutableArray * list) {
        [IndicatorUtils dissmiss];
        self.listDrivers = list;
        [self.tableView reloadData];
    }];
}

- (IBAction)addNewDriverClicked:(id)sender {
    FCFindView* view = [[FCFindView alloc] initView:self];
    [view setupView];
    [self.navigationController.view addSubview:view];
    
    [RACObserve(view, userInfo) subscribeNext:^(FCUserInfo* info) {
        if (info) {
            FCFavorite* fav = [[FCFavorite alloc] init];
            fav.userFirebaseId = info.firebaseId;
            fav.userAvatar = info.avatar;
            fav.userPhone = info.phoneNumber;
            fav.userName = info.fullName;
            fav.userId = info.id;
            [self loadClientData:fav];
            [view removeFromSuperview];
        }
    }];
}

- (void) loadClientData: (FCFavorite*) favorite {
    ClientProfileViewController* vc = (ClientProfileViewController*)[[NavigatorHelper shareInstance] getViewControllerById:@"ClientProfileViewController" inStoryboard:@"ClientProfile"];
    vc.favorite = favorite;
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [navController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:navController animated:YES
                     completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listDrivers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FavoriteTableViewCell class]) forIndexPath:indexPath];
    
    FCFavorite* fav = [self.listDrivers objectAtIndex:indexPath.row];
    [cell loadData:fav];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFavorite* fav = [self.listDrivers objectAtIndex:indexPath.row];
    [self loadClientData:fav];
}


@end
