//
//  FCButton.h
//  FaceCar
//
//  Created by facecar on 11/19/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCButton.h"

@interface FCButtonNext : FCButton

@property (assign, nonatomic) IBInspectable BOOL isEnable;
@property (assign, nonatomic) IBInspectable BOOL isLoadingWhenPress;

- (void) setHidden:(BOOL)hidden;
- (void) setEnabled:(BOOL)enabled;
- (void) loadingProgress;
- (void) dismissProcess;

@end
