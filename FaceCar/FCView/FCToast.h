//
//  FCToast.h
//  FaceCar
//
//  Created by facecar on 11/16/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCToast : UIView

@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIView *bg;

@property (strong, nonatomic) UIView* parentView;

- (instancetype) initView;
- (void) show;

@end
