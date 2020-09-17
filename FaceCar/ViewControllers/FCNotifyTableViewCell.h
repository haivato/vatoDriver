//
//  FCNotifyTableViewCell.h
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCNotification.h"

@interface FCNotifyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBody;
@property (weak, nonatomic) IBOutlet UILabel *lblCreated;

- (void) loadData: (FCNotification*) notify;
- (void) loadNewStatus: (FCNotification*) notify;
@end
