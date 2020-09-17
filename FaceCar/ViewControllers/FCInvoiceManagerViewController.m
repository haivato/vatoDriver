//
//  FCInvoiceManagerViewController.m
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCInvoiceManagerViewController.h"
#import "FCInvoiceTableViewCell.h"
#import "FCInvoice.h"
#import "UITableView+ENFooterActivityIndicatorView.h"
#import "FCInvoiceDetailViewController.h"
#import "FCWarningNofifycationView.h"

#define CELL @"FCInvoiceTableViewCell"

@interface FCInvoiceManagerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listInvoice;
@end

@implementation FCInvoiceManagerViewController {
    UIRefreshControl* refresh;
    NSInteger _page;
    BOOL _more;
    BOOL _loadMoring;
}

- (instancetype) initView {
    self = [self initWithNibName:@"FCInvoiceManagerViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Lịch sử giao dịch";
    return self;
}

- (instancetype) initViewForPresent {
    self = [self initWithNibName:@"FCInvoiceManagerViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Lịch sử giao dịch";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listInvoice = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil] forCellReuseIdentifier:CELL];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
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
                [self getInvoiceData];
            }
        }
        else {
            [self.tableView removeFooterActivityIndicator];
        }
    }];
    
    // get data
    [IndicatorUtils show];
    [self getInvoiceData];
}

- (void) onRefresh: (id) sender {
    _page = 0;
    [self getInvoiceData];
    [refresh endRefreshing];
}

- (void) reloadData {
    if (self.listInvoice.count == 0) {
        FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] intView];
        view.bgColor = [UIColor whiteColor];
        view.messColor = [UIColor darkGrayColor];
        [view show:self.view
             image:[UIImage imageNamed:@"notify-1"]
             title:@"Thông báo"
           message: @"Hiện bạn chưa có giao dịch nào."];
        [self.tableView setScrollEnabled:NO];
    }
    else {
        self.tableView.hidden = NO;
    }
    
    [self.tableView reloadData];
}

- (void) getInvoiceData {
    long long to = (long long)[self getCurrentTimeStamp];
    long long from = (long long) (to - limitdays);
    NSDictionary* params = @{@"from": @(from),
                             @"to": @(to),
                             @"page": @(_page),
                             @"size": @10};
    
    [[APICall shareInstance] apiGetInvoicesList:params block:^(NSArray * list, BOOL more) {
        [IndicatorUtils dissmiss];
        _more = more;
        _loadMoring = NO;
        if (_page == 0) {
            [self.listInvoice removeAllObjects];
        }

        [self.listInvoice addObjectsFromArray: list];
        [self reloadData];
    }];
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView Delegate
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listInvoice.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCInvoiceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    FCInvoice* invoice = [self.listInvoice objectAtIndex:indexPath.row];
    [cell loadData:invoice];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCInvoiceDetailViewController* detailVC = [[FCInvoiceDetailViewController alloc] init];
    detailVC.isPushedView = YES;
    [detailVC setInvoice:[self.listInvoice objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailVC
                                         animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView tableViewDidScroll];
}

@end
