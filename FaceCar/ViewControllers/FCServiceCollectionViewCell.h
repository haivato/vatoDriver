//
//  FCServiceCollectionViewCell.h
//  FC
//
//  Created by facecar on 7/28/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FCServiceCollectionViewCell;

@protocol FCServiceDelegate
- (void) serviceCell:(FCServiceCollectionViewCell *)sender onChoosed: (BOOL) choose service: (FCMService*) service;
@end

@interface FCServiceCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UISwitch *swChoose;
@property (weak, nonatomic) IBOutlet UILabel *lbRegister;

@property (strong, nonatomic) id<FCServiceDelegate> delegate;
@property (strong, nonatomic) FCMService* service;

@end
