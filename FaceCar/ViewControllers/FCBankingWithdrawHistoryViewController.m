//
//  FCBankingWithdrawHistoryViewController.m
//  FC
//
//  Created by tony on 8/31/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBankingWithdrawHistoryViewController.h"
#import "FCInvoiceTableViewCell.h"
#import "FCWithdrawHistory.h"
#import "FCInvoiceDetailViewController.h"
#import "UITableView+ENFooterActivityIndicatorView.h"
#import "FCWarningNofifycationView.h"

#define CELL @"FCInvoiceTableViewCell"

@interface FCBankingWithdrawHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray* listInvoice;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FCBankingWithdrawHistoryViewController {
    NSInteger _page;
    BOOL _more;
    BOOL _loadMoring;
}

- (instancetype) initView {
    self = [self initWithNibName:@"FCBankingWithdrawHistoryViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Đang chờ xử lý";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listInvoice = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil] forCellReuseIdentifier:CELL];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [IndicatorUtils show];
    NSDictionary* params = @{@"page": @(_page),
                             @"size": @10};
    [[APICall shareInstance] apiGetWithdrawHistoryList:params block:^(NSArray *list, BOOL more) {
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

- (void) backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) reloadData {
    [self.tableView reloadData];
    
    if (self.listInvoice.count == 0) {
        FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] intView];
        view.bgColor = [UIColor whiteColor];
        view.messColor = [UIColor darkGrayColor];
        [view show:self.view
             image:[UIImage imageNamed:@"notify-1"]
             title:nil
           message: @"Hiện bạn chưa có yêu cầu nào đang chờ xử lý."];
        [self.tableView setScrollEnabled:NO];
    }
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
    FCWithdrawHistory* invoice = [self.listInvoice objectAtIndex:indexPath.row];
    [cell loadWithdraw:invoice];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCInvoiceDetailViewController* detailVC = [[FCInvoiceDetailViewController alloc] init];
    detailVC.isPushedView = YES;
    [detailVC setWithdrawData:[self.listInvoice objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailVC
                                         animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView tableViewDidScroll];
}

@end
