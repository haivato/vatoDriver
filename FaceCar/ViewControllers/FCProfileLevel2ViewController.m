//
//  FCProfileLevel2ViewController.m
//  FC
//
//  Created by facecar on 10/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCProfileLevel2ViewController.h"
#import "IQActionSheetPickerView.h"
#import "FCProfileLevel2.h"
#import "FCUploadPofileImageViewController.h"
#import "FCWebViewController.h"
#import "FacecarNavigationViewController.h"

#define PICKER_BIRTHDAY 1
#define PICKER_CMND 2
#define segueUploadCMND @"segueUploadCMND"

@interface FCProfileLevel2ViewController () <IQActionSheetPickerViewDelegate>
@property (strong, nonatomic) FCProfileLevel2* profileLvl2;
@end

@implementation FCProfileLevel2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileLvl2 = [[UserDataHelper shareInstance] getLvl2Info];
    if (!self.profileLvl2) {
        self.profileLvl2 = [[FCProfileLevel2 alloc] init];
    }
    else {
        self.tfName.text = self.profileLvl2.name;
        self.tfEmail.text = self.profileLvl2.email;
        self.tfBirthDay.text = [self getTimeStringByDate:self.profileLvl2.birthDay];
        self.tfCMND.text = self.profileLvl2.cmnd;
        self.tfCmndDate.text = [self getTimeStringByDate:self.profileLvl2.cmndDate];
        self.tfCmndPlace.text = self.profileLvl2.cmndPlace;
    }
    
    RAC(self.btnContinue, enabled) = [RACSignal combineLatest:@[self.tfName.rac_textSignal,
                                                                self.tfEmail.rac_textSignal,
                                                                RACObserve(self.tfBirthDay, text),
                                                                self.tfCMND.rac_textSignal,
                                                                RACObserve(self.tfCmndDate, text),
                                                                self.tfCmndPlace.rac_textSignal]
                                                       reduce:^(NSString* name,
                                                                NSString* email,
                                                                NSString* birthday,
                                                                NSString* cmnd,
                                                                NSString* cmndDate,
                                                                NSString* cmndPlace){
                                                           if (name.length == 0 ||
                                                               (email.length > 0 && ![self validEmail:email]) ||
                                                               birthday.length == 0 ||
                                                               cmnd.length == 0 ||
                                                               cmndDate.length == 0 ||
                                                               cmndPlace.length == 0) {
                                                               
                                                               if (name.length == 0)
                                                                   self.lblError.text = @"Thiếu họ tên (phải trùng với CMND)";
                                                               else if (email.length > 0 && ![self validEmail:email])
                                                                   self.lblError.text = @"Email không đúng";
                                                               else if (birthday.length == 0)
                                                                   self.lblError.text = @"Thiếu ngày tháng năm sinh";
                                                               else if (cmnd.length == 0)
                                                                   self.lblError.text = @"Thiếu CMND";
                                                               else if (cmndDate.length == 0)
                                                                   self.lblError.text = @"Thiếu ngày cấp CMND";
                                                               else if (cmndPlace.length == 0)
                                                                   self.lblError.text = @"Thiếu nơi cấp CMND";
                                                              
                                                               return @(NO);
                                                           }
                                                           
                                                           self.lblError.text = EMPTY;
                                                           return @(YES);
                                                       }];
    
    @try {
        RAC(self.profileLvl2, name) = self.tfName.rac_textSignal;
        RAC(self.profileLvl2, email) = self.tfEmail.rac_textSignal;
        RAC(self.profileLvl2, cmnd) = self.tfCMND.rac_textSignal;
        RAC(self.profileLvl2, cmndPlace) = self.tfCmndPlace.rac_textSignal;
    }
    @catch (NSException* e) {}
    @finally {}
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:segueUploadCMND]) {
        [[UserDataHelper shareInstance] cacheLvl2Info:self.profileLvl2];
        
        FCUploadPofileImageViewController* des = segue.destinationViewController;
        des.profileLvl2 = self.profileLvl2;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)birthdayTouch:(id)sender {
    [self.view endEditing:YES];
    
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Chọn ngày" delegate:self];
    picker.tag = PICKER_BIRTHDAY;
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
    [picker show];
}

- (IBAction)cmndDateTouch:(id)sender {
    [self.view endEditing:YES];
    
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Chọn ngày" delegate:self];
    picker.tag = PICKER_CMND;
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
    [picker show];
}

- (IBAction)agreementClicked:(id)sender {
    FCWebViewController* vc = [[FCWebViewController alloc] initViewWithViewModel:[[FCWebViewModel alloc] initWithUrl:PRIVACY_URL]];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
    [self presentViewController:navController animated:TRUE completion:nil];
}

- (void) actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date {
    if (pickerView.tag == PICKER_BIRTHDAY) {
        [self.tfBirthDay setText:[self getTimeStringByDate:date]];
        self.profileLvl2.birthDay = date;
    }
    else if (pickerView.tag == PICKER_CMND) {
        [self.tfCmndDate setText:[self getTimeStringByDate:date]];
        self.profileLvl2.cmndDate = date;
    }
}

@end
