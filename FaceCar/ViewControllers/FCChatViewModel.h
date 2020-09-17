//
//  FCChatViewModel.h
//  FaceCar
//
//  Created by facecar on 3/1/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCChat.h"
#import "FCBooking.h"

@interface FCChatViewModel : NSObject

@property (strong, nonatomic) FCBooking* booking;
@property (strong, nonatomic) FCChat* chat;
@property (assign, nonatomic) NSInteger noChats;
@property (strong, nonatomic) NSMutableArray* listChats;

- (void) startChat;

- (FCChat*) sendMessage: (NSString*) message;

- (void) getAllChat: (void (^)(NSMutableArray* chats)) handler;
- (void) listenerNewMessage: (void (^)(FCChat* chat)) handler;

@end
