//
//  DemoCalendarViewController.m
//  LYAnimation
//
//  Created by Gu Jun on 3/29/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import "DemoCalendarViewController.h"

@interface DemoCalendarViewController ()
{
    // 测试用数据源
    NSMutableDictionary *_eventsByDate;
    NSMutableDictionary *_sponsorsByDate;
    
}
@end

@implementation DemoCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    
//    if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.calendarView.delegate = self;
    // 设置联动的view，即下方的table view
    self.calendarView.associatedView = self.tableView;
    
    // 创建测试数据：赞助、活动和有缘人
    [self createRandomSponsors];
    [self createRandomEvents];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.imageView.image = [UIImage imageNamed:@"image-placeholder"];
    cell.imageView.alpha = 0.5;
    cell.textLabel.text = @"foo";
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.text = @"bar";
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.;
}

#pragma mark - calendar delegate

- (BOOL)hasSponsorForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_sponsorsByDate[key] && [_sponsorsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
}

- (BOOL)hasEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
}

- (BOOL)hasCoincidenceForDay:(NSDate *)date
{
    return NO;
}

#pragma mark - 测试用数据

- (void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:randomDate];
    }
}

- (void)createRandomSponsors
{
    _sponsorsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_sponsorsByDate[key]){
            _sponsorsByDate[key] = [NSMutableArray new];
        }
        
        [_sponsorsByDate[key] addObject:randomDate];
    }
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

@end