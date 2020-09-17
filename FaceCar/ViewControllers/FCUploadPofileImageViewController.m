//
//  FCUploadPofileImageViewController.m
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCUploadPofileImageViewController.h"
#import "FCUploadImageProcessViewController.h"
#import "FCPasscodeViewController.h"

#define kSegueFontCMND @"kSegueFontCMND"
#define kSegueBackCMND @"kSegueBackCMND"
#define kSegueAvatar @"kSegueAvatar"
#define kSegueCreatePIN @"kSegueCreatePIN"

@interface FCUploadPofileImageViewController ()

@end

@implementation FCUploadPofileImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    RAC(self.btnContinue, enabled) = [RACSignal combineLatest:@[RACObserve(self.profileLvl2, urlCmndFisrt),
                                                                RACObserve(self.profileLvl2, urlCmndFisrt),
                                                                RACObserve(self.profileLvl2, urlAvatar)]
                                                       reduce:^(NSString* cmndFont, NSString* cmndBack, NSString* avatar){
                                                           if (cmndFont.length == 0 ||
                                                               cmndBack.length == 0 ||
                                                               avatar.length == 0) {
                                                               return @(NO);
                                                           }
                                                           return @(YES);
                                                       }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kSegueFontCMND]) {
        FCUploadImageProcessViewController* des = segue.destinationViewController;
        des.imageType = FONT_CMND;
        [RACObserve(des, imageUrlResult) subscribeNext:^(NSString* url) {
            if (url.length > 0) {
                self.profileLvl2.urlCmndFisrt = url;
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }];
    }
    else if ([segue.identifier isEqualToString:kSegueBackCMND]) {
        FCUploadImageProcessViewController* des = segue.destinationViewController;
        des.imageType = BACK_CMND;
        [RACObserve(des, imageUrlResult) subscribeNext:^(NSString* url) {
            if (url.length > 0) {
                self.profileLvl2.urlCmndSecond = url;
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }];
    }
    else if ([segue.identifier isEqualToString:kSegueAvatar]) {
        FCUploadImageProcessViewController* des = segue.destinationViewController;
        des.imageType = AVATAR;
        [RACObserve(des, imageUrlResult) subscribeNext:^(NSString* url) {
            if (url.length > 0) {
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.profileLvl2.urlAvatar = url;
            }
        }];
    }
    else if ([segue.identifier isEqualToString:kSegueCreatePIN]) {
        [[UserDataHelper shareInstance] cacheLvl2Info:self.profileLvl2];
        
        FCPasscodeViewController* des = segue.destinationViewController;
    }
}
@end
