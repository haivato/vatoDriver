//
//  FCDepositViewController.m
//  FC
//
//  Created by facecar on 6/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCDepositViewController.h"
#import "UIView+Border.h"

@interface FCDepositViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfAmount;
@property (weak, nonatomic) IBOutlet UIButton *btnZalopay;
@property (weak, nonatomic) IBOutlet UIButton *btnBankPlus;

@end

@implementation FCDepositViewController


- (instancetype) initView {
    self = [self initWithNibName:@"FCDepositViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Nạp tiền";
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.walletViewModel = [[FCWalletViewModel alloc] initViewModel:self];
    
    [self.btnZalopay borderViewWithColor:[UIColor clearColor] andRadius:5];
    [self.btnBankPlus borderViewWithColor:[UIColor lightGrayColor] andRadius:5];
    
    [self.tfAmount becomeFirstResponder];
    
    [RACObserve(self.tfAmount, text) subscribeNext:^(NSString* x) {
        self.walletViewModel.amountForDeposit = [self getPrice:self.tfAmount.text];
    }];
    
    RAC(self.btnZalopay, enabled) = [RACSignal combineLatest:@[RACObserve(self.tfAmount, text)] reduce:^(NSString* amount){
        NSInteger price = [self getPrice:amount];

        if (LOG) {
            return @(price >= 1000);
        }
        return @(price >= 50000);
        
    }];
    
    RAC(self.btnBankPlus, enabled) = [RACSignal combineLatest:@[RACObserve(self.tfAmount, text)] reduce:^(NSString* amount){
        NSInteger price = [self getPrice:amount];
        
        if (LOG) {
            return @(price >= 1000);
        }
        return @(price >= 50000);
        
    }];
    
    [RACObserve(self.walletViewModel, depositResult) subscribeNext:^(id x) {
        if ([x integerValue] == ZPErrorCode_Success) {
            [self showMessageBanner:@"Chúc mừng bạn đã nạp tiền thành công"
                             status:YES];
            [self backPressed:nil];
        }
        else if ([x integerValue] == ZPErrorCode_NotInstall) {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Bạn phải cài đặt ZaloPay để thực hiện chức năng này"
                                                 message:nil
                                       cancelButtonTitle:nil
                                  destructiveButtonTitle:@"Huỷ"
                                       otherButtonTitles:@[@"Đồng ý"]
                                                tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                    
                                                    if (buttonIndex == 2) {
                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ZALO_APP_STORE]];
                                                    }
                                                }];
        }
        else if ([x integerValue] != 0 && [x integerValue] != ZPErrorCode_UserCancel) {
            [self showMessageBanner:[NSString stringWithFormat:@"Xảy ra lỗi, bạn vui lòng quay lại sau. Hoặc gọi %@ để được hỗ trợ", PHONE_CENTER]
                             status:NO];
        }
    }];
    
    [RACObserve(self.walletViewModel, bplusResult) subscribeNext:^(id x) {
        if (x && [x boolValue] == TRUE) {
            [self showMessageBanner:@"Chúc mừng bạn đã nạp tiền thành công"
                             status:YES];
            [self backPressed:nil];
        }
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zaloPaySuccess:) name:NOTIFICATION_ZALO_SUCCESS object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ZALO_SUCCESS object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)priceChanged:(UITextField*)textField {
    NSInteger price = [self getPrice:textField.text];
    [textField setText:[self formatPrice:price]];
    if (textField.text.length > 1) {
        [self selectTextForInput:textField atRange:NSMakeRange(textField.text.length - 1, 0)];
    }
}

- (void)selectTextForInput:(UITextField *)input atRange:(NSRange)range {
    UITextPosition *start = [input positionFromPosition:[input beginningOfDocument]
                                                 offset:range.location];
    UITextPosition *end = [input positionFromPosition:start
                                               offset:range.length];
    [input setSelectedTextRange:[input textRangeFromPosition:start toPosition:end]];
}


#pragma mark - Zalo
- (void) zaloPaySuccess: (id) sender {
    [self showMessageBanner:@"Chúc mừng bạn đã nạp tiền thành công"
                     status:YES];
    [self backPressed:nil];
}

- (IBAction)zaloPayClicked:(id)sender {
    [self.walletViewModel apiGetOder];
    [self.view endEditing:YES];
}

#pragma mark - Bplus
- (IBAction)bplusClicked:(id)sender {
    [self.walletViewModel apiGetBplusOrder];
    [self.view endEditing:YES];
}

@end
