//
//  MarkerInfoInTrip.h
//  FaceCar
//
//  Created by vudang on 2/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkerInfoInTrip : UIView

@property (weak, nonatomic) IBOutlet UILabel *title;

- (instancetype) initialize;
- (void) loadTitle: (NSString*) duration;
@end
