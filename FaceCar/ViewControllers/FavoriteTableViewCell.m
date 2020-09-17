//
//  FavoriteTableViewCell.m
//  FaceCar
//
//  Created by vudang on 2/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FavoriteTableViewCell.h"
#import "UIView+Border.h"

@implementation FavoriteTableViewCell {
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) loadData:(FCFavorite *)fav {
    [self.avatar circleView:[UIColor clearColor]];
    [self.avatar setImageWithURL:[NSURL URLWithString:fav.userAvatar] placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
    [self.lblName setText:fav.userName];
    
    if (fav.isFavorite) {
        [self.icFav setImage:[UIImage imageNamed:@"fav-1"]];
    }
    else {
        [self.icFav setImage:[UIImage imageNamed:@"fav-2"]];
    }
    @try {
        NSString* phone = [fav.userPhone stringByReplacingCharactersInRange:NSMakeRange(fav.userPhone.length-3, 3) withString:@"xxx"];
        self.lblPhone.text = phone;
    }
    @catch (NSException* e) {
    }
    
}

@end
