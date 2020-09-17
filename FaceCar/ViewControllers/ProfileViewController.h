//
//  ProfileViewController.h
//  FC
//
//  Created by facecar on 10/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

@interface ProfileViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *cellRegisterProfileLvl2;
@property (weak, nonatomic) IBOutlet UILabel *lblProfileLvl2Status;


@property (strong, nonatomic) FCHomeViewModel* homeViewmodel;
@end
