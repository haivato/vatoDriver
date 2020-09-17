//
//  FCZoneViewModel.m
//  FC
//
//  Created by facecar on 5/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCZoneViewModel.h"

@implementation FCZoneViewModel

- (instancetype) initViewModel {
    self = [super init];
    if (self) {
        [self getListZones];
    }
    
    return self;
}

- (void) getListZones {
    FIRDatabaseReference* ref = [[[[[FIRDatabase database].reference child:TABLE_MASTER] child:@"Zones"] child:@"0"] child:@"cities"];
    [ref keepSynced:YES];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSMutableArray* listZone = [[NSMutableArray alloc] init];
        for(FIRDataSnapshot* s in snapshot.children) {
            FCZone* zone = [[FCZone alloc] initWithDictionary:s.value error:nil];
            if (zone) {
                [listZone addObject:zone];
            }
        }
        self.listZone = listZone;
    }];
}

- (void) didSelectZoneAtIndex: (NSIndexPath*) indexpath {
    self.zoneSelected = [self.listZone objectAtIndex:indexpath.row];
}

@end
