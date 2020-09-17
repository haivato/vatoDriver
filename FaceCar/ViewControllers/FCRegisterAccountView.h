//
//  FCRegisterAccountView.h
//  FaceCar
//
//  Created by facecar on 11/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCLoginViewModel.h"

@interface FCRegisterAccountView : FCView
@property (weak, nonatomic) IBOutlet FCButtonNext *btnNext;
@property (strong, nonatomic) FCLoginViewModel* loginViewModel;
@property (strong, nonatomic) FCDriver* driver;
@property (assign, nonatomic) BOOL isUpdate;

- (void) loadUserInfo;

@end
