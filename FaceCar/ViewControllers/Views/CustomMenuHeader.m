//
//  CustomMenuHeader.m
//  FC
//
//  Created by Son Dinh on 4/30/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "CustomMenuHeader.h"
#import "MenusTableViewController.h"
#import "KYDrawerController.h"
#import "FCWebViewController.h"
#import <SDWebImage/SDWebImage.h>

@interface CustomMenuHeader()
{
    void (^_profileCallback)(void);
    void (^_pageIdCallback)(FCLinkConfigure*);
    void (^_pageSummaryBonusCallback)(FCLinkConfigure*);
    void (^_licenseCallback)(void);
}
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIButton *btnPageID;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consNameY;
@property (weak, nonatomic) IBOutlet UIView *summaryBonusView;
@property (weak, nonatomic) IBOutlet UILabel *lblSummaryBonus;

@end

@implementation CustomMenuHeader

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProfileUpdated) name:NOTIFICATION_PROFILE_UPDATED object:nil];
}

- (void) onProfileUpdated {
    self.homViewModel.driver = [UserDataHelper shareInstance].getCurrentUser;
}

- (void)didMoveToSuperview
{
    [self load];
}

- (void) load
{
    [RACObserve(self.homViewModel, driver) subscribeNext:^(FCDriver* driver) {
        if (driver) {
            //avatar
            self.avatar.backgroundColor = [UIColor whiteColor];
            [self.avatar sd_setImageWithURL:[NSURL URLWithString:driver.user.avatarUrl] placeholderImage:[UIImage imageNamed:@"ic_register_default_avatar"]];
            self.avatar.layer.cornerRadius = self.avatar.frame.size.height /2;
            self.avatar.layer.masksToBounds = YES;
            self.avatar.layer.borderWidth = 0;
            
            //label
            [self.labelName setText:driver.user.fullName];
        }
    }];
    
    // page id
    {
        FCLinkConfigure* link = [self getPageIDLink];
        if (link) {
            [self.btnPageID setTitle:link.name forState:UIControlStateNormal];
        }
        else {
            self.consNameY.constant = 0;
        }
    }
    
    // page summary bonus
    {
        FCLinkConfigure* link = [self getSummaryBonusLink];
        if (link) {
            [self.summaryBonusView setHidden:NO];
            self.lblSummaryBonus.text = link.name;
        }
        else {
            [self.summaryBonusView setHidden:YES];
        }
    }
}

- (IBAction)onUpdateAvatar:(id)sender
{
    DLog(@"onUpdateAvatar")
    if (_profileCallback != nil)
    {
        _profileCallback();
    }
    
}
- (IBAction)onPageIDClicked:(id)sender {
    if (_pageIdCallback) {
        _pageIdCallback([self getPageIDLink]);
    }
}

- (IBAction)onSummaryClicked:(id)sender {
    if (_pageSummaryBonusCallback) {
        _pageSummaryBonusCallback([self getSummaryBonusLink]);
    }
}

- (FCLinkConfigure*) getPageIDLink {
    NSArray* links = [FirebaseHelper shareInstance].appConfigure.app_link_configure;
    for (FCLinkConfigure* link in links) {
        if (link.active && link.type == LinkConfigureTypeIDPage) {
            return link;
        }
    }
    
    return nil;
}

- (FCLinkConfigure*) getSummaryBonusLink {
    NSArray* links = [FirebaseHelper shareInstance].appConfigure.app_link_configure;
    for (FCLinkConfigure* link in links) {
        if (link.active && link.type == LinkConfigureTypeSummaryBonusPage) {
            return link;
        }
    }
    
    return nil;
}

- (void)setProfileClickCallback:(void (^)(void))callback
{
    _profileCallback = callback;
}

- (void) setPageIDClickCallback:(void (^)(FCLinkConfigure *))callback {
    _pageIdCallback = callback;
}

- (void) setPageSummaryBonusClickCallback:(void (^)(FCLinkConfigure *))callback {
    _pageSummaryBonusCallback = callback;
}


@end
