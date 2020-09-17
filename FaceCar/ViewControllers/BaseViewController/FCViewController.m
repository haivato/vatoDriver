//
//  FCViewController.m
//  FaceCar
//
//  Created by facecar on 3/8/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCViewController.h"
#import "FacecarNavigationViewController.h"

@interface FCViewController ()

@end

@implementation FCViewController

- (instancetype) init {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}


- (instancetype) initViewController {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void) initViewWithNavi {
    
}

- (BOOL) isModal {
    if([self presentingViewController])
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    
    return NO;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isPushedView) {
        self.icBtnLeft = @"back";
    }
    else {
        self.icBtnLeft = @"close-w";
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:self.icBtnLeft]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(btnLeftClicked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:self.icBtnRight]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(btnRightClicked:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = self.title;
}

- (void) btnLeftClicked: (id) sender {
    
}

- (void) btnRightClicked: (id) sender {
    
}

@end
