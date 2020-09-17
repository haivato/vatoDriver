//
//  FCLoaderView.h
//  FaceCar
//
//  Created by facecar on 11/28/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCLoaderView : UIView
- (void) start: (void (^) (void)) completed;
@end
