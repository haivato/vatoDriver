//
//  FCWebViewModel.m
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWebViewModel.h"


@implementation FCWebViewModel

- (instancetype) initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        self.url = url;   
    }
    
    return self;
}

- (instancetype) initWithLinkConfigure:(FCLinkConfigure*) url {
    self = [super init];
    if (self) {
        if (url.auth) {
            [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
                @try {
                    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                    [cookieProperties setObject:@"x-access-token" forKey:NSHTTPCookieName];
                    [cookieProperties setObject:token forKey:NSHTTPCookieValue];

                    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
                    self.url = url.url;
                }
                @catch (NSException* e) {
                    DLog(@"Error: %@", e)
                }
            }];
        }
        else {
            self.url = url.url;
        }
    }
    
    return self;
}
@end
