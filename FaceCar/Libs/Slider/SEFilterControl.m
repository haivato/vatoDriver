//
//  SEFilterControl.m
//  SEFilterControl_Test
//
//  Created by Shady A. Elyaski on 6/13/12.
//  Copyright (c) 2012 mash, ltd. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "SEFilterControl.h"

#define LEFT_OFFSET                         25
#define RIGHT_OFFSET                        25
#define TITLE_SELECTED_DISTANCE             5
#define TITLE_FADE_ALPHA                    .5f

#define KNOB_HEIGHT                         40
#define KNOB_WIDTH                          40

@interface SEFilterControl ()
{
    // Cached slot width
    CGFloat oneSlotSize;

    // Hold titles count, to allows a control without labels
    NSUInteger titlesCount;

    // Dragging management
    BOOL dragging;
    CGFloat dragOffset;
}

@property (nonatomic, strong) NSArray      *labels;
@property (nonatomic, weak)   SEFilterKnob *handler;

@property (nonatomic, strong) IBInspectable UIColor      *handlerColor;
@property (nonatomic, strong) IBInspectable UIColor      *handlerShadowColor;
@property (nonatomic, assign) IBInspectable BOOL          handlerShadow;
@end

@implementation SEFilterControl
#if TARGET_INTERFACE_BUILDER
- (void)prepareForInterfaceBuilder
{
    [self setTitles:@[@"", @"", @""]];
    [self refreshSlotSize];
}
#endif

#pragma mark - Constructors
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        // Force frame height
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), SEFilterControl_HEIGHT);

        // Perform common inits
        [self commonInits:@[@"", @"", @""]];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    // Force frame height
    CGRect updatedFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), SEFilterControl_HEIGHT);

    if (self = [super initWithFrame:updatedFrame])
    {
#if TARGET_INTERFACE_BUILDER
        // Perform common inits
        [self commonInits:@[@"First", @"Second", @"Third"]];
#else
        // Perform common inits
        [self commonInits:@[@"", @"", @""]];
#endif
    }

    return self;
}

- (id)initWithFrame:(CGRect) frame titles:(NSArray *) titles{
    if (self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, SEFilterControl_HEIGHT)]) {

        // Perform common inits
        [self commonInits:titles];
    }

    return self;
}

- (id)initWithFrame:(CGRect) frame titles:(NSArray *) titles labels:(NSArray *) labels{
    if (self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, SEFilterControl_HEIGHT)]) {

        NSAssert2(titles.count == labels.count, @"Error, titles (%ld) and labels (%ld) must contains same objects count", titles.count, labels.count);

        // Perfom common inits
        [self applyDefaultConfiguration];
        [self commonInits:titles labels:labels];
    }

    return self;
}

- (void)applyDefaultConfiguration
{
    self.backgroundColor    = [UIColor clearColor];
    _progressColor          = SEFilterControl_DEFAULT_PROGRESS_COLOR;

    _titlesFont             = SEFilterControl_DEFAULT_TITLE_FONT;
    _titlesColor            = SEFilterControl_DEFAULT_TITLE_COLOR;
    _titlesShadowColor      = SEFilterControl_DEFAULT_TITLE_SHADOW_COLOR;

    _continuous             = NO;
}

- (void)commonInits:(NSArray *)titles
{
    [self applyDefaultConfiguration];

    // Create labels
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    
    // Create labels
    for (NSInteger i=0; i<titles.count; i++)
        [labels addObject:[self buildDefaultLabel]];
    
    [self commonInits:titles labels:labels];
}

- (void)commonInits:(NSArray *)titles labels:(NSArray *)labels
{
    // Hold labels
    self.labels = labels;

    // Hold titles counts
    titlesCount = titles.count;

    // Precompute slot size for futur use
    [self refreshSlotSize];

    [self configureGestures];
    [self configureLabels:titles];
    [self configureKnob];
    [self moveHandlerToIndex:0 animated:NO];
}

- (void)configureLabels:(NSArray *)titles
{
    NSString *title;
    UILabel *lbl;

    for (NSInteger i = 0; i < titlesCount; i++) {
        title = [titles objectAtIndex:i];
        lbl   = [_labels objectAtIndex:i];

        [lbl setFrame:CGRectMake(0, self.frame.size.height, oneSlotSize, 20)];
        [lbl setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [lbl setAdjustsFontSizeToFitWidth:YES];
        [lbl setMinimumScaleFactor:0.4];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setShadowOffset:CGSizeMake(0, 0.5)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setText:title];

        if (i)
            [lbl setAlpha:TITLE_FADE_ALPHA];

        [lbl setCenter:[self centerPointForIndex:i]];
        
        [self addSubview:lbl];
    }
}

- (void)configureKnob
{
    SEFilterKnob *handler = [SEFilterKnob buttonWithType:UIButtonTypeCustom];

    [handler setFrame:CGRectMake(LEFT_OFFSET - KNOB_HEIGHT/2, 1/2*(CGRectGetHeight(self.frame) - KNOB_HEIGHT), KNOB_WIDTH, KNOB_HEIGHT)];
    [handler setCenter:CGPointMake(handler.center.x-(CGRectGetWidth(handler.frame)/2.f), CGRectGetHeight(self.frame)/2)];
    [handler setAdjustsImageWhenHighlighted:NO];

    [self addSubview:handler];

    // Hold handler
    self.handler = handler;
}

- (void)configureGestures
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
    [self addGestureRecognizer:tapGesture];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    [self addGestureRecognizer:panGesture];
}

#pragma mark - Data update
- (void)setTitles:(NSArray *)titles
{
    NSMutableArray *labels = [_labels mutableCopy];
    if (labels.count < titles.count)
    {
        for (NSInteger i=labels.count - 1; i<titles.count; i++)
            [labels addObject:[self buildDefaultLabel]];
    }
    else if (labels.count > titles.count)
    {
        UILabel *label;
        NSInteger labelsCount = labels.count;
        for (NSInteger i=titles.count; i<labelsCount; i++)
        {
            // Remove label
            label = [labels lastObject];
            [label removeFromSuperview];
            [labels removeLastObject];
        }
    }

    // Update titles
    [self setTitles:titles labels:labels];
}

- (void)setTitles:(NSArray *)titles labels:(NSArray *)labels
{
    // Hold labels
    self.labels = labels;

    // Hold titles counts
    titlesCount = titles.count;
    
    // Precompute slot size for futur use
    [self refreshSlotSize];

    // Refresh titles
    [self configureLabels:titles];

    // Force refresh
    [self setNeedsDisplay];

    // Reset selection
    self.selectedIndex = 0;
}

#pragma mark - Drawing code
- (void)drawRect:(CGRect)rect {
#if TARGET_INTERFACE_BUILDER
#endif

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Fill Main Path
    
//    self.progressColor = [UIColor redColor];
    
    CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
    
    CGContextFillRect(context, CGRectMake(LEFT_OFFSET, rect.size.height/ 2 - 3, rect.size.width-RIGHT_OFFSET-LEFT_OFFSET, 6));
    
    CGContextSaveGState(context);
    
    
    CGPoint centerPoint;
    for (NSInteger i = 0; i < titlesCount; i++) {
        centerPoint = [self centerPointForIndex:i];
        
        //Draw Selection Circles
        
        CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
        
        CGContextFillEllipseInRect(context, CGRectMake(centerPoint.x-15, rect.size.height/2 - 8, 15, 15));
    }
}

#pragma mark - Animations
- (void)updateTitlesToIndex:(NSInteger)index animated:(BOOL)animated{
    [_labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        if (animated)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
        }

        if (idx == index) {
            [label setCenter:CGPointMake(CGRectGetMidX(label.frame), self.frame.size.height-KNOB_HEIGHT-TITLE_SELECTED_DISTANCE)];
            [label setAlpha:1];
        }else{
            [label setCenter:CGPointMake(CGRectGetMidX(label.frame), self.frame.size.height-KNOB_HEIGHT)];
            [label setAlpha:TITLE_FADE_ALPHA];
        }
        
        if (animated)
            [UIView commitAnimations];
    }];
}

- (void)moveHandlerToIndex:(NSInteger) index animated:(BOOL)animated{
    CGPoint toPoint = [self centerPointForIndex:index];
    toPoint = CGPointMake(toPoint.x-(_handler.frame.size.width/2.f), _handler.frame.origin.y);
    toPoint = [self fixFinalPoint:toPoint];
    
    if (animated)
        [UIView beginAnimations:nil context:nil];

    // Move handler
    [_handler setFrame:CGRectMake(toPoint.x, toPoint.y, _handler.frame.size.width, _handler.frame.size.height)];
    
    if (animated)
        [UIView commitAnimations];
}

#pragma mark - UIGestureRecognizer callbacks
- (void)tapGestureDetected:(UITapGestureRecognizer *)tapGesture {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];

    [self setSelectedIndex:[self selectedTitleInPoint:[tapGesture locationInView:self]]
                  animated:YES];
}

- (void)panGestureDetected:(UIPanGestureRecognizer *)panGesture {
    CGPoint point = [panGesture locationInView:self];
    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        if (CGRectContainsPoint(CGRectInset(_handler.frame, -40, -40) , point))
        {
            dragOffset = point.x - CGRectGetMinX(_handler.frame);
            dragging = YES;
            [self moveKnobToPoint:CGPointMake(point.x - dragOffset, point.y)];
        }

        return;
    }

    // If no dragging, nothing to do
    if (!dragging)
        return;
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateCancelled)
    {
        [self moveKnobToPoint:CGPointMake(point.x - dragOffset, point.y)];
        
        if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
        {
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            [self setSelectedIndex:[self selectedTitleInPoint:_handler.center]
                          animated:YES];
            dragging = NO;
        }
        else if (_continuous)
        {
            // Update selected index if continuous
            NSUInteger currentIndex = [self selectedTitleInPoint:_handler.center];
            if (currentIndex != _selectedIndex)
            {
                _selectedIndex = currentIndex;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
    }
}

- (void)moveKnobToPoint:(CGPoint)point
{
    CGPoint toPoint = CGPointMake(point.x, _handler.frame.origin.y);
    
    toPoint = [self fixFinalPoint:toPoint];
    
    [_handler setFrame:CGRectMake(toPoint.x, toPoint.y, _handler.frame.size.width, _handler.frame.size.height)];

    [self updateTitlesToIndex:[self selectedTitleInPoint:_handler.center]
                     animated:YES];

    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

#pragma mark - Utils
- (UILabel *)buildDefaultLabel
{
    UILabel *label = [[UILabel alloc] init];

    [label setFont:_titlesFont];
    [label setShadowColor:_titlesShadowColor];
    [label setTextColor:_titlesColor];

    return label;
}

- (void)refreshSlotSize
{
    // Compute slot size
    oneSlotSize = 1.f * (CGRectGetWidth(self.frame) - LEFT_OFFSET-RIGHT_OFFSET-1)/(titlesCount-1);
}

- (NSInteger)selectedTitleInPoint:(CGPoint)pnt {
    return round((pnt.x-LEFT_OFFSET)/oneSlotSize);
}

- (CGPoint)centerPointForIndex:(NSInteger)i {
    return CGPointMake(
                       (i/(float)(titlesCount-1)) * (CGRectGetWidth(self.frame)-RIGHT_OFFSET-LEFT_OFFSET) + LEFT_OFFSET + 4,
//                       CGRectGetHeight(self.frame));
                       i==_selectedIndex ? CGRectGetHeight(self.frame) - KNOB_HEIGHT - TITLE_SELECTED_DISTANCE:CGRectGetHeight(self.frame) - KNOB_HEIGHT);
}

- (CGPoint)fixFinalPoint:(CGPoint)pnt {
    if (pnt.x < LEFT_OFFSET-(_handler.frame.size.width/2.f)) {
        pnt.x = LEFT_OFFSET-(_handler.frame.size.width/2.f);
    }else if (pnt.x+(_handler.frame.size.width/2.f) > self.frame.size.width-RIGHT_OFFSET){
        pnt.x = self.frame.size.width-RIGHT_OFFSET- (_handler.frame.size.width/2.f);
    }
    return pnt;
}

#pragma mark - Setters
- (void) setSelectedIndex:(NSUInteger)index animated:(BOOL) animated
{
    _selectedIndex = index;
    [self updateTitlesToIndex:index animated:animated];
    [self moveHandlerToIndex:index animated:animated];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) setSelectedIndex:(NSUInteger)index {
    [self setSelectedIndex:index animated:NO];
}

- (void) setTitlesColor:(UIColor *)color{
    _titlesColor = color;

    for (UILabel *label in _labels)
        [label setTextColor:color];
}

- (void) titlesShadowColor:(UIColor *)shadowColor{
    _titlesShadowColor = shadowColor;

    for (UILabel *label in _labels)
        [label setShadowColor:shadowColor];
}

- (void) setTitlesFont:(UIFont *)font{
    _titlesFont = font;

    for (UILabel *label in _labels)
        [label setFont:font];
}

#pragma mark - Interface builder
- (void) setHandlerColor:(UIColor *)handlerColor
{
    self.handler.handlerColor = handlerColor;
}

- (void) setHandlerShadow:(BOOL)handlerShadow
{
    self.handler.shadow = handlerShadow;
}

- (void) setHandlerShadowColor:(UIColor *)handlerShadowColor
{
    self.handler.shadowColor = handlerShadowColor;
}

@end
