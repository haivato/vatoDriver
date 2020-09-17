//
//  FCNotifyBannerView.m
//  FaceCar
//
//  Created by facecar on 12/16/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCNotifyBannerView.h"
#import "AppDelegate.h"

#define kBannerHeight 60
#define kErrorColor UIColorFromRGB(0xE53935)
#define kSuccessColor UIColorFromRGB(0x388E3C)

static FCNotifyBannerView* instance;

@interface FCNotifyBannerView ()
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;

@end

@implementation FCNotifyBannerView {
    void (^_closeClicked) (void);
    void (^_bannerClicked) (void);
}

+ (FCNotifyBannerView*) banner {
    if (!instance)
        instance = [[FCNotifyBannerView alloc] init];
    
    return instance;
}

- (id) init {
    id view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    
    return view;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kBannerHeight);
}

- (void) hide {
    instance = nil; // release
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.frame = frame;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void) show {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    CGRect targetFrame = self.frame;
    CGRect fromFrame = self.frame;
    fromFrame.origin.y = -targetFrame.size.height;
    self.frame = fromFrame;
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.frame = targetFrame;
                     } completion:^(BOOL finished) {
                     }];
}

- (IBAction)closeClicked:(id)sender {
    if (_closeClicked) {
        _closeClicked ();
    }
    
    [self hide];
}

- (IBAction)bannerClicked:(id)sender {
    if (_bannerClicked) {
        _bannerClicked ();
    }
    
    [self hide];
}

- (void) show:(UIView *)inview
      forType:(FCNotifyBannerType)type
     autoHide:(BOOL)autoHide
      message:(NSString *)message
   closeClick:(void (^)(void))closeclick
  bannerClick:(void (^)(void))bannerclick {
    if (!inview) {
        AppDelegate* appdelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        inview = appdelegate.window;
    }
    
    _closeClicked = closeclick;
    _bannerClicked = bannerclick;
    
    self.lblMessage.text = message;
    if (type == FCNotifyBannerTypeError) {
        self.backgroundColor = kErrorColor;
    }
    else {
        self.backgroundColor = kSuccessColor;
    }
    
    [inview addSubview:self];
    [self show];
    
    if (autoHide) {
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(hide)
                                       userInfo:nil
                                        repeats:NO];
    }
}
@end
