//
//  FCBankingTableViewCell.h
//  FC
//
//  Created by tony on 10/28/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCBankingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblShortName;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end

NS_ASSUME_NONNULL_END
