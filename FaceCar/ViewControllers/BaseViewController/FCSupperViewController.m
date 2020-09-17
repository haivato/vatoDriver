//
//  FCSupperViewController.m
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCSupperViewController.h"
#import "FacecarNavigationViewController.h"

@interface FCSupperViewController ()

@end

@implementation FCSupperViewController

- (id) initView {
    self = [super init];
    
    return self;
}

- (id) init {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (UINavigationController*) loadWithNavi {
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:self];
    
    return navController;
}

- (void) setupBackNav {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void) setupCloseNav {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void) backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) closePressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
