//
//  SliderView.m
//  Slider
//
//  Created by Mathieu Bolard on 02/02/12.
//  Copyright (c) 2012 Streettours. All rights reserved.
//

#import "MBSliderView.h"
#import <QuartzCore/QuartzCore.h>

#define FRAMES_PER_SEC 10

static const CGFloat gradientWidth = 0.2;
static const CGFloat gradientDimAlpha = 0.5;


@interface MBSliderView()
{
    UIView *_background;
    UISlider *_slider;
    MBSliderLabel *_label;
    id<MBSliderViewDelegate> _delegate;
    BOOL _sliding;
}
- (void) loadContent:(CGRect)frame;
- (UIImage *) thumbWithColor:(UIColor*)color;
- (UIImage *) clearPixel;
@end

@implementation MBSliderView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"initWithFrame");
    if (frame.size.width < 136.0) {
        frame.size.width = 136.0;
    }
    if (frame.size.height < 44.0) {
        frame.size.height = 44.0;
    }
    self = [super initWithFrame:frame];
    if (self) {
        [self loadContent:frame];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"initWithCoder");
        [self loadContent:CGRectZero];
    }
    return self;
}
-(void) awakeFromNib
{
    NSLog(@"awakeFromNib");
    [super awakeFromNib];
    [self loadContent:CGRectZero];
}

- (void) loadContent:(CGRect)frame {
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    self.shouldAlignSliderThumb = YES;
    
    if (!_label || !_slider) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        _background = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_background];
        [self sendSubviewToBack:_background];
        
        _label = [[MBSliderLabel alloc] initWithFrame:frame];
        [self addSubview:_label];
        
        
        _slider = [[UISlider alloc] initWithFrame:CGRectZero];
        _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        CGPoint ctr = _slider.center;
        CGRect sliderFrame = _slider.frame;
        sliderFrame.size.width -= 4; //each "edge" of the track is 2 pixels wide
        _slider.frame = sliderFrame;
        _slider.center = ctr;
        _slider.backgroundColor = [UIColor clearColor];
        UIImage *thumbImage = [self thumbWithColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
        [_slider setThumbImage:thumbImage forState:UIControlStateNormal];

        UIImage *clearImage = [self clearPixel];
        [_slider setMaximumTrackImage:clearImage forState:UIControlStateNormal];
        [_slider setMinimumTrackImage:clearImage forState:UIControlStateNormal];
        
        _slider.minimumValue = 0.0;
        _slider.maximumValue = 1.0;
        _slider.continuous = YES;
        _slider.value = 0.0;
        [self addSubview:_slider];
        
        // Set the slider action methods
        [_slider addTarget:self 
                   action:@selector(sliderUp:) 
         forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self 
                   action:@selector(sliderUp:) 
         forControlEvents:UIControlEventTouchUpOutside];
        [_slider addTarget:self 
                   action:@selector(sliderDown:) 
         forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self 
                   action:@selector(sliderChanged:)
         forControlEvents:UIControlEventValueChanged];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat sliderWidth = [_slider thumbImageForState:_slider.state].size.width;
    CGSize labelSize = [_label sizeThatFits:self.bounds.size];
    CGRect sliderFrame = self.bounds;
    CGRect backgroundFrame = self.bounds;
//    backgroundFrame.origin.x += 20.0f;
//    backgroundFrame.size.width -= 30.0f;
    
    CGFloat originX = 0.0f;
    CGFloat padding = 0.0f;
    if (self.shouldAlignSliderThumb)
    {
//        originX = sliderWidth;
//        padding = 10.0f;
    }
    
    CGRect labelFrame = CGRectMake(originX + padding,
                                   CGRectGetMidY(self.bounds) - (labelSize.height / 2.0),
                                   backgroundFrame.size.width - originX - padding * 2,
                                   labelSize.height);
    
    _background.frame = backgroundFrame;
    _slider.frame = sliderFrame;
    _label.frame = labelFrame;
}

// Implement the "enabled" property
- (BOOL) enabled {
	return _slider.enabled;
}

- (void) setEnabled:(BOOL)enabled{
	_slider.enabled = enabled;
	_label.label.enabled = enabled;
	if (enabled) {
		_slider.value = 0.0;
		_label.alpha = 1.0;
		_sliding = NO;
	}
    [_label setAnimated:enabled];
}

- (UIColor*) backgroundColor
{
    return _background.backgroundColor;
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    [_background setBackgroundColor:backgroundColor];
}

// Implement the "text" property
- (NSString *) text {
    return [_label.label text];
}

- (void) setText:(NSString *)text {
    [_label.label setText:text];
    [_label.label setTextAlignment:NSTextAlignmentCenter];
}

// Implement the "labelColor" property
- (UIColor *) labelColor {
    return [_label.label textColor];
}

- (void) setLabelColor:(UIColor *)labelColor {
    [_label.label setTextColor:labelColor];
}

- (UIFont*) font
{
    return _label.label.font;
}

- (void) setFont:(UIFont *)font
{
    [_label.label setFont:font];
}

- (CGFloat) fontSize
{
    return _label.label.font.pointSize;
}

- (void) setFontSize:(CGFloat)fontSize
{
    [_label.label setFont:[_label.label.font fontWithSize:fontSize]];
}

- (UIImage*) thumbImage
{
    return _slider.currentThumbImage;
}

- (void) setThumbImage:(UIImage *)thumbImage
{
    CGSize size = thumbImage.size;
//    size.height = self.bounds.size.height * 1.2f;
//    size.width = size.height * thumbImage.size.width / thumbImage.size.height;
    
    UIImage *scaledImage = [self imageWithImage:thumbImage scaledToSize:size];
    [_slider setThumbImage:scaledImage forState:UIControlStateNormal];
    
    [self setNeedsLayout];
}

- (UIColor*) minimumTrackTinColor
{
    return _slider.minimumTrackTintColor;
}

- (void) setMinimumTrackTinColor:(UIColor *)minimumTrackTinColor
{
    [_slider setMinimumTrackTintColor:minimumTrackTinColor];
}

- (UIColor*) maximumTrackTinColor
{
    return _slider.maximumTrackTintColor;
}

- (void) setMaximumTrackTinColor:(UIColor *)maximumTrackTinColor
{
    [_slider setMaximumTrackTintColor:maximumTrackTinColor];
}

- (NSTextAlignment) textAlignment
{
    return _label.label.textAlignment;
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment
{
    [_label.label setTextAlignment:textAlignment];
}

- (CGFloat) sliderWidth
{
    return [_slider thumbImageForState:_slider.state].size.width;
}

#pragma mark - UISlider actions
- (void)resetDefaultState {
    [_slider setValue:0.0 animated: NO];
    _label.alpha = 1.0;
    [_label setAnimated:YES];
}

- (void) sliderUp:(UISlider *)sender {
    
	if (_sliding) {
		_sliding = NO;
        
        if (_slider.value >= 0.9) {
            if (_delegate && [_delegate respondsToSelector:@selector(sliderDidSlide:shouldResetState:)])
            {
                BOOL resetState;
                [_delegate sliderDidSlide:self shouldResetState:&resetState];
                if (resetState)
                {
                    [self resetDefaultState];
                }
            }
        }
        else
        {
            [UIView animateWithDuration:0.2f animations:^{
                [_slider setValue:0.0 animated: YES];
                _label.alpha = 1.0;
            } completion:^(BOOL finished) {
                [_label setAnimated:YES];
            }];
        }
	}
}

- (void) sliderDown:(UISlider *)sender {

	if (!_sliding) {
		[_label setAnimated:NO];
	}
	_sliding = YES;
}

- (void) sliderChanged:(UISlider *)sender {

	_label.alpha = MAX(0.0, 1.0 - (_slider.value * 3.5));
}


- (void) setThumbColor:(UIColor *)color {
    [_slider setThumbImage:[self thumbWithColor:color] forState:UIControlStateNormal];
}

- (UIImage *) thumbWithColor:(UIColor*)color {
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale<1.0) {scale = 1.0;}
    
    CGSize size = CGSizeMake(68.0*scale, 44.0*scale);
    CGFloat radius = 10.0*scale;
    // create a new bitmap image context
    UIGraphicsBeginImageContext(size);     
    
    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();       
    
    // push context to make it current 
    // (need to do this manually because we are not drawing in a UIView)
    UIGraphicsPushContext(context);    
    
    [color setFill];
    [[[UIColor blackColor] colorWithAlphaComponent:0.8] setStroke];
    
    CGFloat radiusp = radius+0.5;
    CGFloat wid1 = size.width-0.5;
    CGFloat hei1 = size.height-0.5;
    CGFloat wid2 = size.width-radiusp;
    CGFloat hei2 = size.height-radiusp;
    
	// Path
    CGContextMoveToPoint(context, 0.5, radiusp);
    CGContextAddArcToPoint(context, 0.5, 0.5, radiusp, 0.5, radius);
    CGContextAddLineToPoint(context, wid2, 0.5);
    CGContextAddArcToPoint(context, wid1, 0.5, wid1, radiusp, radius);
    CGContextAddLineToPoint(context, wid1, hei2);
    CGContextAddArcToPoint(context, wid1, hei1, wid2, hei1, radius);
    CGContextAddLineToPoint(context, radius, hei1);
    CGContextAddArcToPoint(context, 0.5, hei1, 0.5, hei2, radius);
    CGContextClosePath(context); 
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    // Arrow
    [[[UIColor whiteColor] colorWithAlphaComponent:0.6] setFill];
    [[[UIColor blackColor] colorWithAlphaComponent:0.3] setStroke];
    
    CGFloat points[8]= {    (19.0*scale)+0.5,
                            (16.0*scale)+0.5,
                            (36.0*scale)+0.5,
                            (10.0*scale)+0.5,
                            (52.0*scale)+0.5,
                            (22.0*scale)+0.5,
                            (34.0*scale)+0.5,
                            (28.0*scale)+0.5 };
    
    CGContextMoveToPoint(context, points[0], points[1]);
    CGContextAddLineToPoint(context, points[2], points[1]);
    CGContextAddLineToPoint(context, points[2], points[3]);
    CGContextAddLineToPoint(context, points[4], points[5]);
    CGContextAddLineToPoint(context, points[2], points[6]);
    CGContextAddLineToPoint(context, points[2], points[7]);
    CGContextAddLineToPoint(context, points[0], points[7]);
    CGContextClosePath(context); 
    CGContextDrawPath(context, kCGPathFillStroke); 
    
    
    // Light
    [[[UIColor whiteColor] colorWithAlphaComponent:0.2] setFill];
    
    CGFloat mid = lround(size.height/2.0)+0.5;
    CGContextMoveToPoint(context, 0.5, radiusp);
    CGContextAddArcToPoint(context, 0.5, 0.5, radiusp, 0.5, radius);
    CGContextAddLineToPoint(context, wid2, 0.5);
    CGContextAddArcToPoint(context, wid1, 0.5, wid1, radiusp, radius);
    CGContextAddLineToPoint(context, wid1, mid);
    CGContextAddLineToPoint(context, 0.5, mid);
    CGContextClosePath(context); 
    CGContextDrawPath(context, kCGPathFill);
    
    // pop context 
    UIGraphicsPopContext();                             
    
    // get a UIImage from the image context
    UIImage *outputImage = [[UIImage alloc] initWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:scale orientation:UIImageOrientationUp];
    //write (debug)
    //[UIImagePNGRepresentation(outputImage) writeToFile:@"/Users/mathieu/Desktop/test.png" atomically:YES];
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (UIImage *) clearPixel {
    CGRect rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (MBSliderView *) createDefautTemplate {
    MBSliderView *sliderView = [[MBSliderView alloc] initWithFrame:CGRectZero];
    
    UIColor *color = [UIColor clearColor];
    [sliderView setBackgroundColor:color];
    [sliderView setFont:[UIFont fontWithName:@"Roboto-Regular" size:21.0f]];
    [sliderView setThumbImage:[UIImage imageNamed:@"logo-transparent"]];
    [sliderView setTextAlignment:NSTextAlignmentCenter];
    sliderView.shouldAlignSliderThumb = NO;
    return sliderView;
}


@end


@implementation MBSliderLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _label.text = @"Shimmer";
        _label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:24];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.backgroundColor = [UIColor clearColor];
        _label.adjustsFontSizeToFitWidth = YES;
        self.contentView = _label;
        self.shimmering = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    [_label setFrame:CGRectMake(0, 0, rect.size.height, rect.size.width)];
}

- (BOOL) isAnimated {
    return self.shimmering;
}

- (void) setAnimated:(BOOL)animated {
    self.shimmering = animated;
}
@end
