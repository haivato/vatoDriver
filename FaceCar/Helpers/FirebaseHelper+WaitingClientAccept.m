//
//  FirebaseHelper+WaitingClientAccept.m
//  FC
//
//  Created by Dung Vu on 9/23/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "FirebaseHelper+WaitingClientAccept.h"
#import "FCBookCommand.h"

@implementation FirebaseHelper (WaitingClientAccept)
- (RACSignal *)trackAcceptClient:(FCBooking *)book timeout:(NSTimeInterval)timeout {
    NSString *tripId = book.info.tripId;
    if ([tripId length] == 0) {
        
        return [RACSignal empty];
    }
    
    NSArray *commands = book.command;
    // Check commands had client accept
    if ([commands count] > 0) {
        for (FCBookCommand *command in commands) {
            if (command.status == BookStatusClientAgreed) {
                return [RACSignal return:command];
            }
        }
    }
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        FIRDatabaseReference *refTrip = [[FirebaseHelper shareInstance].ref child:TABLE_BOOK_TRIP];
        FIRDatabaseReference* ref;
        FIRDatabaseHandle handler = -1;
        @try {
            ref = [[refTrip child:tripId] child:@"command"];
            handler = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                NSError *e;
                FCBookCommand* stt = [[FCBookCommand alloc] initWithDictionary:snapshot.value error:&e];
                if (e) {
                    NSLog(@"%@", [e localizedDescription]);
                } else {
                    if (stt && stt.status == BookStatusClientAgreed) {
                        [subscriber sendNext:stt];
                        [subscriber sendCompleted];
                    } else {
                        return;
                    }
                }
            } withCancelBlock:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
        } @catch (NSException *exception) {
            NSError *e = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{ NSLocalizedDescriptionKey: exception ?: @""}];
            [subscriber sendError: e];
        } @finally {}
        return [RACDisposable disposableWithBlock:^{
            if (handler != -1 && ref) {
                [ref removeObserverWithHandle:handler];
            }
        }];
    }] timeout:timeout onScheduler:[RACScheduler mainThreadScheduler]];
}
@end
