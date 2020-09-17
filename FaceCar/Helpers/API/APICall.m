//
//  AFNetworkingHelper.m
//  FaceCar
//
//  Created by Vu Dang on 7/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "APICall.h"
#import <AFNetworking/AFNetworking.h>
#import "FCInvoice.h"
#import "FCTripHistory.h"
#import "AppDelegate.h"
#import "APIHelper.h"
#import "FCLoginViewModel.h"
#import "FCWithdrawHistory.h"
#import "FCNotifyBannerView.h"
#import "FCBalance.h"
#import "FCFareSetting.h"
#import "FCFareModifier.h"
#import "FCFarePredicate.h"


@implementation APICall

static APICall* instance = nil;
+ (APICall*) shareInstance {
    if (instance == nil) {
        instance = [[APICall alloc] init];
    }
    return instance;
}

- (void) apiGetRefferalCodeWithComplete:(void (^)(NSString*)) completed {
    NSDictionary* params = [NSDictionary dictionaryWithObject:@1 forKey:@"eventId"];
    [[APIHelper shareInstance] get:API_GET_REFERAL_CODE
                            params:params
                          complete:^(FCResponse *response, NSError *e) {
                              
                          }];
}

- (void) apiVerifyRefferalCode :(NSString*) code withComplete:(void (^)(NSString*, BOOL)) completed {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjects:@[code, @1] forKeys:@[@"code", @"eventId"]];
    [[APIHelper shareInstance] post:API_VERIFY_REFERAL_CODE
                               body:params
                           complete:^(FCResponse *response, NSError *e) {
                               
                           }];
    
}

- (void) apiGetInvoicesList:(NSDictionary*) params block:(void (^)(NSArray* list, BOOL more)) completed {
    [[APIHelper shareInstance] get:API_GET_INVOICE
                               params:params
                           complete:^(FCResponse *response, NSError *e) {
                               @try {
                                   NSMutableArray* list = [[NSMutableArray alloc] init];
                                   NSArray* datas = [response.data objectForKey:@"transactions"];
                                   BOOL more = [[response.data objectForKey:@"more"] boolValue];
                                   for (id item in datas) {
                                       FCInvoice* invoice = [[FCInvoice alloc] initWithDictionary:item error:nil];
                                       if (invoice) {
                                           [list addObject:invoice];
                                       }
                                   }
                                   if (completed) {
                                       completed(list, more);
                                   }
                               }
                               @catch (NSException* e) {
                                   DLog(@"Error: %@", e);
                                   
                                   if (completed) {
                                       completed(nil, NO);
                                   }
                               }
                               
    }];
}

- (void) apiGetWithdrawHistoryList:(NSDictionary*) params block:(void (^)(NSArray* list, BOOL more)) completed {
    [[APIHelper shareInstance] get:API_GET_WITHDRAW_ORDER
                            params:params
                          complete:^(FCResponse *response, NSError *e) {
                              @try {
                                  NSMutableArray* list = [[NSMutableArray alloc] init];
                                  NSArray* datas = [response.data objectForKey:@"withdrawOrders"];
                                  BOOL more = [[response.data objectForKey:@"more"] boolValue];
                                  for (id item in datas) {
                                      FCWithdrawHistory* invoice = [[FCWithdrawHistory alloc] initWithDictionary:item error:nil];
                                      if (invoice) {
                                          [list addObject:invoice];
                                      }
                                  }
                                  if (completed) {
                                      completed(list, more);
                                  }
                              }
                              @catch (NSException* e) {
                                  DLog(@"Error: %@", e);
                                  
                                  if (completed) {
                                      completed(nil, NO);
                                  }
                              }
                          }];
}

- (void) apiGetTripListFromDay:(double)fromTimestamp toDay:(double)toTimestamp block:(void (^ _Nullable)(NSArray * _Nullable, NSInteger, NSInteger))completed
{
    NSDictionary* body = @{@"from": @((NSInteger) fromTimestamp),
                           @"to": @((NSInteger) toTimestamp),
                           @"page": @0,
                           @"size": @10};
    
    [[APIHelper shareInstance] get:API_GET_TRIP_DAY
                            params:body
                          complete:^(FCResponse *response, NSError *e) {
                              @try {
                                  NSMutableArray* list = [[NSMutableArray alloc] init];
                                  NSDictionary *data = response.data;
                                  NSArray* datas = [data objectForKey:@"trips"];
                                  for (id item in datas) {
                                      NSError* err;
                                      FCTripHistory* invoice = [[FCTripHistory alloc] initWithDictionary:item error:&err];
                                      if (invoice) {
                                          [list addObject:invoice];
                                      }
                                  }
                                  completed(list, 0, 0);
                              }
                              @catch (NSException* e) {
                                  DLog(@"Error: %@", e);
                              }
                              
                          }];
}


- (void) apiUpdateProfile:(NSString*) email
                 nickname:(NSString*) nickname
                 fullname:(NSString*) fullname
                   avatar:(NSString*) avatar
                  handler:(void (^)(NSError * error)) block {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        return;
    }
    
    NSString* phone = user.phoneNumber;
    if ([phone hasPrefix:@"+84"]) {
        phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
    }
    
    FCDriver* driver = [UserDataHelper shareInstance].getCurrentUser;
    
    NSString* uid = user.uid;
    NSMutableDictionary* body = [[NSMutableDictionary alloc] init];
    [body addEntriesFromDictionary:@{@"isDriver":@(YES),
                                     @"phoneNumber":phone,
                                     @"firebaseId":uid}];
    if (email.length > 0) {
        driver.user.email = email;
        [body addEntriesFromDictionary:@{@"email":email}];
    }
    if (nickname.length > 0) {
        driver.user.nickname = nickname;
        [body addEntriesFromDictionary:@{@"nickname":nickname}];
    }
    if (fullname.length > 0) {
        driver.user.fullName = fullname;
        [body addEntriesFromDictionary:@{@"fullName":fullname}];
    }
    if (avatar.length > 0) {
        driver.user.avatarUrl = avatar;
        [body addEntriesFromDictionary:@{@"avatarUrl":avatar}];
    }
    
    [[APIHelper shareInstance] post:API_UPDATE_ACCOUNT
                               body:body
                           complete:^(FCResponse *response, NSError *e) {
                               if (block) {
                                   block(nil);
                               }
                           }];
    
    [[UserDataHelper shareInstance] saveUserToLocal:driver];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROFILE_UPDATED
                                                        object:nil];
}

- (void) checkingNetwork {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == 0) {
            DLog("LOST CONNECTION")
            [self showMessageBanner:@"Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra và thử lại"
                             status:NO];
        }
        else {
            DLog("HAVE CONNECTION")
            [[NSNotificationCenter defaultCenter] postNotificationName:NotifyNetWorkStatus object:nil];
        }
    }];
}

- (void) apiSigOut {
    [[APIHelper shareInstance] post:API_LOGOUT
                               body:nil
                           complete:^(FCResponse *response, NSError *e) {
                               
                           }];
}


+ (void) apiGetMyBalance:(void (^)(FCBalance *))block {
    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_GET_BALANCE
                            params:nil
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                              @try {
                                  FCBalance* balance = [[FCBalance alloc] initWithDictionary:response.data
                                                                                       error:nil];
                                  if (balance) {
                                      block(balance);
                                  }
                                  else {
                                      block(nil);
                                      [[FCNotifyBannerView banner] show:nil
                                                                forType:FCNotifyBannerTypeError
                                                               autoHide:YES
                                                                message:@"Xảy ra lỗi, bạn vui lòng quay lại sau."
                                                             closeClick:nil
                                                            bannerClick:nil];
                                  }
                              }
                              @catch (NSException* e) {
                                  DLog(@"Error: %@", e)
                              }
                          }];
}

- (void)apiFareSettingsWithCoordinate:(CLLocationCoordinate2D)coordinate complete:(void(^_Nonnull)(NSArray<FCFareSetting*> *fareSettings, NSArray<FCFarePredicate*> *farePredecates, NSArray<FCFareModifier*> *fareModifiers, NSError *error))complete {
    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_FARE_SETTINGS
                            params:@{@"origin":[NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude], @"v":@"2"}
                          complete:^(FCResponse *response, NSError *e) {
                              [IndicatorUtils dissmiss];
                              NSDictionary *info = [NSDictionary castFrom:response.data];
                              if (!info) {
                                  NSInteger status = response.status;
                                  NSError * err = [NSError errorWithDomain:@"vn.vato.driver" code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"Invalid data return", @"status": @(status)}];
                                  complete(nil, nil, nil, err);
                                  return;
                              }

                              NSError *error;
                              NSArray *fareSettings = [FCFareSetting arrayOfModelsFromDictionaries:(NSArray*)info[@"settings"] error:&error];
                              NSArray *farePredecates = [FCFarePredicate arrayOfModelsFromDictionaries:(NSArray*)info[@"predicates"] error:&error];
                              NSArray *fareModifiers = [FCFareModifier arrayOfModelsFromDictionaries:(NSArray*)info[@"modifiers"] error:&error];

                              if (!error) {
                                  complete(fareSettings, farePredecates, fareModifiers, nil);
                              } else {
                                  complete(nil, nil, nil, error);
                              }
                          }];
}

@end
