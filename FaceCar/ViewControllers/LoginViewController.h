//
//  ViewController.h
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCLoginViewModel.h"

@interface LoginViewController : UIViewController

@property (assign, nonatomic) LoginType loginType;
@property (strong, nonatomic) FCLoginViewModel* loginViewmodel;

@end

