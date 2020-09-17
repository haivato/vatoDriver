//
//  FirebasePushHelper.h
//  FaceCar
//
//  Created by facecar on 3/12/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIHelper.h"

@interface FirebasePushHelper : NSObject

+ (void) sendPushTo: (NSString*) destination
               type: (NSInteger) pushtype
              title: (NSString*) title
           message : (NSString*) message;

@end
