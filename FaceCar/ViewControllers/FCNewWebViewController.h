//
//  FCNewWebViewController.h
//  FC
//
//  Created by facecar on 6/13/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TopupLinkConfigureProtocol;
@interface FCNewWebViewController : UIViewController
- (void) loadWebview: (NSString *_Nullable) url;
- (void) loadWebviewWithConfigure:(id<TopupLinkConfigureProtocol>_Nullable) url;
@end
NS_ASSUME_NONNULL_END
