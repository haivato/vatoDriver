//
//  FCImageView.h
//  FaceCar
//
//  Created by facecar on 12/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCImageView : UIImageView

@property (assign, nonatomic) IBInspectable BOOL isCircle;
@property (assign, nonatomic) IBInspectable NSInteger cornerRadius;

- (void) setImageWithUrl: (NSString*) url;
- (void) setImageWithUrl: (NSString*) url
                  holder: (UIImage*) holder;

@end
