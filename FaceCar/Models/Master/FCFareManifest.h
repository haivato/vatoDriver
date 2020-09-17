//
//  FCFareManifest.h
//  FaceCar
//
//  Created by facecar on 7/22/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCFareManifest : FCModel
@property (nonatomic, assign)   BOOL active;
@property (nonatomic, strong)   NSString *url;
@property (nonatomic, strong)   NSString *banner;
@property (nonatomic, strong)   NSString *description;
@property (nonatomic, strong)   NSString *headline;
@property (nonatomic, strong)   NSString *icon;
@property (nonatomic, assign)   NSInteger id;
@property (nonatomic, strong)   NSString *image;
@property (nonatomic, strong)   NSString *title;
@property (nonatomic, assign)   NSInteger type;
@end
