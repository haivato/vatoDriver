//
//  ClientProfileViewController.h
//  FC
//
//  Created by Son Dinh on 6/4/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClientProfileViewController : UITableViewController
@property (strong, nonatomic) FCFavorite *favorite;
@property (strong, nonatomic) FCClient* client;
@end
