//
//  UITapGestureRecognizer+Tap.m
//  FC
//
//  Created by tony on 10/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "UITapGestureRecognizer+Tap.h"

@implementation UITapGestureRecognizer (Tap)
/*
func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
    // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: CGSize.zero)
    let textStorage = NSTextStorage(attributedString: label.attributedText!)
    
    // Configure layoutManager and textStorage
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    
    // Configure textContainer
    textContainer.lineFragmentPadding = 0.0
    textContainer.lineBreakMode = label.lineBreakMode
    textContainer.maximumNumberOfLines = label.numberOfLines
    let labelSize = label.bounds.size
    textContainer.size = labelSize
    
    // Find the tapped character location and compare it to the specified range
    let locationOfTouchInLabel = self.locationInView(label)
    let textBoundingBox = layoutManager.usedRectForTextContainer(textContainer)
    let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                     locationOfTouchInLabel.y - textContainerOffset.y);
    let indexOfCharacter = layoutManager.characterIndexForPoint(locationOfTouchInTextContainer, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    
    return NSLocationInRange(indexOfCharacter, targetRange)
}
 */
- (BOOL) didTapAttributedTextInLabel:(UILabel*) label inRange:(NSRange) targetRange {
    NSLayoutManager* layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer* textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];
    
    // Configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    // Configure textContainer
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = label.lineBreakMode;
    textContainer.maximumNumberOfLines = label.numberOfLines;
    CGSize labelSize = label.bounds.size;
    textContainer.size = labelSize;
    
    // Find the tapped character location and compare it to the specified range
    CGPoint locationOfTouchInLabel = [self locationInView:label];
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                     locationOfTouchInLabel.y - textContainerOffset.y);
    NSUInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    
    return NSLocationInRange(indexOfCharacter, targetRange);
}
@end
