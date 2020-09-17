//
//  NSString+MD5.m
//  FC
//
//  Created by Son Dinh on 4/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)MD5String {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

- (NSInteger)javaHashCode
{
    int h = 0;
    if (h == 0 && self.length > 0) {
        for (int i = 0; i < self.length; i++) {
            h = 31 * h + [self characterAtIndex:i];
        }
    }
    return abs(h);
}

@end
