//
//  FirebasePushHelper.m
//  FaceCar
//
//  Created by facecar on 3/12/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FirebasePushHelper.h"
#import "FirebaseHelper.h"

#define PUSH_URL @"https://fcm.googleapis.com/fcm/send"

@implementation FirebasePushHelper

+ (void) sendPushTo: (NSString*) destination
               type: (NSInteger) pushtype
              title: (NSString*) title
           message : (NSString*) message {
    
    [[FirebaseHelper shareInstance] getAppConfigure:^(FCAppConfigure *appconfigure) {
        if (appconfigure.push_key.length > 0) {
            
            NSDictionary* data = @{@"type": @(pushtype),
                                   @"refer_id": @0};
            NSDictionary* disc = @{@"body" : message,
                                   @"title": title};
            
            NSDictionary* params = @{@"to": destination,
                                     @"priority": @"high",
                                     @"data": data,
                                     @"notification" : disc};
            
            [[APIHelper shareInstance] call:PUSH_URL
                                     method:METHOD_POST
                                     params:params
                                      token:appconfigure.push_key
                             headerTokenKey:@"Authorization"
                                    handler:^(NSError *error, id response) {
                                       
                                    }];
        }
    }];
}

@end
