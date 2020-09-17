//
//  FCErrorNofifycationView.h
//  FaceCar
//
//  Created by facecar on 9/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FCWarningAction) {
    FCFCWarningActionOK = 0, // OK
    FCFCWarningActionCancel = 1 // cancel
};

@interface FCWarningNofifycationView : FCView
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) UIColor* bgColor;
@property (strong, nonatomic) UIColor* messColor;
@property (assign, nonatomic) CGRect cusframe;

- (void) show: (UIView*) inview
        image: (UIImage*) img
        title: (NSString*) title
      message: (NSString*) message;

- (void) show: (UIView*) inview
        image: (UIImage*) img
        title: (NSString*) title
      message: (NSString*) message
     buttonOK: (NSString*) btnOK
 buttonCancel: (NSString*) btnCancel
     callback: (void (^)(NSInteger buttonIndex)) block;

@end
