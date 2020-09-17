//
//  DigitalClockViewController.m
//  FC
//
//  Created by Son Dinh on 5/23/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "DigitalClockViewController.h"
#import "NSObject+Helper.h"
#import "GoogleMapsHelper.h"
#import "UIView+Border.h"
#import "GoogleAutoCompleteViewController.h"
#import "GoogleMapsHelper.h"
#import "FCGGMapView.h"
#import "FCBookingService+BookStatus.h"
#import "FCBookingService+UpdateStatus.h"
#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

#define kDeltatime 1

@interface DigitalClockViewController ()
{
    NSTimer *currentTimer;
    BOOL firstTimeLoadMap;
    FCBookingService* _bookingService;
    NSInteger _lastestTime;
    NSInteger _deltaDistance;
    ReceiptView* _receiptView;
}

@property (strong, nonatomic) FCFareSetting *receipt;
@property (weak, nonatomic) IBOutlet FCGGMapView *viewContainMapView;

@property (strong, nonatomic) FCGGMapView *mapView;
@property (strong, nonatomic) GMSMarker *markerStart;
@property (strong, nonatomic) GMSMarker *markerEnd;
@property (strong, nonatomic) GMSMarker *markerDriver;
@property (strong, nonatomic) GMSPolyline* realPolyline;
@property (strong, nonatomic) GMSPolyline* estimatePolyline;
@property (strong, nonatomic) IBOutlet UIButton *buttonDirection;

@property (strong, nonatomic) IBOutlet UIView *orangeDot;
@property (strong, nonatomic) IBOutlet UILabel *labelAddress;


@property (strong, nonatomic) IBOutlet UIView *sliderViewContainer;
@property (strong, nonatomic) IBOutlet UIView *parameterView;
@property (strong, nonatomic) IBOutlet UILabel *labelPrice;
@property (strong, nonatomic) IBOutlet UILabel *labelDistance;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) MBSliderView *sliderView;
@property (weak, nonatomic) IBOutlet FCButton *btnLocation;
@property (weak, nonatomic) IBOutlet FCView *sliderViewBackground;

@property (weak, nonatomic) IBOutlet UILabel *labelAppVersion;

@end

@implementation DigitalClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _lastestTime = 0;
    
    firstTimeLoadMap = YES;
    _bookingService = [FCBookingService shareInstance];
    
    [self initMaps];
    
    [self initView];
    
    [self checkingBookStatus];
    
    [self drawRealPolyline];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumeApp:)
                                                 name:NOTIFICATION_RESUME_APP
                                               object:nil];
}

- (void) resumeApp: (id) sender {
    // set driver busy for sure
    [[FirebaseHelper shareInstance] driverBusy];
}

- (void)viewDidLayoutSubviews
{
    CGRect rect = self.sliderViewContainer.frame;
    [self.sliderView setFrame:CGRectMake(10.0f, 0.0f, rect.size.width - 20.0f, rect.size.height)];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.frame = self.viewContainMapView.bounds;
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:) name:NOTIFICATION_UPDATE_LOCATION_RAPIDLY
                                               object:nil];
    
    // set driver busy for sure
    [[FirebaseHelper shareInstance] driverBusy];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_UPDATE_LOCATION_RAPIDLY
                                                  object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.clockTrip.endLocation != nil)
    {
        [self.labelAddress setText:self.clockTrip.endLocation.name];
        
        CLLocationCoordinate2D start = CLLocationCoordinate2DMake(self.clockTrip.startLocation.location.lat, self.clockTrip.startLocation.location.lon);
        CLLocationCoordinate2D end = CLLocationCoordinate2DMake(self.clockTrip.endLocation.location.lat, self.clockTrip.endLocation.location.lon);
        
        [self addMarkerEndToMap:end];
        
        [self drawPolylineFrom:start to:end include:kCLLocationCoordinate2DInvalid];
    }
    
    //show appp information
    FCDriver *driver = [[UserDataHelper shareInstance] getCurrentUser];
    [self.labelAppVersion setText:[NSString stringWithFormat:@"%li | %@ | %@", (long)driver.user.id, APP_VERSION_STRING, self.booking.info.tripId]];
}

- (void) initView {
    MBSliderView *sliderView = [[MBSliderView alloc] initWithFrame:CGRectZero];
    UIColor *color = [UIColor clearColor];
    sliderView.shouldAlignSliderThumb = NO;
    [sliderView setBackgroundColor:color];
    [sliderView setText:@"TRƯỢT ĐỂ KẾT THÚC"];
    [sliderView setTextAlignment:NSTextAlignmentCenter];
    [sliderView setFont:[UIFont fontWithName:@"Roboto-Regular" size:21.0f]];
    [sliderView setThumbImage:[UIImage imageNamed:@"logo-transparent"]];
    [sliderView setDelegate:self];
    self.sliderView = sliderView;
    [self.sliderViewContainer addSubview:sliderView];
    [self.sliderViewContainer sendSubviewToBack:sliderView];
    
    // load last clock info
    [self loadDistanceUI];
    
    // slider color
    self.sliderViewContainer.backgroundColor = NewOrangeColor;
    self.sliderViewBackground.backgroundColor = GRAY_COLOR;
    self.sliderViewBackground.backgroundColor = GREEN_COLOR;
    self.parameterView.backgroundColor = [UIColor whiteColor];
    //    self.parameterView.backgroundColor = UIColorFromRGB(0x666666);
    
    //round corner
    [self setViewRoundCorner:self.sliderViewContainer withRadius:self.sliderViewContainer.frame.size.height/2];
}

#pragma mark - Booking handler
- (void) checkingBookStatus {
    if ([_bookingService isTripCompleted: self.booking]) {
        [self showReceiptView];
    }
    else {
        [self startTrip];
    }
}

- (void) startTrip {
    [self playsound:@"start"];
    
    // ------------------------------------------
    // init clock
    // ------------------------------------------
    
    if (self.clockTrip == nil)
    {
        self.clockTrip = [[FCDigitalClockTrip alloc] init];
        
        CLLocationCoordinate2D currentLoc = [GoogleMapsHelper shareInstance].currentLocation.coordinate;
        self.clockTrip.lastLocation = [[FCLocation alloc] initWithLat:currentLoc.latitude lon:currentLoc.longitude];
        [[UserDataHelper shareInstance] saveCurrentDigitalClockTrip:self.clockTrip forBook:_booking];
    }
    
    // ------------------------------------------
    // get receipt
    // ------------------------------------------
    [IndicatorUtils showWithAllowDismiss:NO];
    CLLocation *location = [GoogleMapsHelper shareInstance].currentLocation;
    FCUCar* car = [[UserDataHelper shareInstance] getCurrentUser].vehicle;
    NSInteger serviceID = 0;
    if (self.booking.info.clientFirebaseId) {
        serviceID = self.booking.info.serviceId;
    } else {
        for (id item in car.services)
        {
            NSInteger object1 = [item intValue];
            if (object1 == 32) {
                serviceID = 32;
            } else if (object1 == 64) {
                serviceID = 64;
            }
        }
    }
    [[FirebaseHelper shareInstance] getFareDetail:serviceID
                                         tripType:4
                                       atLocation:location
                                        taxiBrand: car.taxiBrand
                                          handler:^(FCFareSetting *receipt, NSArray<FCFarePredicate*> *predecates, NSArray<FCFareModifier*> *modifiers) {
        [IndicatorUtils dissmiss];
        if (receipt)
        {
            
            self.receipt = receipt;
            
            double currentTime = [self getCurrentTimeStamp];
            NSInteger deltaSecond = (currentTime - self.clockTrip.lastOnlineTime) / 1000;
            if (deltaSecond > 0 && self.clockTrip.lastOnlineTime > 0)
            {
                self.clockTrip.totalTime += deltaSecond;
            }
            
            self.clockTrip.lastOnlineTime = currentTime;
            
            [self startTimer];
        }
        else
        {
            [self showAlertError:@"Có lỗi xảy ra"];
        }
    }];
    
    // ------------------------------------------
    // start info
    // ------------------------------------------
    
    //update zoom
    [self updateMaps:location.coordinate];
    
    //update marker
    [self updateMarkerDriverPosition:location.coordinate];
    [self locationUpdate:[NSNotification notificationWithName:NOTIFICATION_UPDATE_LOCATION_RAPIDLY object:location]];
    
    if (!self.clockTrip.startLocation) {
        
        // add marker start
        [self addMarkerStartToMap:location.coordinate];
        
        [[GoogleMapsHelper shareInstance] getAddressOfLocation:location.coordinate withCompletionBlock:^(GMSReverseGeocodeResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error) {
                DLog(@"Cannot get address of current location: %@", error);
            }
            else {
                GMSAddress* address = response.firstResult;
                FCPlace *startLocation = [[FCPlace alloc] init];
                [startLocation setLocation:[[FCLocation alloc] initWithLat:location.coordinate.latitude
                                                                       lon:location.coordinate.longitude]];
                [startLocation setName:address.lines.firstObject];
                self.clockTrip.startLocation = startLocation;
            }
        }];
    }
    else {
        // add marker start
        [self addMarkerStartToMap:CLLocationCoordinate2DMake(self.clockTrip.startLocation.location.lat,
                                                             self.clockTrip.startLocation.location.lon)];
    }
    
}

- (void) updateTime
{
    long long time = [TimeUtils uptime];
    self.clockTrip.totalTime += 1;
    long total = self.clockTrip.totalTime;
    
    // cache to local
    [[UserDataHelper shareInstance] saveCurrentDigitalClockTrip:self.clockTrip forBook:_booking];
    [self.labelTime setText:[self getHourAndMinuteAndSecond:total*1000]];
    
    // only update price if dis greater 100m or duration greater 60 sec
    // only update price & distance when dis >= 10m
    if (_deltaDistance >= 10 || _lastestTime == 0) {
        _deltaDistance = 0;
        _lastestTime += 1;
        [self updatePrice];
        [self loadDistanceUI];
    }
}

- (void) updatePrice {
    long price = [self caculatePrice:self.receipt
                            distance:self.clockTrip.totalDistance
                         timeRunning:self.clockTrip.totalTime
                            finished:NO];
    [self.labelPrice setText:[self formatPrice:price withSeperator:@","]];
}
//
- (void) showAlertError:(NSString*)error
{
    [AlertVC showMessageAlertFor:self
                           title:@"Thông báo"
                         message:@"Chuyến đi đồng hồ thực tế không hỗ trợ. Liên hệ ban quản trị để được hỗ trợ "
                   actionButton1:@"Đóng"
                   actionButton2:nil
                        handler1:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[TOManageCommunication shared] startObserWhenFinishTrip];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NOTIFICATION_RESUME_APP
                                                          object:nil];
            
        }];
        
    }
                        handler2:nil];
    
}

- (void) hideView:(NSString*)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DIGITAL_CLOCK_CLOSE object:error];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_RESUME_APP
                                                  object:nil];
}

- (void) startTimer {
    // stop first
    [self stopTimer];
    
    [[FirebaseHelper shareInstance] getServerTime:^(NSTimeInterval time) {
        if (self.clockTrip.timeStarted == 0) {
            self.clockTrip.timeStarted = time;
        }
        else {
            self.clockTrip.totalTime = MAX(time - self.clockTrip.timeStarted, 0);
        }
        
        // make sure run on main
        dispatch_async(dispatch_get_main_queue(), ^{
            currentTimer = [NSTimer scheduledTimerWithTimeInterval:kDeltatime
                                                            target:self
                                                          selector:@selector(updateTime)
                                                          userInfo:nil
                                                           repeats:YES];
        });
    }];
}

- (void) stopTimer {
    // make sure run on main
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentTimer invalidate];
        currentTimer = nil;
    });
}

#pragma mark - Completed book handler

- (void) prefinishedTrip {
    [IndicatorUtils show];
    [_bookingService updateLastestBookingInfo:self.booking
                                        block:^(NSError *error) {
        [IndicatorUtils dissmiss];
        if (error) {
            [self notifyFinishedError];
        }
        else {
            [self showReceiptView];
        }
    }];
}

- (void) finishedTrip {
    FCBookCommand* command = [[FCBookCommand alloc] init];
    command.status = BookStatusCompleted;
    command.time = [self getCurrentTimeStamp];
    NSMutableArray* cmds = [[NSMutableArray alloc] initWithArray:self.booking.command];
    [cmds addObject:command];
    self.booking.command = cmds;
    [_bookingService processFinishedTrip:self.booking];
    [[FirebaseHelper shareInstance] driverReady];
}

- (void) notifyFinishedError {
    [self showMessageBanner:@"Xảy ra lỗi xác thực thông tin chuyến đi. Bạn vui lòng kiểm tra lại kết nối và thử lại!"
                     status:NO];
    
}

#pragma mark -  MBSliderViewDelegate
- (void) sliderDidSlide:(MBSliderView *)slideView shouldResetState:(BOOL*)reset
{
    [self stopTimer];
    
    [self playsound:@"start"];
    
    // check network
    if (![self isNetworkAvailable]) {
        
        *reset = YES;
        
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Thông báo"
                                             message:@"Đường truyền mạng trên thiết bị đã bị mất kết nối.\n\nKiểm tra lại kết nối để tiếp tục"
                                   cancelButtonTitle:@"Đồng ý"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                    [[UIApplication sharedApplication]
                     openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }
        }];
        return;
    }
    
    
    CLLocation* enLo = [GoogleMapsHelper shareInstance].currentLocation;
    if (self.clockTrip.endLocation == nil) {
        self.clockTrip.endLocation = [[FCPlace alloc] init];
    }
    
    [self.clockTrip.endLocation setLocation:[[FCLocation alloc] initWithLat:enLo.coordinate.latitude
                                                                        lon:enLo.coordinate.longitude]];
    long price = [self caculatePrice:self.receipt
                            distance:self.clockTrip.totalDistance
                         timeRunning:self.clockTrip.totalTime
                            finished:NO];
    price = [self roundUpPrice:price];
    [self.labelPrice setText:[self formatPrice:price]];
    
    // update trip info (price, distance, duration, ..) to server
    if (self.receipt.min >= price) {
        self.booking.info.price = self.receipt.min;
    } else {
        self.booking.info.price = price;
    }
    self.booking.info.distance = self.clockTrip.totalDistance;
    self.booking.info.duration = self.clockTrip.totalTime;
    self.booking.info.endLat = self.clockTrip.endLocation.location.lat;
    self.booking.info.endLon = self.clockTrip.endLocation.location.lon;
    
    [self prefinishedTrip];
    
    [IndicatorUtils showWithAllowDismiss:NO];
    [[GoogleMapsHelper shareInstance] getAddressOfLocation:enLo.coordinate
                                       withCompletionBlock:^(GMSReverseGeocodeResponse* response, NSError* error) {
        
        if (!error) {
            GMSAddress* address = response.firstResult;
            [self.clockTrip.endLocation setName:address.lines.firstObject];
            self.booking.info.endName = address.lines.firstObject;
            self.booking.info.endAddress = address.lines.firstObject;
            if (_receiptView) {
                [_receiptView updateAddressTo:self.booking.info.endAddress];
            }
            
            // update for end name
            [_bookingService updateLastestBookingInfo:self.booking
                                                block:^(NSError *error) {
            }];
        }
    }];
}

#pragma mark - Receip View
- (void) showReceiptView {
    _receiptView = [[NSBundle mainBundle] loadNibNamed:@"ReceiptView" owner:self options:nil].firstObject;
    _receiptView.book = self.booking;
    [self.view addSubview:_receiptView];
    [self.view bringSubviewToFront:_receiptView];
    
    [_receiptView setDelegate:self];
    [_receiptView updateAddressFrom:self.booking.info.startName];
    [_receiptView updateAddressTo:self.booking.info.endName];
    [_receiptView updateDistance:self.booking.info.distance];
    [_receiptView updateTime:self.booking.info.duration];
    if (self.receipt.min >= self.booking.info.price) {
        self.booking.info.price = self.receipt.min;
    }
    [_receiptView updatePrice:self.booking.info.price];
    [_receiptView updateNoteView];
    
    // update status finished
    [_bookingService updateBookStatus:BookStatusCompleted
                             complete:nil];
}

- (void) onCloseReceipt {
    
    // update book status
    [self finishedTrip];
    
    // remove local data
    [[UserDataHelper shareInstance] removeCurrentDigitalClockTrip:_booking];
    
    [self hideView:nil];
}

#pragma mark - Action

- (IBAction)onMyLocation:(id)sender {
    if (self.clockTrip.lastLocation)
    {
        [self updateMaps:CLLocationCoordinate2DMake(self.clockTrip.lastLocation.lat, self.clockTrip.lastLocation.lon)];
    }
}

- (IBAction)onDirection:(id)sender {
    CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(self.clockTrip.startLocation.location.lat, self.clockTrip.startLocation.location.lon);
    CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake(self.clockTrip.endLocation.location.lat, self.clockTrip.endLocation.location.lon);
    
    [GoogleMapsHelper openMapWithStart:startCoordinate andEnd:endCoordinate];
}


#pragma mark - Maps
- (void) initMaps {
    self.mapView = [[FCGGMapView alloc] initWithFrame:self.viewContainMapView.bounds];
    [self.mapView setMinZoom:kMinZoom maxZoom:kMaxZoom];
    [self.viewContainMapView addSubview:self.mapView];
    [self.mapView addLocationButton: self.btnLocation];
    self.btnLocation.backgroundColor = [UIColor clearColor];
    self.buttonDirection.backgroundColor = [UIColor clearColor];
}

/*
 - Clear maps when get driver data success
 - Readd all maker start, end, polyline if have before
 */
- (void) resetMaps {
    [self.mapView clear];
}

- (void) loadDistanceUI {
    NSString *distanceStr = [NSString stringWithFormat:@"%.2f km", self.clockTrip.totalDistance / 1000];
    distanceStr = [distanceStr stringByReplacingOccurrencesOfString:@"." withString:@","];
    [self.labelDistance setText:distanceStr];
}

- (void) updateMaps:(CLLocationCoordinate2D) lo {
    self.mapView.camera = [GMSCameraPosition cameraWithTarget:lo zoom:12];
}

- (void)locationUpdate:(NSNotification*)notification
{
    CLLocation *location = notification.object;
    FCLocation *curLocation = [[FCLocation alloc] initWithLat:location.coordinate.latitude lon:location.coordinate.longitude];
    if (self.clockTrip.lastLocation.lat > 0 && self.clockTrip.lastLocation.lon > 0)
    {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.clockTrip.lastLocation.lat longitude:self.clockTrip.lastLocation.lon];
        CGFloat deltaDistance = [location distanceFromLocation:loc];
        
        // nếu khoảng cách quá lớn thì tính theo google (> 500m)
        if (deltaDistance > 500 && [self isNetworkAvailable]) {
            
            [[GoogleMapsHelper shareInstance] googleApiGetListLocation:CLLocationCoordinate2DMake(self.clockTrip.lastLocation.lat, self.clockTrip.lastLocation.lon)
                                                                 toEnd:location.coordinate
                                                             completed:^(NSMutableArray * listLocation, NSInteger distance) {
                
                self.clockTrip.totalDistance += distance;
                _deltaDistance += distance;
                
                //distance
//                [self loadDistanceUI];
                
                // create polyline
                [self createRealPolyline: listLocation];
            }];
        }
        else {
            self.clockTrip.totalDistance += deltaDistance;
            _deltaDistance += deltaDistance;
            
            //distance
//            [self loadDistanceUI];
            
            // create polyline
            [self createRealPolyline: location];
        }
        
        if (deltaDistance > 0)
        {
            [self rotateDriverMarker:self.markerDriver atCurrent:curLocation andPrevLoc:self.clockTrip.lastLocation];
        }
        
        DLog(@"Digital trip distance: %ld m", (long)self.clockTrip.totalDistance);
    }
    
    self.clockTrip.lastLocation = curLocation;
    [self updateMarkerDriverPosition:location.coordinate];
    
    GMSCoordinateBounds *bound = [[GMSCoordinateBounds alloc] initWithRegion:self.mapView.projection.visibleRegion];
    if (![bound containsCoordinate:location.coordinate])
    {
        [self.mapView animateToLocation:location.coordinate];
    }
    
}

#pragma mark - Marker

- (void) addMarkerStartToMap: (CLLocationCoordinate2D) position {
    if (self.markerStart) {
        self.markerStart.map = nil;
    }
    self.markerStart = [[GMSMarker alloc] init];
    self.markerStart.icon = [UIImage imageNamed:@"marker-start"];
    self.markerStart.map = self.mapView;
    self.markerStart.position = position;
}

- (void) addMarkerEndToMap: (CLLocationCoordinate2D) position {
    if (self.markerEnd) {
        self.markerEnd.map = nil;
    }
    self.markerEnd = [[GMSMarker alloc] init];
    self.markerEnd.icon = [UIImage imageNamed:@"marker-end"];
    self.markerEnd.map = self.mapView;
    self.markerEnd.position = position;
    
    [self.buttonDirection setHidden:NO];
}

- (void) updateMarkerDriverPosition: (CLLocationCoordinate2D) position {
    
    if (self.markerDriver == nil) {
        NSInteger carID = self.booking.info.serviceId;
        
        self.markerDriver = [[GMSMarker alloc] init];
        int zoom = (int) self.mapView.camera.zoom;
        if (zoom < 5) {
            self.markerDriver.icon = [UIImage imageNamed:[NSString stringWithFormat:@"m-car-%lu-5", (long)carID]];
        }
        else if (zoom > 12) {
            self.markerDriver.icon = [UIImage imageNamed:[NSString stringWithFormat:@"m-car-%lu-12", (long)carID]];
        }
        else {
            self.markerDriver.icon = [UIImage imageNamed:[NSString stringWithFormat:@"m-car-%lu-%d", (long)carID, zoom]];
        }
        
        if (self.markerDriver.icon  == nil) {
            FCUCar* car = [[UserDataHelper shareInstance] getCurrentUser].vehicle;
            if (car.type == VehicleTypeBike) {
                self.markerDriver.icon = [UIImage imageNamed:@"m-car-8-12"];
            } else {
                self.markerDriver.icon = [UIImage imageNamed:@"m-car-32-12"];
            }
        }
        
        self.markerDriver.flat = true;
        self.markerDriver.groundAnchor = CGPointMake(0.5f, 0.5f);
        self.markerDriver.map = self.mapView;
        self.markerDriver.rotation = arc4random() % 360;
    }
    
    self.markerDriver.position = position;
    
}

- (void) rotateDriverMarker:(GMSMarker*) marker atCurrent:(FCLocation*) newsLoc andPrevLoc:(FCLocation*) oldLoc {
    CLLocation* des = [[CLLocation alloc] initWithLatitude:newsLoc.lat longitude:newsLoc.lon];
    CLLocation* from = [[CLLocation alloc] initWithLatitude:oldLoc.lat longitude:oldLoc.lon];
    double bearing = [from bearingToLocation:des];
    if (bearing != 0) {
        marker.rotation = bearing;
    }
}

#pragma mark - Polyline
- (void) createRealPolyline: (id) locations {
    
    // polyline
    NSMutableArray* listLocation = [[GoogleMapsHelper shareInstance] decodePolyline:self.clockTrip.polyline];
    if (!listLocation) {
        listLocation = [[NSMutableArray alloc] init];
    }
    if ([locations isKindOfClass:[CLLocation class]]) {
        [listLocation addObject:locations];
    }
    else if ([locations isKindOfClass:[NSMutableArray class]]) {
        [listLocation addObjectsFromArray:locations];
    }
    
    self.clockTrip.polyline = [[GoogleMapsHelper shareInstance] encodeStringWithCoordinates:listLocation];
    [self drawRealPolyline];
    
    DLog(@"Polyline: %@", self.clockTrip.polyline)
}

- (void) drawRealPolyline {
    NSString* decode = self.clockTrip.polyline;
    if (decode) {
        if (self.realPolyline) {
            self.realPolyline.map = nil;
        }
        
        GMSPath *path =[GMSPath pathFromEncodedPath:decode];
        self.realPolyline = [GMSPolyline polylineWithPath:path];
        self.realPolyline.strokeColor = [UIColor orangeColor];
        self.realPolyline.strokeWidth = 2;
        self.realPolyline.map = self.mapView;
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
        
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                                          withEdgeInsets:UIEdgeInsetsMake(100, 100, 100, 100)]];
    }
}

- (void) drawPolylineFrom:(CLLocationCoordinate2D)startPosition
                       to:(CLLocationCoordinate2D)endPosition
                  include:(CLLocationCoordinate2D)otherPosition
{
    [[GoogleMapsHelper shareInstance] getDirection:startPosition
                                             andAt:endPosition
                                         completed:^(FCRouter * router) {
        @try {
            if (self.estimatePolyline) {
                self.estimatePolyline.map = nil;
            }
            
            GMSPath *path =[GMSPath pathFromEncodedPath:router.polylineEncode];
            self.estimatePolyline = [GMSPolyline polylineWithPath:path];
            self.estimatePolyline.strokeColor = [UIColor blackColor];
            self.estimatePolyline.strokeWidth = 2;
            self.estimatePolyline.map = self.mapView;
            
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
            if (!CLLocationCoordinate2DIsValid(otherPosition) || (otherPosition.latitude == 0 && otherPosition.longitude == 0))
            {
                //do nothing
            }
            else
            {
                bounds = [bounds includingCoordinate:otherPosition];
            }
            
            
            
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                                              withEdgeInsets:UIEdgeInsetsMake(100, 100, 100, 100)]];
        }
        @catch (NSException* e) {
            DLog(@"Error: %@", e)
        }
    }];
}

#pragma mark - Places

- (IBAction)onAddressViewTouched:(id)sender {
    [self loadPlacePickerView:nil];
}

- (void) loadPlacePickerView:(id) sender {
    GoogleAutoCompleteViewController* vc = [[GoogleAutoCompleteViewController alloc] initViewController];
    [vc setMapview:self.mapView];
    
    [RACObserve(vc.googleViewModel, place) subscribeNext:^(FCPlace* x) {
        if (x) {
            [self handlerPlaceAutoComplete:x error:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) handlerPlaceAutoComplete: (FCPlace*) place error: (NSError*) er {
    // move camera
    [self updateMaps:CLLocationCoordinate2DMake(place.location.lat, place.location.lon)];
    
    // choose place
    if (self.clockTrip.endLocation == nil) {
        self.clockTrip.endLocation = [[FCPlace alloc] init];
    }
    
    [self.clockTrip.endLocation setLocation:[[FCLocation alloc] initWithLat:place.location.lat lon:place.location.lon]];
    [self.clockTrip.endLocation setName:place.name];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.clockTrip.startLocation.location.lat
                                                      longitude:self.clockTrip.startLocation.location.lon];
    [self drawPolylineFrom:location.coordinate to:CLLocationCoordinate2DMake(place.location.lat, place.location.lon) include:kCLLocationCoordinate2DInvalid];
    [self addMarkerEndToMap:CLLocationCoordinate2DMake(place.location.lat, place.location.lon)];
    [self.labelAddress setText:place.address];
}

@end
