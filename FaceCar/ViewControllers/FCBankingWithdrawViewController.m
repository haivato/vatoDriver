//
//  FCBankingWithdrawViewController.m
//  FC
//
//  Created by tony on 8/30/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBankingWithdrawViewController.h"
#import "FCTextView.h"
#import "FCBanking.h"
#import "NSString+Helper.h"
#import "FCPassCodeView.h"
#import "FCBankingWithdrawHistoryViewController.h"
#import "FCBankingListTableViewController.h"

@interface FCBankingWithdrawViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblBankName;
@property (weak, nonatomic) IBOutlet UITextField *tfBankBranch;
@property (weak, nonatomic) IBOutlet UITextField *tfBankAccount;
@property (weak, nonatomic) IBOutlet UITextField *tfBankAccountName;
@property (weak, nonatomic) IBOutlet UITextField *tfAmountWithdraw;
@property (weak, nonatomic) IBOutlet FCTextView *tfNote;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet FCButton *btnComplete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBankName;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBankBranch;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellNote;

@property (weak, nonatomic) IBOutlet UILabel *lblBankNameErr;
@property (weak, nonatomic) IBOutlet UILabel *lblBankBranchErr;
@property (weak, nonatomic) IBOutlet UILabel *lblBankAccountNumberErr;
@property (weak, nonatomic) IBOutlet UILabel *lblBankAccountNameErr;
@property (weak, nonatomic) IBOutlet UILabel *lblAmountErr;
@end

@implementation FCBankingWithdrawViewController {
    BOOL _isVerifyInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 90;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    if (self.bankingInfo) {
        self.navigationItem.title = @"Xác nhận thông tin";
        _isVerifyInfo = YES;
        [self setupViewBankingVerify];
    }
    else {
        self.navigationItem.title = @"Rút tiền";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history-1"] style:UIBarButtonItemStylePlain target:self action:@selector(onHistoryClick)];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        
        _banking = [self getDefaultBanking];
        self.bankingInfo = [[UserDataHelper shareInstance] getBankingInfo:_banking.name];
        [self setupViewBankingNew];
    }
    
    if ([[FirebaseHelper shareInstance] getListBanking].count == 1) {
        self.cellBankName.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackClick)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    if (self.userCash > 0) {
        self.lblAmount.text = [self formatPrice:MAX(self.userCash - _banking.minimumBalance, 0) withSeperator:@"."];
    }
    else {
        __block RACDisposable* handler = [RACObserve([FCHomeViewModel getInstace].driver.user, cash) subscribeNext:^(id x) {
            if (x) {
                self.userCash = [x integerValue];
                self.lblAmount.text = [self formatPrice:MAX(self.userCash - _banking.minimumBalance, 0) withSeperator:@"."];
                [handler dispose];
            }
        }];
    }   
}

- (void) onBackClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onHistoryClick {
    FCBankingWithdrawHistoryViewController* hisVC = [[FCBankingWithdrawHistoryViewController alloc] initView];
    [self.navigationController pushViewController:hisVC animated:YES];
}

- (void) showBankingList {
    FCBankingListTableViewController* vc = [[FCBankingListTableViewController alloc] init];
    vc.currentBank = _banking;
    [self.navigationController pushViewController:vc animated:YES];
    __block RACDisposable* handler = [RACObserve(vc, bankingSelected) subscribeNext:^(FCBanking* x) {
        if (x) {
            _banking = x;
            self.bankingInfo = [[UserDataHelper shareInstance] getBankingInfo:_banking.name];
            [self setupViewBankingNew];
            [handler dispose];
        }
    }];
}

- (IBAction)onCompleteClicked:(id)sender {
    if (_isVerifyInfo) {
        [self showPasscodeView];
    }
    else if ([self validateWithdrawData]) {
        NSString* branch = [self.tfBankBranch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* accountNumber = [self.tfBankAccount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* accountName = [self.tfBankAccountName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* amountStr = [self.tfAmountWithdraw.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* note = [self.tfNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSInteger amount = 0;
        if (amountStr.length > 0) {
            amount = [self getPrice:amountStr];
        }
        
        _bankingInfo.bank = self.lblBankName.text;
        _bankingInfo.bankBranch = branch;
        _bankingInfo.bankAccount = accountNumber;
        _bankingInfo.accountName = accountName;
        _bankingInfo.amount = amount;
        _bankingInfo.bankNote = note;
        
        [self showConfirmWithdrawView];
    }
    
    [self.tableView reloadData];
}

- (void) showPasscodeView {
    FCPassCodeView* view = [[FCPassCodeView alloc] initView:self];
    view.lblTitle.text = @"Nhập mật khẩu thanh toán";
    view.lblFogotPass.hidden = YES;
    view.btnFogotPass.hidden = YES;
    [view setupView:PasscodeTypeClose];
    [self.navigationController.view addSubview:view];
    
    [RACObserve(view, passcode) subscribeNext:^(NSString* pass) {
        if (pass.length == 6) {
            [self verifyRequestWithdraw: pass];
            [view removeFromSuperview];
        }
    }];
}

- (void) verifyRequestWithdraw: (NSString*) pinCode {
    [IndicatorUtils show];
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:[self.bankingInfo toDictionary]];
    [body addEntriesFromDictionary:@{@"pin":pinCode}];
    [[UserDataHelper shareInstance] saveBankingInfo:self.bankingInfo];
    [[UserDataHelper shareInstance] saveDefaultBanking:_banking];
    [self apiVerify:body complete:^(BOOL success) {
        [IndicatorUtils dissmiss];
        [self onCompletedWithdraw:success];
    }];
}

- (void) setupViewBankingVerify {
    self.tableView.allowsSelection = NO;
    self.cellBankName.accessoryType = UITableViewCellAccessoryNone;
    self.tfNote.editable = NO;
    self.tfBankBranch.userInteractionEnabled = NO;
    self.tfBankAccount.userInteractionEnabled = NO;
    self.tfAmountWithdraw.userInteractionEnabled = NO;
    self.tfBankAccountName.userInteractionEnabled = NO;
    [self.btnComplete setTitle:@"HOÀN TẤT" forState:UIControlStateNormal];
    
    [self loadDataBankingInfo];
}

- (void) setupViewBankingNew {
    if (self.bankingInfo && self.bankingInfo.bank.length > 0) {
        [self loadDataBankingInfo];
    }
    else {
        self.bankingInfo = [[FCBankingInfo alloc] init];
        [self resetBankingInfo];
    }
}

- (void) loadDataBankingInfo {
    self.lblBankName.text = self.bankingInfo.bank;
    self.tfBankAccount.text = self.bankingInfo.bankAccount;
    self.tfBankAccountName.text = self.bankingInfo.accountName;
    self.tfBankBranch.text = self.bankingInfo.bankBranch;
    self.tfAmountWithdraw.text = [self formatPrice:self.bankingInfo.amount withSeperator:@"."];
    self.tfNote.text = self.bankingInfo.bankNote;
    [self.tableView reloadData];
}

- (void) resetBankingInfo {
    self.lblBankName.text = _banking.name;
    self.tfBankAccount.text = EMPTY;
    self.tfBankAccountName.text = EMPTY;
    self.tfBankBranch.text = EMPTY;
//    self.tfAmountWithdraw.text = EMPTY;
    self.tfAmountWithdraw.placeholder = [NSString stringWithFormat:@"Rút tiền tối thiểu %@", [self formatPrice:_banking.min]];
    self.tfNote.text = EMPTY;
}

- (FCBanking*) getDefaultBanking {
    FCAppConfigure* configure = [FirebaseHelper shareInstance].appConfigure;
    
    if (configure.banking.count > 0) {
        // get from cache first
        FCBanking* bankCache = [[UserDataHelper shareInstance] getDefaultBanking];
        if (bankCache) {
            for (FCBanking* bank in configure.banking) {
                if (bank.id == bankCache.id && bank.active) {
                    return bank;
                }
            }
        }
        
        // if not bank from cache -> get default
        for (FCBanking* bank in configure.banking) {
            if (bank.chooseDefault && bank.active) {
                return bank;
            }
        }
    }
    return nil;
}

- (void) showConfirmWithdrawView {
    FCBankingWithdrawViewController* vc = (FCBankingWithdrawViewController*) [[NavigatorHelper shareInstance] getViewControllerById:@"FCBankingWithdrawViewController" inStoryboard:@"FCBankingWithdrawViewController"];
    vc.bankingInfo = self.bankingInfo;
    vc.banking = self.banking;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onCompletedWithdraw: (BOOL) success {
    NSString* message = nil;
    if (success) {
        message = @"Hệ thống đã nhận được yêu cầu rút tiền của bạn. Sẽ có thông báo khi tiền chuyển về tài khoản của bạn thành công. Hoặc bạn có thể vào danh sách lịch sử chuyển tiền để kiểm tra trạng thái yêu cầu rút tiền của bạn";
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Thông báo"
                                             message:message
                                   cancelButtonTitle:@"Tôi đã hiểu"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                [self.navigationController popToRootViewControllerAnimated:YES];
                                            }];
    }
}

#pragma mark - Validate
- (NSString*) validateBankBranch {
    NSString* branch = [self.tfBankBranch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (branch.length > 0) {
        if (branch.length < 3) {
            return @"Thông tin nhập tối thiểu là 3 ký tự";
        }
        else if ([branch wordCount] < 2) {
            return @"Thông tin nhập tối thiểu là 2 từ";
        }
    }
    return nil;
}

- (NSString*) validateBankAccountNumber {
    NSString* accountNumber = [self.tfBankAccount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (accountNumber.length == 0) {
        return @"Cung cấp số tài khoản ngân hàng";
    }
    else if (accountNumber.length < 4) {
        return @"Thông tin nhập tối thiểu là 4 ký tự";
    }
    else if (![self validBankAccount:accountNumber]) {
        return @"Thông tin nhập có ký tự không hợp lệ";
    }
    return nil;
}

- (NSString*) validateBankAccountName {
    NSString* accountName = [self.tfBankAccountName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (accountName.length == 0) {
        return @"Cung cấp tên chủ tài khoản";
    }
    else if ([accountName wordCount] < 2) {
        return @"Thông tin nhập tối thiểu là 2 từ";
    }
    return nil;
}

- (NSString*) validateAmountWithdraw {
    NSString* amountStr = [self.tfAmountWithdraw.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger amount = 0;
    if (amountStr.length > 0) {
        amount = [self getPrice:amountStr];
    }
    
    NSInteger cashAvailable = MAX(self.userCash - _banking.minimumBalance, 0);
    if (cashAvailable < amount) {
        return @"Số dư không đủ";
    }
    else if (amount < _banking.min) {
        return [NSString stringWithFormat:@"Số tiền tối thiểu là %@", [self formatPrice:_banking.min]];
    }
    else if (amount % 10000 != 0) {
        return @"Số tiền phải là bội số của 10,000đ";
    }
    return nil;
}


- (BOOL) validateWithdrawData {
    BOOL valid = YES;
    // amount checking (required)
    if([self validateAmountWithdraw]) {
        self.lblAmountErr.text = [self validateAmountWithdraw];
        valid = NO;
    }
    
    // branch checking (optional)
    if([self validateBankBranch]){
        self.lblBankBranchErr.text = [self validateBankBranch];
        valid = NO;
    }
    
    // bank number (required)
    if([self validateBankAccountNumber]) {
        self.lblBankAccountNumberErr.text = [self validateBankAccountNumber];
        valid = NO;
    }
    
    // bank account name (required)
    if([self validateBankAccountName]) {
        self.lblBankAccountNameErr.text = [self validateBankAccountName];
        valid = NO;
    }
    
    return valid;
}

#pragma mark - Textfield Delegate
- (IBAction)textfieldChanged:(UITextField*)sender {
    if (sender == self.tfBankBranch) {
        self.lblBankBranchErr.text = EMPTY;
    }
    else if (sender == self.tfBankAccount) {
        self.lblBankAccountNumberErr.text = EMPTY;
    }
    else if (sender == self.tfBankAccountName) {
        self.lblBankAccountNameErr.text = EMPTY;
    }
    else if (sender == self.tfAmountWithdraw) {
        self.lblAmountErr.text = EMPTY;
        
        NSInteger price = [self getPrice:sender.text];
        if (price > 0) {
            [sender setText:[self formatPrice:price withSeperator:@"."]];
        }
        else {
            self.tfAmountWithdraw.placeholder = [NSString stringWithFormat:@"Rút tiền tối thiểu %@", [self formatPrice:_banking.min]];
        }
        
        // resize
        [sender adjustsFontSizeToFitWidth];
        [sender invalidateIntrinsicContentSize];
    }
}

- (IBAction)textfieldDidEnd:(UITextField*)sender {
    if (sender == self.tfBankBranch) {
        self.lblBankBranchErr.text = [self validateBankBranch];
    }
    else if (sender == self.tfBankAccount) {
        self.lblBankAccountNumberErr.text = [self validateBankAccountNumber];
    }
    else if (sender == self.tfBankAccountName) {
        self.lblBankAccountNameErr.text = [self validateBankAccountName];
    }
    else if (sender == self.tfAmountWithdraw) {
        self.lblAmountErr.text = [self validateAmountWithdraw];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Tableview Delegate
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
     return 0.1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isVerifyInfo) {
        if (indexPath.row == 0) {
            [tableView cellForRowAtIndexPath:indexPath].hidden = YES;
            return 0;
        }
        
        if (indexPath.row == 2) { // branch
            if (_bankingInfo.bankBranch.length == 0) {
                [tableView cellForRowAtIndexPath:indexPath].hidden = YES;
                return 0;
            }
        }
        
        if (indexPath.row == 6) { // note
            if (_bankingInfo.bankNote.length == 0) {
                [tableView cellForRowAtIndexPath:indexPath].hidden = YES;
                return 0;
            }
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self showBankingList];
    }
}

#pragma mark - Backend Verify
- (void) apiVerify: (NSDictionary*) info complete: (void (^)(BOOL success)) complete {
    [[APIHelper shareInstance] post:API_WITHDRAW_MONEY_TO_BANK body:info complete:^(FCResponse *response, NSError *e) {
        complete (response.status == APIStatusOK);
    }];
}

@end
