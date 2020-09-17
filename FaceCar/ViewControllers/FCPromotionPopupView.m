//
//  FCPromotionPopupView.m
//  FC
//
//  Created by tony on 11/19/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCPromotionPopupView.h"
#import "FCManifest.h"
#import "FCManifestPredicate.h"
#import "UIImageView+AFNetworking.h"

@implementation FCPromotionPopupView

- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

- (void) loadPromotionData:(FCManifest *)manifest predicate: (FCManifestPredicate*) predicate {
    _manifest = manifest;
    _predicate = predicate;
    manifest.banner = [manifest.banner stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.imageViewHeader setImageWithURL:[NSURL URLWithString:manifest.banner] placeholderImage:nil];
    self.lblTitle.text = manifest.title;
    self.textviewDescription.text = manifest.description;
    
    if (predicate.type != NotifyTypeLink) {
        [self.stackview removeArrangedSubview:self.btnDetail];
        self.btnDetail.hidden = YES;
    }
}

- (IBAction)closeClicked:(id)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(onPromotionPopupCloseClicked)]) {
        [self.delegate onPromotionPopupCloseClicked];
    }
}

- (IBAction)detailClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onPromotionPopupDetailClicked:predicate:)]) {
        [self.delegate onPromotionPopupDetailClicked:_manifest predicate:_predicate];
    }
    
    [self removeFromSuperview];
}

@end
