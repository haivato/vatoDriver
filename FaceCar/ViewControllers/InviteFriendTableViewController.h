//
//  InviteFriendTableViewController.h
//  FaceCar
//
//  Created by facecar on 4/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

@interface InviteFriendTableViewController : UITableViewController

@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) NSString* inviteCode;

@end
