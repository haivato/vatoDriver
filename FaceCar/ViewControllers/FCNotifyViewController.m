//
//  FCNotifyViewController.m
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCNotifyViewController.h"
#import "FCNotifyTableViewCell.h"
#import "APIHelper.h"
#import "FCWebViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCInvoiceManagerViewController.h"
#import "ProfileViewController.h"
#import "UITableView+ENFooterActivityIndicatorView.h"
#import "FCWarningNofifycationView.h"
#import "UserDataHelper.h"
#import "FCInvoiceDetailViewController.h"
#import "FCNotificationDetailViewController.h"
#import "FCVatoPayViewController.h"
#import "FCNewWebViewController.h"

#define CELL @"FCNotifyTableViewCell"

@interface FCNotifyViewController ()

@end

@implementation FCNotifyViewController {
    UIRefreshControl* refresh;
    NSMutableArray* _listData;
    NSInteger _page;
    BOOL _more;
    BOOL _loadMoring;
}

- (instancetype) initView {
    self = [self initWithNibName:@"FCNotifyViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Thông báo";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listData = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil]
         forCellReuseIdentifier:CELL];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.hidden = YES;
    
    // header
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        refresh =  [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refresh;
    }
    
    // footer
    [self.tableView setTableScrolledDownBlock:^void() {
        if (_more) {
            if (![self.tableView footerActivityIndicatorView])
                [self.tableView addFooterActivityIndicatorWithHeight:80.f];
            
            if (!_loadMoring) {
                _page ++;
                _loadMoring = TRUE;
                [self getListNotification];
            }
        }
        else {
            [self.tableView removeFooterActivityIndicator];
        }
    }];
    
    [IndicatorUtils show];
    [self getListNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) onRefresh: (id) sender {
    _page = 0;
    [self getListNotification];
    [refresh endRefreshing];
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Data handler

- (void) getListNotification {
    [self apiGetListNotification:^(NSMutableArray *list, BOOL more) {
        _more = more;
        _loadMoring = NO;
        if (_page == 0) {
            [_listData removeAllObjects];
        }
        
        [_listData addObjectsFromArray: list];
        [self.tableView reloadData];
        [self checkingData];
    }];
}

- (void) apiGetListNotification : (void (^) (NSMutableArray* arr, BOOL more)) block{
    long long to = (long long)[self getCurrentTimeStamp];
    long long from = (long long) (to - limitdays);
    NSDictionary* body = @{@"from":@(from),
                           @"to" : @(to),
                           @"page":@(_page),
                           @"size":@(10)};
    [[APIHelper shareInstance] get:API_GET_LIST_NOTIFY
                            params:body
                           complete:^(FCResponse *response, NSError *e) {
                               [IndicatorUtils dissmiss];
                               @try {
                                   [IndicatorUtils dissmiss];
                                   NSMutableArray* list = [[NSMutableArray alloc] init];
                                   NSArray* datas = [response.data objectForKey:@"notifications"];
                                   BOOL more = [[response.data objectForKey:@"more"] boolValue];
                                   NSInteger lastest = 0;
                                   for (id item in datas) {
                                       FCNotification* noti = [[FCNotification alloc] initWithDictionary:item error:nil];
                                       if (noti) {
                                           [list addObject:noti];
                                           if (lastest < noti.createdAt) {
                                               lastest = noti.createdAt;
                                           }
                                       }
                                   }
                                   
                                   [[UserDataHelper shareInstance] saveLastestNotification:lastest];
                                   [self.homeViewModel setNotifyBadge:0];
                                   block(list, more);
                               }
                               
                               @catch (NSException* e) {
                                   DLog(@"Error: %@", e);
                                   block (nil, NO);
                               }
                               
                           }];
}

- (void) checkingData {
    if (_listData.count == 0) {
        FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] intView];
        view.bgColor = [UIColor whiteColor];
        view.messColor = [UIColor darkGrayColor];
        [view show:self.view
             image:[UIImage imageNamed:@"no-notify"]
             title:nil
           message: @"Hiện bạn chưa nhận được thông báo nào từ hệ thống!"];
        [self.tableView setScrollEnabled:NO];
    }
    else {
        self.tableView.hidden = NO;
    }
}

#pragma mark - Tableview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView tableViewDidScroll];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listData.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCNotifyTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    [cell loadData:[_listData objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCNotification* noti = [_listData objectAtIndex:indexPath.row];
    if (noti.status == NEW) {
        noti.status = READ;
        
        self.homeViewModel.totalUnreadNotify -= 1;
        
        FCNotifyTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            [cell loadNewStatus:noti];
        }
    }
    
    int type = noti.type;
    UIViewController* vc = nil;
    if (type == NotifyTypeReferal) {
        vc = [[FCInvoiceManagerViewController alloc] initViewForPresent];
    }
    else if (type == NotifyTypeBalance) {
        vc = [[FCVatoPayViewController alloc] init];
    }
    else if (type == NotifyTypeLink && noti.extra.length > 0) {
        if ([noti.extra containsString:@"https://id"]) {
            [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
                @try {
                    NSString* link = [NSString stringWithFormat:@"%@?token=%@", noti.extra, token];
                    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                    [cookieProperties setObject:@"x-access-token" forKey:NSHTTPCookieName];
                    [cookieProperties setObject:token forKey:NSHTTPCookieValue];
                    
                    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
                    
                    FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
//                    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
                    [self presentViewController:vc
                                                animated:YES
                                              completion:^{
                                                  [vc loadWebview:link];
                                              }];
                }
                @catch (NSException* e) {
                    DLog(@"Error: %@", e)
                }
            }];
            return;
        }
        else {
            FCWebViewModel* model = [[FCWebViewModel alloc] initWithUrl:noti.extra];
            vc = [[FCWebViewController alloc] initViewWithViewModel:model];
            [(FCWebViewController*)vc setTitle:noti.title.length > 0 ? noti.title: @"VATO thông báo"];
        }
    }
    else if (type == NotifyTypeTranferMoney) {
        vc = [[FCInvoiceDetailViewController alloc] init];
        ((FCInvoiceDetailViewController*) vc).invoiceId = [noti.referId integerValue];
    }
    else {
        vc = [[FCNotificationDetailViewController alloc] initView];
        [(FCNotificationDetailViewController*) vc setNotification:noti];
    }
    
    if (vc) {
        FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
        [navController setModalPresentationStyle:UIModalPresentationFullScreen];
        [self  presentViewController:navController animated:TRUE completion:^{
        }];
    }
}

@end
