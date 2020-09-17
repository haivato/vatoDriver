//
//  FCZoneViewModel.h
//  FC
//
//  Created by facecar on 5/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCZone.h"

@interface FCZoneViewModel : NSObject

- (instancetype) initViewModel;
- (void) didSelectZoneAtIndex: (NSIndexPath*) indexpath;

@property (strong, nonatomic) FCZone* zoneSelected;
@property (strong, nonatomic) NSArray<FCZone*>* listZone;

@end
