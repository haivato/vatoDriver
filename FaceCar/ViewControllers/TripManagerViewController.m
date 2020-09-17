//
//  TripManagerViewController.m
//  FC
//
//  Created by Son Dinh on 5/22/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "TripManagerViewController.h"
#import "TripDayViewController.h"
#import "TripWeekViewController.h"
#import "TripPageContentViewController.h"
#import "TripMonthViewController.h"
#import "NSObject+Helper.h"

@interface TripManagerViewController ()
@property (strong, nonatomic) NSMutableArray *pages;
//@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) CAPSPageMenu *pageMenu;
@end

@implementation TripManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Array to keep track of controllers in page menu
    NSMutableArray *controllerArray = [NSMutableArray array];
    
    // Create variables for all view controllers you want to put in the
    // page menu, initialize them, and add each to the controller array.
    // (Can be any UIViewController subclass)
    // Make sure the title property of all view controllers is set
    // Example:
    
    //day
    {
        TripDayViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TripDayViewController"];
        vc.title = @"HẰNG NGÀY";
        [controllerArray addObject:vc];
    }
    
    //week
    {
        TripWeekViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TripWeekViewController"];
        vc.title = @"HẰNG TUẦN";
        [controllerArray addObject:vc];
    }
    
    //month
    {
        TripMonthViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TripMonthViewController"];
        vc.title = @"HẰNG THÁNG";
        [controllerArray addObject:vc];
    }
    
    
    
    // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
    // Example:
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
//                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1),
                                 CAPSPageMenuOptionMenuHeight : @(44),
                                 CAPSPageMenuOptionMenuMargin : @(20),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor : [UIColor darkGrayColor],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor : [UIColor whiteColor],
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor : [UIColor lightGrayColor],
                                 CAPSPageMenuOptionAddBottomMenuHairline : @(YES),
                                 CAPSPageMenuOptionBottomMenuHairlineColor : [UIColor orangeColor],
                                 CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth : @(YES)
                                 };
    
    // Initialize page menu with controller array, frame, and optional parameters
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray
                                                        frame:CGRectMake(0.0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)
                                                      options:parameters];
    
    // Lastly add page menu as subview of base view controller view
    // or use pageMenu controller in you view hierachy as desired
    [self.view addSubview:_pageMenu.view];
    
    _pageMenu.delegate = self;
    
//    _pages = [[NSMutableArray alloc] initWithCapacity:3];
//    [_pages addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"TripDayViewController"]];
//    [_pages addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"TripWeekViewController"]];
//    
//    for (int i = 0; i < _pages.count; i++)
//    {
//        TripPageContentViewController *vc = [_pages objectAtIndex:i];
//        vc.pageIndex = i;
//    }
//    
//    
//    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
//    self.pageViewController.dataSource = self;
//    
//    TripPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
//    NSArray *viewControllers = @[startingViewController];
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//    
//    // Change the size of page view controller
//    self.pageViewController.view.frame = self.view.bounds;
//    
//    [self addChildViewController:_pageViewController];
//    [self.view addSubview:_pageViewController.view];
//    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) loadListTripMonth
{
    
}

- (void) loadListTripYear
{
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - CAPSMenu

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    
}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    
}

#pragma mark - UIPageViewControllerDataSource

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TripPageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TripPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (TripPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (self.pages.count <= 0 || index >= [self.pages count]) {
        return nil;
    }
    
    return [_pages objectAtIndex:index];
}

#pragma mark - Actions

- (IBAction)onButtonClose:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
