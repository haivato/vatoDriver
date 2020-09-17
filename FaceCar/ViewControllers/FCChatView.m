//
//  FCChatView.m
//  FaceCar
//
//  Created by facecar on 2/27/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCChatView.h"
#import "PTSMessagingCell.h"
#import "UserDataHelper.h"
#import "FCTextView.h"

#define kcell @"messagingCell"

@interface FCChatView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet FCTextView *inputView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) CGRect originalFrame;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContraintView;

@end

@implementation FCChatView {
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.bottomContraintView.constant = 0;
    [self registerNotification];
    
    _tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void) bindingData {
    [self getListChats];
    [self listenerNewChat];
}

- (void)registerNotification
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterNotification
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    //save current frame
    self.originalFrame = self.frame;
    
    //get root of view hierarchy
    UIView* rootView = self;
    while (rootView.superview) {
        rootView = rootView.superview;
    }
    
    //get keyboard frame
    CGRect keyboardFrame = [rootView convertRect:
                            [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    
    CGRect frameToRootView = [self convertRect:self.bounds toView:rootView];
    
    CGFloat newHeight = rootView.frame.size.height -
    (keyboardFrame.size.height + frameToRootView.origin.y);
    
    //if keyboard and textView doesn't intersect or
    //keyboard covers textView all,
    //no need to resize.
    if (!CGRectIntersectsRect(keyboardFrame, frameToRootView) || newHeight <= 0) {
        return;
    }
    
    CGRect newFrameToRootView = CGRectMake(frameToRootView.origin.x,
                                           frameToRootView.origin.y + 10,
                                           self.frame.size.width, newHeight);
    
    CGRect newFrame = [rootView convertRect:newFrameToRootView toView:self.superview];
    
    CGFloat padding = self.originalFrame.size.height - newFrame.size.height;
    if (padding > 0) {
        [UIView animateWithDuration:[[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            //        self.contentView.frame = newFrame;
            self.bottomContraintView.constant = padding;
            [self layoutIfNeeded];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    self.bottomContraintView.constant = 0;
    [self layoutIfNeeded];
}

#pragma mark - Chats
- (IBAction)sendClicked:(id)sender {
    [self sendChat:self.inputView.text];
    [self.inputView setText:EMPTY];
}

- (void) getListChats {
    [RACObserve(_chatViewModel, listChats) subscribeNext:^(NSMutableArray *chats) {
        if (chats.count > 0) {
            [self reloadTableView];
        }
    }];
}

- (void) sendChat: (NSString*) message {
    if (message.length <= 0)
        return;
    
    if (![self isNetworkAvailable]) {
        [self showMessageBanner:@"Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra lại."
                         status:NO];
    }
    FCChat* chat = [_chatViewModel sendMessage:message];
    [self addNewChat:chat];
}

- (void) listenerNewChat {
    [RACObserve(_chatViewModel, chat) subscribeNext:^(FCChat *chat) {
        if (chat) {
            [self addNewChat:chat];
        }
    }];
}

- (void) addNewChat: (FCChat*) chat {
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                            inSection:0]]
                      withRowAnimation:UITableViewRowAnimationFade];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                      atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark - Tableview

- (void) reloadTableView {
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                      atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatViewModel.listChats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:kcell];
    
    if (cell == nil) {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:kcell];
    }
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    FCChat* chat = [self.chatViewModel.listChats objectAtIndex:indexPath.row];
    [self configureCell:cell chat: chat];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* msg = [[self.chatViewModel.listChats objectAtIndex:indexPath.row] message];
    CGSize messageSize = [PTSMessagingCell messageSize:msg];
    return messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 40.0f;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)configureCell:(id)cell chat:(FCChat *)chat {
    PTSMessagingCell* ccell = (PTSMessagingCell*)cell;
    FCClient* client = self.client;
    NSString* userid = [NSString stringWithFormat:@"d~%ld", (long)[[UserDataHelper shareInstance] getCurrentUser].user.id];
    
    if ([chat.sender isEqualToString:userid]) {
        ccell.sent = YES;
        ccell.avatarImageView.image = [UIImage imageNamed:@"person1"];
        ccell.messageLabel.textColor = [UIColor whiteColor];
        ccell.timeLabel.text = [self getTimeString:chat.time > 0 ? chat.time : chat.id
                                        withFormat:@"HH:mm"];
    }
    else {
        ccell.sent = NO;
        ccell.avatarImageView.image = [UIImage imageNamed:@"avatar-placeholder"];
        ccell.messageLabel.textColor = [UIColor blackColor];
        NSString* avatarUrl = client.photo;

        [ccell.avatarImageView setImageWithURL:[NSURL URLWithString:avatarUrl]
                              placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];

        NSString* displayName = [client.user getDisplayName];
        if (displayName.length > 0) {
            ccell.timeLabel.text = [NSString stringWithFormat:@"%@, %@", displayName, [self getTimeString:chat.time
                                                                                               withFormat:@"HH:mm"]];
        }
        else {
            ccell.timeLabel.text = [NSString stringWithFormat:@"%@", [self getTimeString:chat.time
                                                                              withFormat:@"HH:mm"]];
        }
    }
    
    ccell.messageLabel.text = chat.message;

}

@end
