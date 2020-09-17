//
//  FCHelpViewController.m
//  FaceCar
//
//  Created by facecar on 4/6/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCHelpViewController.h"
#import "FCHelp.h"
#import "FCWebViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCNotifyBannerView.h"
@import MessageUI;

#define kCell @"cell-help"

@interface FCHelpViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FCHelpViewController {
    NSArray* _listMenus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:kCell];
    
    [[FirebaseHelper shareInstance] getAppConfigure:^(FCAppConfigure* appconfigure) {
        _listMenus = appconfigure.driver_help_menus;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) btnLeftClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listMenus.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCell forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    FCHelp* help = [_listMenus objectAtIndex:indexPath.row];
    cell.textLabel.text = help.name;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FCHelp* help = [_listMenus objectAtIndex:indexPath.row];
    if (help.type == 1) {
        FCWebViewController* vc = [[FCWebViewController alloc] initViewWithViewModel:[[FCWebViewModel alloc] initWithUrl:help.link]];
        FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
        [navController setModalPresentationStyle:UIModalPresentationFullScreen];
        [self.navigationController presentViewController:navController
                                                animated:YES
                                              completion:nil];
    }
    else if (help.type == 2) {
        [self callPhone:help.link];
    }
    else if (help.type == 3) {
        [self sendEmailSupport:help.link];
    }
}

- (void) sendEmailSupport: (NSString*) email {
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        return;
    }
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setMessageBody:@"" isHTML:NO];
    [controller setToRecipients:[NSArray arrayWithObjects:email, nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultSent) {
        [[FCNotifyBannerView banner] show:nil
                                  forType:FCNotifyBannerTypeSuccess
                                 autoHide:YES
                                  message:@"VATO xin chân thành cảm ơn những đóng góp của bạn."
                               closeClick:nil
                              bannerClick:nil];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
