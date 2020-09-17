//
//  FCChatView.h
//  FaceCar
//
//  Created by facecar on 2/27/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCView.h"
#import "FCChatViewModel.h"

@interface FCChatView : FCView

@property (strong, nonatomic) FCChatViewModel* chatViewModel;
@property (assign, nonatomic) BOOL ishidden;
@property (strong, nonatomic) FCClient* client;

- (void) bindingData;

@end
