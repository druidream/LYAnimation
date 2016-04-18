//
//  DemoCalendarViewController.m
//  LYAnimation
//
//  Created by Gu Jun on 3/29/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import "DemoCalendarViewController.h"
#import "DemoSnapViewController.h"

@interface DemoCalendarViewController ()<UIGestureRecognizerDelegate>
{
    // 测试用数据源
    NSMutableDictionary *_eventsByDate;
    NSMutableDictionary *_sponsorsByDate;
    NSMutableDictionary *_coincidencesByDate;
}
@end

@implementation DemoCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // fix UITableView动态改变高度时的bug
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 1);
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    
    // 创建测试数据：赞助、活动和有缘人
    [self createRandomSponsors];
    [self createRandomEvents];
    [self createRandomCoincidences];
    self.calendarView.delegate = self;
    
    // 设置联动的view，即下方的table view
    self.calendarView.associatedView = self.tableView;
    
    [self createBarButtons];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDidRecognized:)];
    panGesture.delegate = self;
    [self.tableView addGestureRecognizer:panGesture];
}

// 显示完成后reload一次以展示当月数据
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.calendarView reload];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:[[DemoSnapViewController alloc] init] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear:%@", NSStringFromCGRect(self.tableView.frame));
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear:%@", NSStringFromCGRect(self.tableView.frame));
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - scroll delegate

// 处理折叠状态时，拖动tableview也可以展开日历
- (void)panGestureDidRecognized:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateCancelled) {
        // 拖动结束，计算位移决定拖动生效或者取消。可能是负数，需要fabs
        CGFloat transitionY = fabs([gesture translationInView:self.tableView].y);
        if (transitionY < 150.) {
            if (!self.calendarView.collapsed) { // 展开状态开始，回到展开状态
                [self.calendarView expandWithVelocity:0];
            } else { // 缩起状态开始，回到缩起状态
                [self.calendarView collapseWithVelocity:0];
            }
        } else {
            // 拖动成功，已通过KVO执行
        }
    } else  {
        // 拖动中，触发KVO
        self.calendarView.gestureTransitionY = fabs([gesture translationInView:self.tableView].y);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
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
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_coincidencesByDate[key] && [_coincidencesByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
}

- (void)dateDidSelect:(NSDate *)date
{
    self.navigationItem.title = [[self dateFormatter] stringFromDate:date];
}

- (void)dateRangeDidSelectFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSString *message = [NSString stringWithFormat:@"%@ - %@", [[self dateFormatter] stringFromDate:fromDate], [[self dateFormatter] stringFromDate:toDate]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选中日期区间" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
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

- (void)createRandomCoincidences
{
    _coincidencesByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_coincidencesByDate[key]){
            _coincidencesByDate[key] = [NSMutableArray new];
        }
        
        [_coincidencesByDate[key] addObject:randomDate];
    }
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return dateFormatter;
}

- (void)createBarButtons
{
    UIBarButtonItem *beginSelectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self.calendarView action:@selector(beginSelectMode)];
    UIBarButtonItem *endSelectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self.calendarView action:@selector(endSelectMode)];
    self.navigationItem.rightBarButtonItems = @[beginSelectButton, endSelectButton];
}

@end
