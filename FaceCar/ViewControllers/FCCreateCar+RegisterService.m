    //
//  TripMapsViewController+FoodDelivery.m
//  FC
//
//  Created by vato. on 2/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

#import "FCCreateCar+RegisterService.h"

@implementation FCCreateCarViewController (RegisterService)

- (void)showFoodReceivePackage: (FCUCar*) car{
    self.rsListServicePackageObjcWrapper = [[RSListServiceObjcWrapper alloc] initWith:self];
    self.rsListServicePackageObjcWrapper.listener = self;
    [self.rsListServicePackageObjcWrapper moveToRSListServiceWithCar:car];
}

- (void)didSelectAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
