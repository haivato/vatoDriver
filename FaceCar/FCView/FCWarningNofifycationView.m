//
//  FCErrorNofifycationView.m
//  FaceCar
//
//  Created by facecar on 9/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWarningNofifycationView.h"

@interface FCWarningNofifycationView ()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIView *menuActionView;
@property (weak, nonatomic) IBOutlet FCButtonNext *btnAgree;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consCancelHeight;


@end

@implementation FCWarningNofifycationView {
    void (^_buttonClickCallback) (NSInteger);
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    self.btnAgree.hidden = YES;
    self.btnCancel.hidden = YES;
}


- (void) show:(UIView *)inview
        image:(UIImage *)img
        title:(NSString *)title
      message:(NSString *)message {
     self.frame = inview.bounds;
    
    if (title.length > 0) {
        self.lblTitle.text = title;
    }
    self.lblMessage.text = message;
    self.icon.image = img;
    
    // custom layout
    if (self.bgColor) {
        [self setBackgroundColor:self.bgColor];
    }
    if (self.messColor) {
        self.lblMessage.textColor = self.messColor;
    }
    
    if (self.cusframe.size.width != 0) {
        self.frame = self.cusframe;
    }
    
    [inview addSubview:self];
}

- (void) show:(UIView *)inview
        image:(UIImage *)img
        title:(NSString *)title
      message:(NSString *)message
     buttonOK:(NSString *)btnOK
 buttonCancel:(NSString *)btnCancel
     callback:(void (^)(NSInteger))block {
    _buttonClickCallback = block;
    
    self.btnAgree.hidden = btnOK.length == 0;
    self.btnCancel.hidden = btnCancel.length == 0;
    [self.btnAgree setTitle:[btnOK uppercaseString] forState:UIControlStateNormal];
    [self.btnCancel setTitle:btnCancel forState:UIControlStateNormal];
        
    
    [self show:inview
         image:img
         title:title
       message:message];
    
    if (!btnCancel) {
        self.consCancelHeight.constant = 0.0f;
    }
}

- (void) hide {
    CGSize size = UIScreen.mainScreen.bounds.size;
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.frame = CGRectMake(0, size.height, size.width, size.height);
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (IBAction)agreeClicked:(id)sender {
    if (_buttonClickCallback) {
        _buttonClickCallback (FCFCWarningActionOK);
    }
}

- (IBAction)cancelClicked:(id)sender {
    if (_buttonClickCallback) {
        _buttonClickCallback (FCFCWarningActionCancel);
    }
}


@end
