//
//  GoogleViewModel.h
//  FaceCar
//
//  Created by facecar on 5/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCGGPlace.h"
#import "FCGGMapView.h"
@import GooglePlaces;

@interface GoogleViewModel : NSObject

@property (strong, nonatomic) GMSAutocompleteFilter* filter;
@property (strong, nonatomic) NSArray* listPlace;
@property (strong, nonatomic) NSMutableArray* listHistory;
@property (strong, nonatomic) GMSPlace* placeSelected;
@property (strong, nonatomic) FCPlace* place;

- (void) queryPlace: (NSString*) searchText;
- (void) didSelectedPlace:(NSIndexPath*) indexpath;
- (void) saveHistory:(id) data;

- (id) init: (FCGGMapView*) mapview;

@end
