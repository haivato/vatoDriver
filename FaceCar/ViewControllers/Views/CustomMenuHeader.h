//
//  CustomMenuHeader.h
//  FC
//
//  Created by Son Dinh on 4/30/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

@interface CustomMenuHeader : UIView

- (void) setProfileClickCallback:(void(^)(void))callback;
- (void) setPageIDClickCallback:(void(^)(FCLinkConfigure*))callback;
- (void) setPageSummaryBonusClickCallback:(void (^)(FCLinkConfigure *))callback;

@property (strong, nonatomic) FCHomeViewModel* homViewModel;

@end
