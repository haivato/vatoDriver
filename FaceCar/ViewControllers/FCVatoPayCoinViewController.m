//
//  VatoPayCoinViewController.m
//  FC
//
//  Created by tony on 12/11/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCVatoPayCoinViewController.h"
#import "NSArray+Extension.h"
#import "FCInvoiceManagerViewController.h"
#import "FCInvoiceDetailViewController.h"
#if DEV
    #import "Driver_DEV-Swift.h"
#else
    #import "VATO_Driver-Swift.h"
#endif

@interface FCVatoPayCoinViewController ()<WalletListHistoryDetailProtocol>
@property (weak, nonatomic) IBOutlet UILabel *lblTotalAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblAvailableAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblPendingAmount;

// topup
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consTopupFromCashHeight;
@property (weak, nonatomic) IBOutlet UIView *topupFromCashView;
@property (weak, nonatomic) IBOutlet UILabel *lblTopupFromCash;
@property (strong, nonatomic) WalletListHistoryObjcWrapper *wrapper;
@property (strong, nonatomic) NSArray <FCLinkConfigure *> *configTopup;
@end

@implementation FCVatoPayCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Tiền tín dụng nhận chuyến";
    @weakify(self);
    [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (error) {
            return;
        }
        @strongify(self);
        
        self.wrapper = [[WalletListHistoryObjcWrapper alloc] initWithVC:self firebaseAuthen:token type:ListHistoryTypeCredit];
    }];
    [self registerListener];
    [self checkTopupView];
    
    if (self.balance) {
        [self reloadView];
    }
    else {
        [self fetchBalance];
    }
}

- (void) resetTopupConfig {
    @synchronized (self) {
        self.configTopup = [NSArray new];
    }
}

- (void)updateTopupConfig:(NSArray <FCLinkConfigure *> *)configs {
    if ([configs count] == 0) {
        return;
    }
    
    @synchronized (self) {
        self.configTopup = configs;
    }
}

- (void) showDetailFrom:(NSDictionary<NSString *,id> *)json {
    FCInvoiceDetailViewController* detailVC = [[FCInvoiceDetailViewController alloc] init];
    detailVC.isPushedView = YES;
    FCInvoice *i = [[FCInvoice alloc] initWithDictionary:json error:nil];
    [detailVC setInvoice:i];
    [self.navigationController pushViewController:detailVC
                                         animated:YES];
}

- (void) registerListener {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchBalance)
                                                 name:NOTIFICATION_TRANSFER_MONEY_COMPLETED
                                               object:nil];
}

- (void) fetchBalance {
    UINavigationController *navi = self.navigationController;
    if (navi) {
        NSArray *viewControllers = [navi viewControllers];
        NSUInteger idx = [viewControllers indexOfObject:self];
        
        if (!(idx == NSNotFound || idx == [viewControllers count] - 1)) {
            [navi popToViewController:self animated:YES];;
        }
    }
    
    
    [APICall apiGetMyBalance:^(FCBalance * balance) {
        self.balance = balance;
        [self reloadView];
    }];
}

- (void) reloadView {
    if (!self.balance) {
        return;
    }
    
    self.lblTotalAmount.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:(self.balance.credit + self.balance.creditPending) withSeperator:@","]];
    self.lblAvailableAmount.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:self.balance.credit withSeperator:@","]];
    self.lblPendingAmount.text = [NSString stringWithFormat:@"%@đ", [self formatPrice:self.balance.creditPending withSeperator:@","]];
}

#pragma mark - Check PIN
- (void) canTranserCash: (void (^) (BOOL can)) block {
    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_CHECK_TRANF_CASH
                            params:nil
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                              if (response.status == APIStatusOK) {
                                  BOOL c = [(NSNumber*)response.data boolValue];
                                  block(c);
                              }
                          }];
}

- (void) loadCreatePINView {
    FCPasscodeViewController* passView = [[FCPasscodeViewController alloc] initWithNibName:@"FCPasscodeViewController"
                                                                                    bundle:nil];
    [self.navigationController pushViewController:passView
                                         animated:YES];
}

#pragma mark - Topup Config
- (void) checkTopupView {
    [self enableTopupView:NO];
    @weakify(self);
    [[APIHelper shareInstance] get:API_GET_TOPUP_CONFIG params:nil complete:^(FCResponse *response, NSError *e) {
        @strongify(self);
        NSMutableArray* channels = [[NSMutableArray alloc] init];
        if (response.status == APIStatusOK && response.data) {
            for (NSDictionary* dict in response.data) {
                FCLinkConfigure* config = [[FCLinkConfigure alloc] initWithDictionary:dict error:nil];
                if (config && config.active) {
                    [channels addObject:config];
                }
            }
        }
        [self enableTopupView:channels.count > 0];
        [self updateTopupConfig:channels];
    }];
}

- (void) enableTopupView: (BOOL) enable {
    if (enable) {
        self.topupFromCashView.hidden = NO;
        self.consTopupFromCashHeight.constant = 56;
        self.lblTopupFromCash.text = @"Nạp tiền qua kênh thanh toán";
    } else {
        self.topupFromCashView.hidden = YES;
        self.consTopupFromCashHeight.constant = 0;
        self.lblTopupFromCash.text = EMPTY;
    }
    [self.tableView reloadData];
}

- (NSArray <FCLinkConfigure *> *)configure_top_up {
    NSArray *result;
    @synchronized (self) {
        result = self.configTopup;
    }
    
    return result ?: @[];
}

#pragma mark - Action handler
- (void) backPressed: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)topupFromCashTapped:(id)sender {
    [self canTranserCash:^(BOOL can) {
        if (can) {
            FCLinkConfigure *config  = [FCLinkConfigure new];
            config.min = MIN(10000, self.balance.hardCash);
            config.max = self.balance.hardCash;
            config.name = @"Doanh thu chuyến đi";
            [config setOptions:@[@(100000), @(200000), @(500000)]];
            TopupByMoneyVC *moneyVC = [[TopupByMoneyVC alloc] initWith:config credit:self.balance.credit hardCash:self.balance.hardCash];
            [self.navigationController pushViewController:moneyVC animated:YES];
        }
        else {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Thông báo"
                                                 message:@"Bạn cần tạo mật khẩu thanh toán để sử dụng chức năng này. Tạo mật khẩu?"
                                       cancelButtonTitle:nil
                                  destructiveButtonTitle:@"Bỏ qua"
                                       otherButtonTitles:@[@"Đồng ý"]
                                                tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                    if (buttonIndex == 2) {
                                                        [self loadCreatePINView];
                                                    }
                                                }];
        }
    }];
}

- (IBAction)topupFromExternalChannelTapped:(id)sender {
    TopUpChooseVC *chooseVC = [[TopUpChooseVC alloc] initWith:[self configure_top_up]];
    [self.navigationController pushViewController:chooseVC animated:YES];
}

- (IBAction)historyTapped:(id)sender {
    [FCTrackingHelper trackEvent:@"Topup" value:@{@"ClickButton" : @"History"}];
//    FCInvoiceManagerViewController* vc = [[FCInvoiceManagerViewController alloc] initView];
//    [self.navigationController pushViewController:vc animated:YES];
    [_wrapper showList];
}

#pragma mark - Tableview Delegate
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
        view.backgroundColor = [UIColor clearColor];
        UILabel* lableTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 18)];
        lableTime.font = [UIFont systemFontOfSize:10];
        [lableTime setTextAlignment:NSTextAlignmentCenter];
        lableTime.textColor = UIColor.darkGrayColor;
        FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
        lableTime.text = [NSString stringWithFormat:@"%li | %@", (long)driver.user.id, APP_VERSION_STRING];
        [view addSubview:lableTime];
        return view;
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 18;
    }
    
    return 40;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
