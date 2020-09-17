//
//  FCNotifyTableViewCell.m
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCNotifyTableViewCell.h"

@implementation FCNotifyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) loadData:(FCNotification*) notify {
    [self.lblTitle setText:notify.title];
    [self.lblBody setText:notify.body];
    [self.lblCreated setText:[self getTimeString:notify.createdAt]];
    
    [self loadNewStatus:notify];
}

- (void) loadNewStatus: (FCNotification*) notify {
    [self setBackgroundColor:[UIColor whiteColor]];
}

@end
