//
//  CarManageTableViewCell.m
//  FC
//
//  Created by Son Dinh on 5/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "CarManageTableViewCell.h"
#import "UIAlertController+Blocks.h"

@interface CarManageTableViewCell()

@property (strong, nonatomic) FCUCar *car;

@end
@implementation CarManageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) bindingData {
    [RACObserve(self.homeViewModel, driver) subscribeNext:^(FCDriver* _driver) {
        if (_driver) {
            [self.carImage setImageWithURL:[NSURL URLWithString:_car.image] placeholderImage:[UIImage imageNamed:@"car-holder-1"]];
            [self.labelCarName setText:_car.marketName];
            [self.labelLicense setText:_car.plate];
            
            if (_car.type == VehicleTypeCar) {
                [self.lblCarService setText:@"VATO Car"];
            }
            else if (_car.type == VehicleTypeBike) {
                [self.lblCarService setText:@"VATO Bike"];
            }
            else if (_car.type == VehicleType7Seat) {
                [self.lblCarService setText:@"VATO 7 chỗ"];
            }
            
            if (self.car.id == _driver.vehicle.id) {
                self.lblCarStatus.text = @"Xe đang sử dụng";
            }
            else {
                self.lblCarStatus.text = @"";
            }
        }
    }];
}

- (void) loadData:(FCUCar*)car;
{
    self.car = car;

    [self bindingData];
}

- (IBAction)onEditCar:(id)sender {
    self.edit(self.car);
}

- (IBAction)onDeleteCar:(id)sender {
    self.del(self.car);
}
- (IBAction)onChooseCar:(id)sender {
    self.choose(self.car);
}
@end
