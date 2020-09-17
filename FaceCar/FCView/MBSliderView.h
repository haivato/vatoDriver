//
//  SliderView.h
//  Slider
//
//  Created by Mathieu Bolard on 02/02/12.
//  Copyright (c) 2012 Streettours. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBShimmeringView.h"

@class MBSliderLabel;
@protocol MBSliderViewDelegate;

IB_DESIGNABLE

@interface MBSliderView : UIView

@property (nonatomic, assign) IBInspectable UIColor *backgroundColor;
@property (nonatomic, assign) IBInspectable UIColor *labelColor;
@property (nonatomic, assign) IBInspectable UIColor *minimumTrackTinColor;
@property (nonatomic, assign) IBInspectable UIColor *maximumTrackTinColor;
@property (nonatomic, assign) IBInspectable NSString *text;
@property (nonatomic, assign) IBInspectable CGFloat fontSize;
@property (nonatomic, assign) IBInspectable UIFont *font;
@property (nonatomic, assign) IBInspectable UIImage *thumbImage;
@property (nonatomic, assign) IBInspectable NSTextAlignment textAlignment;
@property (nonatomic, assign) IBInspectable BOOL shouldAlignSliderThumb;

@property (nonatomic) IBOutlet id<MBSliderViewDelegate> delegate;
@property (nonatomic) BOOL enabled;

- (void) setThumbColor:(UIColor *)color;
+ (MBSliderView *) createDefautTemplate;
- (void)resetDefaultState;
@end

@protocol MBSliderViewDelegate <NSObject>

- (void) sliderDidSlide:(MBSliderView *)slideView shouldResetState:(BOOL*)reset;

@end




@interface MBSliderLabel : FBShimmeringView
{
    
}

@property (nonatomic, assign, getter = isAnimated) BOOL animated;
@property (nonatomic, strong, readonly) UILabel *label;
@end
