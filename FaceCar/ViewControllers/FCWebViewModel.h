//
//  FCWebViewModel.h
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCWebViewModel : NSObject

@property (strong, nonatomic) NSString* url;

- (instancetype) initWithUrl: (NSString*) url;

- (instancetype) initWithLinkConfigure: (FCLinkConfigure *)url;

@end
