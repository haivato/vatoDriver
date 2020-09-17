//
//  FCPromotionPopupView.h
//  FC
//
//  Created by tony on 11/19/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FCManifest;
@class FCManifestPredicate;
NS_ASSUME_NONNULL_BEGIN

@protocol FCPromotionPopupViewDelegate <NSObject>

- (void) onPromotionPopupCloseClicked;
- (void) onPromotionPopupDetailClicked: (FCManifest*) manifest predicate: (FCManifestPredicate*) predicate;

@end

@interface FCPromotionPopupView : FCView
@property (weak, nonatomic) IBOutlet UIImageView *imageViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextView *textviewDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnDetail;
@property (weak, nonatomic) id<FCPromotionPopupViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIStackView *stackview;

@property (strong, nonatomic) FCManifest* manifest;
@property (strong, nonatomic) FCManifestPredicate* predicate;

- (void) loadPromotionData:(FCManifest*) manifest predicate: (FCManifestPredicate*) predicate;
@end

NS_ASSUME_NONNULL_END
