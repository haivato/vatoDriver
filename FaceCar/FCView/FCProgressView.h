//
//  FCProgressView.h
//  FaceCar
//
//  Created by facecar on 11/19/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    FCProgressTypeDefault = 0,
    FCProgressTypeAllowInteraction = 1
} FCProgressType;

@interface FCProgressView : UIProgressView

@property (assign, nonatomic) IBInspectable BOOL showOnStart;

- (void) setProgressType: (FCProgressType) type;
- (void) show;
- (void) dismiss;

@end
