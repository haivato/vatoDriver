//
//  FCMService.m
//  FC
//
//  Created by facecar on 6/5/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCMService.h"

@implementation FCMService

- (FCMService *)clone {
    FCMService *service = [[FCMService alloc] init];
    service.serviceId = self.serviceId;
    service.rank = self.rank;
    service.type = self.type;
    service.name = self.name;
    service.displayName = self.displayName;
    service.active = self.active;
    service.enable = self.enable;
    service.transport = self.transport;
    service.force = self.force;
    return service;
}
@end
