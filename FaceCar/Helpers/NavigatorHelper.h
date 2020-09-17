//
//  NavigatorHelper.h
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigatorHelper : NSObject

+ (NavigatorHelper*) shareInstance;

- (UIViewController*) getViewControllerById:(NSString *)viewId inStoryboard: (NSString*) sbName;

@end
