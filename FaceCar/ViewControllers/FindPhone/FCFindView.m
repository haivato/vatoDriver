//
//  FCRegisterStationView.m
//  FaceCar
//
//  Created by facecar on 9/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCFindView.h"
#import "APIHelper.h"
#import "FacecarNavigationViewController.h"

@interface FCFindView ()
@end

@implementation FCFindView
{
    UIViewController* supperVC;
}

- (FCFindView*) initView: (UIViewController*) vc {
    self = [[[NSBundle mainBundle] loadNibNamed:@"FCFindView" owner:self options:nil] firstObject];
    supperVC = vc;
    [self.textField becomeFirstResponder];
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    if ([self isPhoneX]) {
        self.consHeight.constant = 500.0f;
    }
    else {
        self.consHeight.constant = 450.0f;
    }
}


- (IBAction)textfiledChanged:(UITextField*)textField {
    
    NSString* fullString = textField.text;
    
    if ([self validPhone:fullString]) {
        
    }
    else {
        self.lblError.hidden = YES;
    }
}

- (void) setupView {
    RAC(self.btnContinue, enabled) = [RACSignal combineLatest:@[self.textField.rac_textSignal,
                                                                RACObserve(self.progressView, hidden)]
                                                       reduce:^(NSString* phone, NSNumber* processing){
                                                           return @([self validPhone:phone] && [processing boolValue]);
                                                       }];
    
    [RACObserve(self.lblError, hidden) subscribeNext:^(id x) {
        [self.progressView dismiss];
    }];
}

- (IBAction)onContinueClicked:(id)sender {
    if ([self validPhone:self.textField.text]) {
        [self findUser:^(FCUserInfo *info) {
            info.phoneNumber = self.textField.text;
            self.userInfo = info;
        }];
    }
}

- (IBAction)closeView:(id)sender {
    [self removeView];
}

-(IBAction)bgTouch:(id)sender {
    [self closeView:sender];
}

- (void) finishedEnterPasscode: (NSString*) phone {
    [self.progressView show];
}

- (void) removeView {
    [self resignFirstResponder];
    [self removeFromSuperview];
}

- (void) findUser: (void (^) (FCUserInfo* info)) block {
    [IndicatorUtils show];
    NSDictionary* body = @{@"phoneNumber": self.textField.text};
    [[APIHelper shareInstance] get:API_GET_USER_INFO
                            params:body
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                              FCUserInfo* info = [[FCUserInfo alloc] initWithDictionary:response.data
                                                                                  error:nil];
                              block(info);
                          }];
}
@end

