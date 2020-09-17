//
//  FCPointView.h
//  FC
//
//  Created by khoi tran on 4/8/20.
//  Copyright © 2020 Vato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCWayPoint.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCPointView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *tripTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

- (void)setupDisplay:(NSString *)address origin:(BOOL) isOrigin;
@end

NS_ASSUME_NONNULL_END
