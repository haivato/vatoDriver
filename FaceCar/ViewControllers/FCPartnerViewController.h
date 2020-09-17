//
//  FCPartnerViewController.h
//  FC
//
//  Created by facecar on 12/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCPartner.h"
#import "FCPartnerViewModel.h"
#import "FCSupperViewController.h"

@interface FCPartnerViewController : FCSupperViewController

@property (strong, nonatomic) FCPartnerViewModel* viewModel;
@property (strong, nonatomic) FCPartner* partnerSelected;

@end
