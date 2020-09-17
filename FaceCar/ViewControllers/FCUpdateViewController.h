//
//  FCUpdateViewController.h
//  FaceCar
//
//  Created by facecar on 6/18/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCViewController.h"

@interface FCUpdateViewController : FCViewController
@property (assign, nonatomic) UpdateViewType type;
@property (strong, nonatomic) NSString* result;
@end
