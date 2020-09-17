//
//  ClientProfileViewController.m
//  FC
//
//  Created by Son Dinh on 6/4/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "ClientProfileViewController.h"
#import "FCNotifyBannerView.h"

@interface ClientProfileViewController ()<UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;
@property (strong, nonatomic) IBOutlet UILabel *labelClientName;
@property (strong, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet FCButton *btnClock;

@end

@implementation ClientProfileViewController {
    BOOL _existInList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadClientData];
    
    // get fav info
    [[FirebaseHelper shareInstance] getFavoriteInfo:self.favorite.userFirebaseId handler:^(FCFavorite * fav) {
        _existInList = fav != nil;
        if (fav) {
            [self.btnClock setTitle:@"Bỏ chặn tài khoản này" forState:UIControlStateNormal];
        }
        else {
            [self.btnClock setTitle:@"Chặn tài khoản này" forState:UIControlStateNormal];
        }
    }];
}

- (void) loadClientData {
    if (self.client) {
        self.favorite = [[FCFavorite alloc] init];
        self.favorite.reporterFirebaseid = [FIRAuth auth].currentUser.uid;
        self.favorite.userId = self.client.user.id;
        self.favorite.userFirebaseId = self.client.user.firebaseId;
        self.favorite.userAvatar = self.client.user.avatarUrl;
        self.favorite.userPhone = self.client.user.phone;
        self.favorite.userName = [self.client.user getDisplayName];
        self.labelPhoneNumber.text = self.client.user.phone;
        [self.tableView reloadData];
    }
    else {
        @try {
            NSString* p = [self.favorite.userPhone stringByReplacingCharactersInRange:NSMakeRange(self.favorite.userPhone.length-4, 4) withString:@"xxx"];
            self.labelPhoneNumber.text = p;
        }
        @catch (NSException* e) {
            DLog(@"Error: %@", e)
        }
    }
    
    [self.avatarImage setImageWithURL:[NSURL URLWithString:self.favorite.userAvatar]
                     placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
    [self.labelClientName setText:self.favorite.userName];
}

- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)blockClientClicked:(id)sender {
    if (_existInList) {
        [self apiRemoveBlackList];
    }
    else {
        [self apiAddBlackList];
    }
}

#pragma mark - APIs

- (void) addDriverToMyList {
    [[FirebaseHelper shareInstance] requestAddFavorite:self.favorite
                                   withCompletionBlock:^(NSError * error, FIRDatabaseReference * ref) {
                                       [IndicatorUtils dissmiss];
                                       [self onClose:nil];
                                       
                                       NSString* mess = [NSString stringWithFormat:@"Đã chặn tài khoản '%@' thành công.", self.favorite.userName];
                                       [[FCNotifyBannerView banner] show:nil
                                                                 forType:FCNotifyBannerTypeSuccess
                                                                autoHide:YES
                                                                 message:mess
                                                              closeClick:nil
                                                             bannerClick:nil];
                                   }];
}

- (void) removeDriverFromMyList {
    [[FirebaseHelper shareInstance] removeFromBacklist:self.favorite
                                               handler:^(NSError * error, FIRDatabaseReference * ref) {
                                                   [IndicatorUtils dissmiss];
                                                   [self onClose:nil];
                                                   
                                                   NSString* mess = [NSString stringWithFormat:@"Đã bỏ chặn '%@' khỏi danh sách của bạn.", self.favorite.userName];
                                                   [[FCNotifyBannerView banner] show:nil
                                                                             forType:FCNotifyBannerTypeSuccess
                                                                            autoHide:YES
                                                                             message:mess
                                                                          closeClick:nil
                                                                         bannerClick:nil];
                                               }];
}

- (void) apiAddBlackList {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_ADD_TO_BLACK_LIST
                               body:@{@"userId":@(self.favorite.userId)}
                           complete:^(FCResponse *response, NSError *e) {
                               [IndicatorUtils dissmiss];
                               BOOL ok = [(NSNumber*) response.data boolValue];
                               if (response.status == APIStatusOK && ok) {
                                   [self addDriverToMyList];
                               }
                               else {
                                   [IndicatorUtils dissmiss];
                               }
                           }];
}

- (void) apiRemoveBlackList {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_REMOVE_FROM_BLACK_LIST
                               body:@{@"userId":@(self.favorite.userId)}
                           complete:^(FCResponse *response, NSError *e) {
                               BOOL ok = [(NSNumber*) response.data boolValue];
                               if (response.status == APIStatusOK && ok) {
                                   [self removeDriverFromMyList];
                               }
                               else {
                                   [IndicatorUtils dissmiss];
                               }
                           }
     ];
}

#pragma mark - Table view delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.client) {
        return 1;
    }
    
    return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 50;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2 && self.client) {
        NSString *phoneNumber = [@"tel://" stringByAppendingString:self.client.user.phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
