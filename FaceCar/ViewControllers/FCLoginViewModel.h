//
//  FCLoginViewModel.h
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, FCLoginResultCode) {
    FCLoginResultCodeUnKnow = 0,
    FCLoginResultCodeCredentialAlreadyInUse = 1,
    
    FCLoginResultCodeVerifyPhoneUnknowError = 1000,
    FCLoginResultCodeVerifyPhoneSuccess = 1001,
    FCLoginResultCodeVerifyPhoneFailed = 1002,

    FCLoginResultCodeVerifySMSCodeUnknowError = 2000,
    FCLoginResultCodeVerifySMSCodeSuccess = 2001,
    FCLoginResultCodeVerifySMSCodeInvalid = 2002,
    FCLoginResultCodeVerifySMSCodeExpireSession = 2003,
    
    FCLoginResultCodePrivacyAccepted = 4001,
    
    FCLoginResultCodeCreateUserInfoFailed = 5001,
    FCLoginResultCodeRegisterAccountCompelted = 50002,
    
    FCLoginResultCodeSocialCheckingFailure = 6000,
    FCLoginResultCodeSocialLinkedToPhone = 6001,
    FCLoginResultCodeSocialNotLinkedToPhone = 60002,
    
    FCLoginResultCodeBackendVerifyFailed = 70000
};

typedef NS_ENUM(NSInteger, FCLoginType) {
    FCLoginTypeSignIn = 0,
    FCLoginTypeChangePhone = 1
};

@interface FCLoginViewModel : NSObject

@property (strong, nonatomic) UIViewController* viewController;
@property (strong, nonatomic) NSString* phoneNumber;
@property (strong, nonatomic) NSString* smsCode;
@property (assign, nonatomic) FCLoginResultCode resultCode;
@property (assign, nonatomic) FCLoginType loginType;
@property (strong, nonatomic) FCDriver* driver;
@property (strong, nonatomic) FIRAuthCredential* socialCredential; // facebook or google

- (void) setPhoneNumber:(NSString*)phoneNumber
           andPhoneCode:(NSString*)phoneCode;

- (void) getSMSPasscode: (void (^)(NSError* err)) block;
- (void) verifySMSPassCode: (NSString*) smscode
                     block: (void (^)(NSError* err)) block;


- (void) checkingUserData:(void (^)(FCDriver*)) block;
- (void) createUserInfo: (void (^) (NSError*)) block;
- (void) updateUserInfo:(void (^)(NSError * error)) block;

- (void) checkingSocialAuth: (FIRAuthCredential*) credential
                      block: (void (^)(NSError *)) block; // facebook or google

- (FIRPhoneAuthCredential*) getPhoneCredential;

#pragma mark - APIs
- (void) apiCheckPhone: (void (^) (BOOL success)) handler;
- (void) apiCheckAccout: (void (^) (BOOL success, BOOL isUpdate, FCDriver* driver)) handler;
- (void) apiCreateAccount: (FCDriver*) driver
                  handler: (void (^)(NSError * error)) block;
- (void) apiUpdateAccount: (FCDriver*) driver
                  handler: (void (^)(NSError * error)) block;
@end
