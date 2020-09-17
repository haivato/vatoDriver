//
//  CarTypeViewController.h
//  FaceCar
//
//  Created by Vu Dang on 6/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CarTypeDelegate <NSObject>
- (void) didChoosedCarType: (FCMCarType*) type;
@end

@interface CarTypeViewController : UITableViewController
@property(strong, nonatomic) NSMutableArray* listCarType;
@property(strong, nonatomic) id <CarTypeDelegate> delegate;
@end
