//
//  FacecarNavigationViewController.m
//  FaceCar
//
//  Created by vudang on 2/19/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FacecarNavigationViewController.h"

@interface FacecarNavigationViewController ()

@end

@implementation FacecarNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBarTintColor:GREEN_COLOR];
//    [self.navigationBar setBarTintColor:GRAY_COLOR];
    self.navigationBar.translucent = NO;
    [self.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
