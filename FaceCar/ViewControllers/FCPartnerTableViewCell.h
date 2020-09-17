//
//  FCPartnerTableViewCell.h
//  FaceCar
//
//  Created by facecar on 12/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCPartnerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet FCImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@end
