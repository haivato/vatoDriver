//
//  NavigatorHelper.m
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "NavigatorHelper.h"

@implementation NavigatorHelper

static NavigatorHelper* instance = nil;
+ (NavigatorHelper*) shareInstance {
    if (instance == nil) {
        instance = [[NavigatorHelper alloc] init];
    }
    return instance;
}

- (UIStoryboard*) getStoryboardByName:(NSString *)name {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:name
                                                             bundle: nil];
    return mainStoryboard;
}

- (UIViewController*) getViewControllerById:(NSString *)viewId inStoryboard: (NSString*) sbName{
    UIStoryboard* mainStoryboard = [self getStoryboardByName:sbName];
    UIViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: viewId];
    return controller;
}

@end
