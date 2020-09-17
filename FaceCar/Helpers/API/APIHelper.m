//
//  APIHelper.m
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "APIHelper.h"
#import "AFHTTPSessionManager+Helper.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "FCNotifyBannerView.h"
#import "KYDrawerController.h"

#define kRequestTimeout 180.0f
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif
@import FirebaseAnalytics;
@implementation APIHelper {
    NSURLSessionDataTask* _currentRequest;
}

static APIHelper* instance = nil;
+ (APIHelper*) shareInstance {
    if (!instance) {
        instance = [[APIHelper alloc] init];
    }
    
    return instance;
}

- (void) cancelCurrentRequest {
    if (_currentRequest) {
        [_currentRequest cancel];
    }
}

- (void) get: (NSString*) url
      params: (id) params
    complete:(void (^)(FCResponse *res, NSError *error))block {
    [[UserDataHelper shareInstance] getAuthToken:^(NSString * token, NSError * error) {
        if (error || [token length] == 0) {
            [FIRAnalytics logEventWithName:@"token_user_not_found"
                                parameters:@{@"url": url ?: @"",
                                             @"reason": error.localizedDescription?: @"",
                                             @"token": token ?: @""}];
            if (block) {
                block(nil, error);
            }
            return;
        }
        
        if (!error && token.length > 0) {
            [self call:url
                method:METHOD_GET
                params:params
                 token:token
        headerTokenKey:@"x-access-token"
              complete:block];
        }
    }];
}

- (void) post: (NSString*) url
         body:(id) params
     complete:(void (^)(FCResponse *res,NSError *error))block{
    
    [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (error || [token length] == 0) {
            if (block) {
                block(nil, error);
            }
            return;
        }
        
        if (!error && token.length > 0) {
            [self call:url
                method:METHOD_POST
                params:params
                 token:token
        headerTokenKey:@"x-access-token"
              complete:block];
        }
    }];
}

- (void) call: (NSString*) url
       method: (NSString*) method
       params: (id) params
        token: (NSString*) token
headerTokenKey: (NSString*) key
     complete: (void (^)(FCResponse* response, NSError *error)) handler {
    NSString *text = @"";
    if (params) {
        text = [NSString stringWithFormat:@"params: %@ token: %@, header: %@", params, token, key];
    }
    [FIRAnalytics logEventWithName:@"call_api"
                        parameters:@{@"url": url ?: @"",
                                     @"method": method , @"params": text }];
    [self call:url
        method:method
        params:params
         token:token
headerTokenKey:key
       handler:^(NSError *error, id response) {
           if (error) {
               [FIRAnalytics logEventWithName:@"call_api_fail"
                                   parameters:@{@"url": url ?: @"",
                                                @"reason": error.localizedDescription}];
               if (handler) {
                   handler(nil, error);
               }
               return;
           }
           
           @try {
               FCResponse* res = [[FCResponse alloc] initWithDictionary:response
                                                                  error:nil];
               [FIRAnalytics logEventWithName:@"call_api_success"
                                   parameters:@{@"url": url ?: @""}];
               if (handler) {
                   handler(res, nil);
               }
               
               if (res && res.status && res.status != APIStatusOK) {
                   if (res.status == APIStatusAccountBanned) {
                       [self showMessageError:@"Tài khoản của bạn đang bị tạm khoá truy cập. Bạn vui lòng quay lại sau."];
                   }
                   else if (res.status == APIStatusAccountSpam) {
                       [self showMessageError:@"Hiện tại bạn đang thao tác quá nhanh. Vui lòng kiểm tra thao tác và thử lại sau."];
                   }
                   else {
                       [self showMessageError:res.message];
                   }
               }
           }
           @catch (NSException* e) {
               NSError *err = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:e.userInfo];
               if (handler) {
                   handler(nil, err);
               }
               
               DLog(@"Error: %@", e);
           }
       }];
}

- (AFHTTPSessionManager*) getSessionManager:(NSString*) url
                                      token: (NSString*) token {
    AFHTTPSessionManager *manager;
    if ([url containsString:@"api.vato"]) {
        NSString* host = [NSString stringWithFormat:@"https://%@", [NSURL URLWithString:url].host];
        manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:host]];
        AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
        [policy setAllowInvalidCertificates:NO];
        [policy setValidatesDomainName:YES];
        manager.securityPolicy = policy;
        
        // optional
        NSString *pathToCert =  [[NSBundle mainBundle]pathForResource:@"*.vato.vn" ofType:@"cer"];
        NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
        manager.securityPolicy.pinnedCertificates = [NSSet setWithArray:@[localCertificate]];
    }
    else {
        manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (token.length > 0) {
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"x-access-token"];
    }
    [manager.requestSerializer setTimeoutInterval:kRequestTimeout];
    
    return manager;
}

- (RACSignal *)call: (NSString*) url
             method: (NSString*) method
             params: (id) params
              token: (NSString*) token
     headerTokenKey: (NSString*) key {
    
    NSDictionary *temp = [NSDictionary castFrom:params];
    if (![url containsString:HOST_MAP] && (temp || params == nil)) {
        
        url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", HOSTV2] withString:@""];
        url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", HOSTV3] withString:@""];
        
        NSDictionary *header = @{
                                 @"Content-Type": @"application/json",
                                 @"x-app-version": [self getAppVersion],
                                 @"x-app-id": [[NSBundle mainBundle] bundleIdentifier],
                                 @"x-platform": @"ios",
                                 @"x-device-id": [self getDeviceId]
                                 };
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[RequesterObjc instance] requestWithToken:token
                                                  path:url
                                                method:method
                                                header:header
                                                params:params
                                         trackProgress:NO
                                               handler:^(NSDictionary<NSString *,id> * _Nullable responseData, NSError * _Nullable error) {
                                                   if (error) {
                                                       [subscriber sendError:error];
                                                   } else {
                                                       [subscriber sendNext:responseData];
                                                       [subscriber sendCompleted];
                                                       
                                                   }
                                                   
                                               }];
            return nil;
        }];
    } else {
        DLog(@"Request:%@\n Token: %@\nParams: %@", url, token, params);
        AFHTTPSessionManager* manager  = [self getSessionManager:url token:token];
        if ([key length] > 0) {
            [manager.requestSerializer setValue:token forHTTPHeaderField:key];
        }
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:[self getAppVersion] forHTTPHeaderField:@"x-app-version"];
        [manager.requestSerializer setValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"x-app-id"];
        [manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"x-platform"];
        [manager.requestSerializer setValue:[self getDeviceId] forHTTPHeaderField:@"x-device-id"];
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSURLSessionDataTask *task = [manager request:url
                                                   method:method
                                               parameters:params
                                                  success:^(id responseData) {
                                                      DLog(@"[Response] %@", responseData);
                                                      [subscriber sendNext:responseData];
                                                      [subscriber sendCompleted];
                                                  }
                                                  failure:^(id responseObject, NSError* error) {
                                                      DLog(@"error: %@", error);
                                                      [subscriber sendError:error];
                                                  }];
            return [RACDisposable disposableWithBlock:^{
                if ([task state] == NSURLSessionTaskStateRunning) {
                    [task cancel];
                }
            }];
        }];
    }
    
}

- (void) call: (NSString*) url
       method: (NSString*) method
       params: (id) params
        token: (NSString*) token
headerTokenKey: (NSString*) key
     handler: (void (^)(NSError* error, id response)) block {
    [[self call:url method:method params:params token:token headerTokenKey:key] subscribeNext:^(id responseData) {
        if (block) {
            block(nil, responseData);
        }
    } error:^(NSError *error) {
        if (block) {
            block(error, nil);
        }
    }];
    
}

- (void) showMessageError: (NSString*) errorMessage {
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController* vc = [app visibleViewController:app.window.rootViewController];
    if (![vc isKindOfClass:[HomeViewController class]] && ![vc isKindOfClass:[KYDrawerController class]]) {
        NSString* mess = [self getErrorMessage:errorMessage];
        if (mess.length > 0) {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeError
                                     autoHide:YES
                                      message:mess
                                   closeClick:nil
                                  bannerClick:nil];
        }
        else {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeError
                                     autoHide:YES
                                      message:@"Bạn vui lòng quay lại sau.\nHoặc liên hệ tổng đài để được hỗ trợ!"
                                   closeClick:nil
                                  bannerClick:^{
                                      [self callPhone:PHONE_CENTER];
                                  }];
        }
    }
}

- (NSString*) getErrorMessage: (NSString*) errorCode {
    if ([errorCode containsString:@"WrongOldPinException"]) {
        return @"Mật khẩu hiện tại không đúng. Vui lòng thử lại.";
    }
    if ([errorCode containsString:@"WrongResetTokenException"]) {
        return @"Mã bảo mật không đúng. Bạn vui lòng kiểm tra và thử lại.";
    }
    if ([errorCode containsString:@"UserNotExistedException"]) {
        return @"Tài khoản này không tồn tại. Bạn vui lòng kiểm tra và thử lại.";
    }
    if ([errorCode containsString:@"CantVerifyPinException"]) {
        return @"Mật khẩu thanh toán không đúng. Bạn vui lòng kiểm tra và thử lại.";
    }
    if ([errorCode containsString:@"TooMuchWithdrawOrderException"]) {
        return @"Vui lòng chờ hoàn tất các yêu cầu rút tiền trước đó của bạn trước khi tiếp tục.";
    }
    if ([errorCode containsString:@"TransferPermissionNotFoundException"]) {
        return @"Bạn chưa có quyền thực hiện chức năng này. Vui lòng quay lại sau.";
    }
    
    return errorCode;
}

@end
