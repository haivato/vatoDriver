//
//  FCUploadPofileImageViewController.h
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCProfileLevel2.h"

@interface FCUploadPofileImageViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

@property (strong, nonatomic) FCProfileLevel2* profileLvl2;

@end
