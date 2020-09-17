//
//  XOREncryption.m
//  FC
//
//  Created by facecar on 6/18/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "XOREncryption.h"

@implementation XOREncryption
+(NSString *) encryptDecrypt:(NSString *)input {
    unichar key[] = {'V', 'A', 'T', 'O', '@', '2', '0', '1', '8'}; //Can be any chars, and any size array
    NSMutableString *output = [[NSMutableString alloc] init];
    
    for(int i = 0; i < input.length; i++) {
        unichar c = [input characterAtIndex:i];
        c ^= key[i % (sizeof(key)/sizeof(unichar))];
        [output appendString:[NSString stringWithFormat:@"%x", c]];
    }
    
    return output;
}
@end
