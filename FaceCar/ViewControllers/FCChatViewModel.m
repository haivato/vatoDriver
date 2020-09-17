//
//  FCChatViewModel.m
//  FaceCar
//
//  Created by facecar on 3/1/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCChatViewModel.h"
#import "FirebasePushHelper.h"

@implementation FCChatViewModel

- (id) init {
    self = [super init];
    if (self) {
        self.listChats = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) startChat {
    [self getAllChat:^(NSMutableArray *chats) {
        
    }];
    
    [self listenerNewMessage:^(FCChat *chat) {
        
    }];
}

- (FCChat*) sendMessage:(NSString *)message {
    FCChat* chat = [[FCChat alloc] init];
    chat.message = message;
    chat.sender = [NSString stringWithFormat:@"d~%ld",_booking.info.driverUserId];
    chat.receiver = [NSString stringWithFormat:@"c~%ld",_booking.info.clientUserId];
    chat.id = [self getCurrentTimeStamp];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:[chat toDictionary]];
    [dict addEntriesFromDictionary:@{@"time":[FIRServerValue timestamp]}];
    FIRDatabaseReference* ref = [[[FirebaseHelper shareInstance].ref
                                  child:TABLE_CHATS]
                                 child:_booking.info.tripId].childByAutoId;
    [ref setValue:dict];
    [self.listChats insertObject:chat
                         atIndex:0];
    [self sendPushForChat:chat];
    return chat;
}

- (void) sendPushForChat: (FCChat*) chat {
    [[FirebaseHelper shareInstance] getClient:self.booking.info.clientFirebaseId
                                      handler:^(FCClient * client) {
                                          if (client.deviceToken.length > 0) {
                                              [FirebasePushHelper sendPushTo:client.deviceToken
                                                                        type:NotifyTypeChatting
                                                                       title:@"Tin nhắn từ tài xế"
                                                                     message:chat.message];
                                          }
                                      }];
}

- (void) getAllChat:(void (^)(NSMutableArray *))handler {
    FIRDatabaseReference* ref = [[[FirebaseHelper shareInstance].ref
                                  child:TABLE_CHATS]
                                 child:self.booking.info.tripId];
    [ref keepSynced:YES];
    [[ref queryLimitedToLast:100] observeSingleEventOfType:FIRDataEventTypeValue
                                                 withBlock:^(FIRDataSnapshot * snapshot) {
                                                     NSMutableArray* list = [[ NSMutableArray alloc] init];
                                                     for (FIRDataSnapshot* s in snapshot.children) {
                                                         FCChat* chat = [[FCChat alloc] initWithDictionary:s.value
                                                                                                     error:nil];
                                                         if (chat) {
                                                             [list insertObject:chat atIndex:0];
                                                         }
                                                     }
                                                     self.listChats = list;
                                                     handler(list);
                                                 }];
}

- (void) listenerNewMessage:(void (^)(FCChat *))handler {
    FIRDatabaseReference* ref = [[[FirebaseHelper shareInstance].ref
                                  child:TABLE_CHATS]
                                 child:self.booking.info.tripId];
    [ref keepSynced:YES];
    [ref observeEventType:FIRDataEventTypeChildAdded
                withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    FCChat* chat = [[FCChat alloc] initWithDictionary:snapshot.value
                                                                error:nil];
                    for (FCChat* c in self.listChats) {
                        if (c.id == chat.id) {
                            return;
                        }
                    }
                    
                    [self.listChats insertObject:chat
                                         atIndex:0];
                    self.chat = chat;
                    handler(chat);
                }];
}

@end
