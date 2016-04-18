//
//  LYCalendarView.m
//  LYLoginButton
//
//  Created by Gu Jun on 3/20/16.
//  Copyright © 2016 Gu Jun. All rights reserved.
//

#define DEFAULT_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define CALENDAR_DEFAULT_HEIGHT (300)
#define MENU_HEIGHT (55)

#import "LYCalendarView.h"
#import "UIColor+LYCalendar.h"

@interface LYCalendarView ()<JTCalendarDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
    NSDate *_dateSelected;
    
    CGFloat _gestureThreshold;           // 手势阈值，决定拖动成功或取消
    
    CGFloat _calendarMenuViewHeight;     // menu栏高度，即月份栏
    CGFloat _calendarContentHeight;      // content区高度，包括week day view和week view
    CGFloat _calendarHeight;             // 日历，包括menu和content
    CGFloat _calendarWeekViewHeight;
    CGFloat _calendarWeekdayViewHeight;
    
    CGFloat _viewHeight;
    
    // 日期区段选择
    NSMutableArray *_datesSelected;
    NSDate *_selectStartDate;
}
// JTCalendar
@property (strong, nonatomic) JTCalendarMenuView *calendarMenuView;
@property (strong, nonatomic) JTHorizontalCalendarView *calendarContentView;
@property (strong, nonatomic) JTCalendarManager *calendarManager;
//@property (weak, nonatomic) NSLayoutConstraint *calendarContentViewHeight;
@property (strong, nonatomic) UIPanGestureRecognizer *scalerGestureRecognizer; // 日历缩放手势
@property (strong, nonatomic) UIPanGestureRecognizer *selectGestureRecognizer; // 日期选择手势


@property (nonatomic, assign) BOOL selectMode;

@end

@implementation LYCalendarView

- (instancetype)init
{
    CGRect frame = CGRectMake(0, 0, DEFAULT_WIDTH, CALENDAR_DEFAULT_HEIGHT);
    
    return [self initWithFrame:frame];
}

#pragma - Designated initialize

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _viewHeight = self.frame.size.height;
    // 初始化日历
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    
    _calendarMenuView = [JTCalendarMenuView new];
    _calendarMenuView.frame = CGRectMake(0, 0, DEFAULT_WIDTH, MENU_HEIGHT);
    _calendarContentView = [JTHorizontalCalendarView new];
    _calendarContentView.frame = CGRectMake(0, MENU_HEIGHT, DEFAULT_WIDTH, CALENDAR_DEFAULT_HEIGHT);
    _calendarContentView.delegate = self;
    
    _calendarMenuView.contentRatio = 0.48; // 菜单栏缩放比例
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:[NSDate date]];
    _calendarMenuView.layer.zPosition = 20;
    
    [self addSubview:_calendarMenuView];
    [self addSubview:_calendarContentView];
    
    // 创建拖动手势
    _scalerGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    _scalerGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_scalerGestureRecognizer];
    
    _selectGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectGestureRecognized:)];
    _selectGestureRecognizer.delegate = self;
    
    // KVO观察手势位移，影响拖动时日历的缩放
    [self addObserver:self forKeyPath:@"gestureTransitionY" options:NSKeyValueObservingOptionNew context:nil];
    
    // 阴影
    [self createShadow];
    
    // weekviews要移到menu位置，出了content的frame，因此需要设置此属性
    _calendarContentView.clipsToBounds = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _calendarMenuViewHeight = _calendarMenuView.frame.size.height;
    _calendarContentHeight = _calendarContentView.frame.size.height;
    _calendarHeight = _calendarMenuViewHeight + _calendarContentHeight;
    
//    _gestureThreshold = _calendarHeight / 2; // 拖动生效的阈值，不到则恢复原状态
    _gestureThreshold = 150;
    
    if (_calendarContentView.subviews.count >= 2) {
        UIView *currentMonthView = [self getCurrentMonth];
        if (currentMonthView.subviews.count >= 2) {
            _calendarWeekViewHeight = currentMonthView.subviews[1].bounds.size.height;
            _calendarWeekdayViewHeight = _calendarWeekViewHeight / 2;
        }
    }
}

#pragma mark - Calendar Delegate

// 日历菜单栏
- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor menuFontColor];
    label.font = [UIFont fontWithName:@"RTWSBanHeiG0v1-Regular" size:36.];
    label.backgroundColor = [UIColor menuBackgroundColor];
    
    // Menu中添加年份
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth / 4 + 20, 30, 40, 14)];
    yearLabel.font = [UIFont fontWithName:@"RTWSBanHeiG0v1-Regular" size:14.];
    yearLabel.textColor = [UIColor menuSubFontColor];
    [label addSubview:yearLabel];
    yearLabel.hidden = YES;
    
    return label;
}


- (void)prepareMenuItemView:(UIView *)menuItemView date:(NSDate *)date
{
    
    NSString *text = nil;
    
    if(date){
        NSCalendar *calendar = _calendarManager.dateHelper.calendar;
        NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        NSInteger currentMonthIndex = comps.month;
        
        static NSDateFormatter *dateFormatter = nil;
        if(!dateFormatter){
            dateFormatter = [_calendarManager.dateHelper createDateFormatter];
        }
        
        dateFormatter.timeZone = _calendarManager.dateHelper.calendar.timeZone;
        dateFormatter.locale = _calendarManager.dateHelper.calendar.locale;
        
        while(currentMonthIndex <= 0){
            currentMonthIndex += 12;
        }
        
        // LYCalendar
        text = [NSString stringWithFormat:@"%ld", (long)currentMonthIndex];
        
        UILabel *yearLabel = menuItemView.subviews[0];
        yearLabel.text = [NSString stringWithFormat:@"%ld", (long)comps.year];
        
        NSDateComponents *componentsA = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        NSDateComponents *componentsB = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
        
        if (componentsA.year == componentsB.year && componentsA.month == componentsB.month) {
            yearLabel.hidden = NO;
        } else {
            yearLabel.hidden = YES;
        }
        yearLabel.hidden = NO;
    }
    
    [(UILabel *)menuItemView setText:text];
}

// 日历day view
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.backgroundColor = [UIColor colorWithRed:234./255 green:234./255 blue:234./255 alpha:1.];
    
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.textLabel.textColor = [UIColor whiteColor];
        dayView.backgroundColor = [UIColor colorWithRed:197./255 green:197./255 blue:197./255 alpha:1.];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
//        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor themeColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:252./255 green:252./255 blue:252./255 alpha:1.];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
        ///
        dayView.textLabel.textColor = [UIColor colorWithRed:235./255 green:235./255 blue:235./255 alpha:1.];
        dayView.backgroundColor = [UIColor colorWithRed:252./255 green:252./255 blue:252./255 alpha:1.];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:234./255 green:234./255 blue:234./255 alpha:1.];
        dayView.textLabel.textColor = [UIColor colorWithRed:200./255 green:200./255 blue:200./255 alpha:1.];
    }
    
    // delegate回调，当天是否有赞助
    if ([_delegate respondsToSelector:@selector(hasSponsorForDay:)] && [_delegate hasSponsorForDay:dayView.date]) {
        dayView.hasSponsor = YES;
        dayView.leftTagView.hidden = NO;
    } else {
        dayView.hasSponsor = NO;
        dayView.leftTagView.hidden = YES;
    }
    
    // delegate回调，当天是否有活动
    if ([_delegate respondsToSelector:@selector(hasEventForDay:)] && [_delegate hasEventForDay:dayView.date]){
        dayView.hasEvent = YES;
        dayView.rightTagView.hidden = NO;
    } else {
        dayView.hasEvent = NO;
        dayView.rightTagView.hidden = YES;
    }
    
    // delegate回调，当天是否有 有缘人
    if ([_delegate respondsToSelector:@selector(hasCoincidenceForDay:)] && [_delegate hasCoincidenceForDay:dayView.date]) {
        dayView.dotView.hidden = NO;
    } else {
        dayView.dotView.hidden = YES;
    }
    
    // LYCalendar 添加 有活动 和 有赞助 的标识
    CGFloat sizeWidth = dayView.frame.size.width;
    CGFloat sizeHeight = 3;
    if (dayView.hasSponsor && dayView.hasEvent) {
        dayView.leftTagView.frame = CGRectMake(0, dayView.frame.size.height - sizeHeight, sizeWidth / 2, sizeHeight);
        dayView.rightTagView.frame = CGRectMake(sizeWidth / 2, dayView.frame.size.height - sizeHeight, sizeWidth, sizeHeight);
        dayView.leftTagView.hidden = NO;
        dayView.rightTagView.hidden = NO;
    } else if (dayView.hasSponsor) {
        dayView.leftTagView.frame = CGRectMake(0, dayView.frame.size.height - sizeHeight, sizeWidth, sizeHeight);
        dayView.leftTagView.hidden = NO;
        dayView.rightTagView.hidden = YES;
    } else if (dayView.hasEvent) {
        dayView.rightTagView.frame = CGRectMake(0, dayView.frame.size.height - sizeHeight, sizeWidth, sizeHeight);
        dayView.rightTagView.hidden = NO;
        dayView.leftTagView.hidden = YES;
    } else {
        dayView.leftTagView.hidden = YES;
        dayView.rightTagView.hidden = YES;
    }
}

// 日历weekday点击事件
- (void)calendar:(JTCalendarManager *)calendar didTouchWeekDayView:(NSUInteger)weekDayIndex
{
    NSCalendar *cal = _calendarManager.dateHelper.calendar;
    NSDateComponents *componentsCurrentDate = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth fromDate:_dateSelected];
    
    NSDateComponents *componentsNewDate = [NSDateComponents new];
    
    componentsNewDate.year = componentsCurrentDate.year;
    componentsNewDate.month = componentsCurrentDate.month;
    componentsNewDate.weekOfMonth = componentsCurrentDate.weekOfMonth;
    componentsNewDate.weekday = weekDayIndex + 1;
    
    _dateSelected = [cal dateFromComponents:componentsNewDate];
    
    [_calendarManager reload];
    
    if ([self.delegate respondsToSelector:@selector(dateDidSelect:)]) {
        [self.delegate dateDidSelect:_dateSelected];
    }
}

// 点击某天的事件
- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
//    [_calendarManager setDate:dayView.date];
    
    // Animation for the circleView
    
    dayView.circleView.transform = CGAffineTransformIdentity;
    [_calendarManager reload];
    
    // Load the previous or next page if touch a day from another month
    
//    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
//        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
//            [_calendarContentView loadNextPageWithAnimation];
//        }
//        else{
//            [_calendarContentView loadPreviousPageWithAnimation];
//        }
//    }
    
    if ([self.delegate respondsToSelector:@selector(dateDidSelect:)]) {
        [self.delegate dateDidSelect:dayView.date];
    }
}

#pragma mark - Gesture Delegate

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
        gestureRecognizer.state == UIGestureRecognizerStateFailed ||
        gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        // 拖动结束，计算位移决定拖动生效或者取消。可能是负数，需要fabs
        CGFloat transitionY = fabs([gestureRecognizer translationInView:self.calendarContentView].y);
        if (transitionY < _gestureThreshold) {
            if (!_collapsed) { // 展开状态开始，回到展开状态
                [self expandWithVelocity:0];
            } else { // 缩起状态开始，回到缩起状态
                [self collapseWithVelocity:0];
            }
        } else {
            // 拖动成功，已通过KVO执行
        }
    } else  {
        // 拖动中，触发KVO
        self.gestureTransitionY = [gestureRecognizer translationInView:self.calendarContentView].y;
        
    }
}

- (void)selectGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
        gestureRecognizer.state == UIGestureRecognizerStateFailed ||
        gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        // 拖动结束
        CGPoint p = [gestureRecognizer locationInView:self.calendarContentView];
        
        NSInteger dayInWeek = (p.x - DEFAULT_WIDTH) / (DEFAULT_WIDTH / 7);
        NSInteger weekInMonth = (p.y - _calendarWeekdayViewHeight) / _calendarWeekViewHeight;
        NSDate *selectEndDate = [[self getCurrentMonth].subviews[weekInMonth+1].subviews[dayInWeek] date];
        
        [self colorDateRangeFrom:_selectStartDate toDate:selectEndDate];
        
        NSDate *dateA, *dateB;
        if ([_calendarManager.dateHelper date:_selectStartDate isEqualOrBefore:selectEndDate]) {
            dateA = _selectStartDate;
            dateB = selectEndDate;
        } else {
            dateB = _selectStartDate;
            dateA = selectEndDate;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dateRangeDidSelectFrom:to:)]) {
            [self.delegate dateRangeDidSelectFrom:dateA to:dateB];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan)  {
        // 拖动开始
        [_calendarManager reload];
        
        CGPoint p = [gestureRecognizer locationInView:self.calendarContentView];
        
        NSInteger dayInWeek = (p.x - DEFAULT_WIDTH) / (DEFAULT_WIDTH / 7);
        NSInteger weekInMonth = (p.y - _calendarWeekdayViewHeight) / _calendarWeekViewHeight;
        _selectStartDate = [[self getCurrentMonth].subviews[weekInMonth+1].subviews[dayInWeek] date];
    } else {
        CGPoint p = [gestureRecognizer locationInView:self.calendarContentView];
        
        NSInteger dayInWeek = (p.x - DEFAULT_WIDTH) / (DEFAULT_WIDTH / 7);
        NSInteger weekInMonth = (p.y - _calendarWeekdayViewHeight) / _calendarWeekViewHeight;
        NSDate *selectEndDate = [[self getCurrentMonth].subviews[weekInMonth+1].subviews[dayInWeek] date];
        
        [self colorDateRangeFrom:_selectStartDate toDate:selectEndDate];
    }
}

#pragma mark - KVO Delegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"gestureTransitionY"]) {
        
        if (!_collapsed) {
            // 展开状态，向上拖动
            [self collapseWhileDragging];
        } else {
            // 收起状态，向下拖动
            [self expandWhileDragging];
        }
    }
}

#pragma mark - animation logic

- (void)collapseWhileDragging
{
    // 不能再向下拖动
    if (_gestureTransitionY > 0) {
        return;
    }
    
    if (fabs(_gestureTransitionY) <= _gestureThreshold) { // 小于阈值，跟随手势进行位移
        // 手势进度，范围 0 到 1
        CGFloat gestureProgress = (fabs(_gestureTransitionY) / _gestureThreshold);
        
        UIView *currentMonth = [self getCurrentMonth];
        
        // self
        CGFloat tmpViewHeight = _viewHeight * (1 - 0.5 * gestureProgress);
        self.frame = CGRectMake(0, 0, DEFAULT_WIDTH, tmpViewHeight);
        
        // 处理外部联动view
        if (!self.associatedView) {
            return;
        }
        CGFloat toFrameY = tmpViewHeight;
        // 60 nav, 49 tab
        CGFloat toHeightY = [UIScreen mainScreen].bounds.size.height - self.frame.size.height - 60 - 49;
        CGRect toFrame = CGRectMake(0, toFrameY, DEFAULT_WIDTH, toHeightY);
        self.associatedView.frame = toFrame;
        
        // menu view
        CGFloat heightRatio = _calendarMenuViewHeight / _viewHeight; // 位移比例
        CGFloat menuTransitionCenterY = - _calendarMenuViewHeight / 2 + tmpViewHeight * heightRatio;
        _calendarMenuView.center = CGPointMake(DEFAULT_WIDTH / 2, menuTransitionCenterY);
        
        // subviews.count=7，第一个weekday view，后六个是week view
        for (int i = 0; i < currentMonth.subviews.count; i++) {
            // 位移变化计算
            UIView<JTCalendarWeek> *weekView = currentMonth.subviews[i];

            heightRatio = (_calendarMenuViewHeight + _calendarWeekdayViewHeight + _calendarWeekViewHeight * i - _calendarWeekViewHeight / 2) / _viewHeight;
            
            if (i == 0) { // week day view
                heightRatio = (_calendarMenuViewHeight + _calendarWeekdayViewHeight / 2) / _viewHeight;
            }
            
            CGPoint transitionCenter = CGPointMake(DEFAULT_WIDTH / 2, tmpViewHeight * heightRatio - _calendarMenuViewHeight);
            weekView.center = transitionCenter;
            
            // alpha变化计算，当前周不改变alpha，其他周alpha降低
            if ([weekView respondsToSelector:@selector(startDate)]) { // weekday view没有这个方法，不判断会crash
                if ([_calendarManager.dateHelper date:weekView.startDate isTheSameWeekThan:[NSDate date]]) {
                    // do nothing for this week
                } else {
                    weekView.alpha = 1 - 0.5 * fabs(_gestureTransitionY) / _gestureThreshold;
                }
            }
        }
    } else { // 大于阈值，拖动成功，执行剩余动画
        CGFloat velocityY = [_scalerGestureRecognizer velocityInView:self].y;
        [self collapseWithVelocity:velocityY];
        _collapsed = YES;
    }
}

- (void)expandWhileDragging
{
    // 不能再向上拖动
    if (_gestureTransitionY < 0) {
        return;
    }
    
    if (fabs(_gestureTransitionY) <= _gestureThreshold) { // 小于阈值，跟随手势进行位移
        // 手势进度，范围 0 到 1
        CGFloat gestureProgress = (fabs(_gestureTransitionY) / _gestureThreshold);
        
        // self
//        CGFloat tmpViewHeight = _viewHeight * gestureProgress * 0.5 + _calendarMenuViewHeight;
        CGFloat tmpViewHeight = _viewHeight * gestureProgress * 0.5 + _calendarWeekdayViewHeight;
        self.frame = CGRectMake(0, 0, DEFAULT_WIDTH, tmpViewHeight);
        
        // 处理外部联动view
        if (!self.associatedView) {
            return;
        }
        CGFloat toFrameY = tmpViewHeight;
        CGRect toFrame = CGRectMake(0, toFrameY, DEFAULT_WIDTH, self.associatedView.frame.size.height);
        self.associatedView.frame = toFrame;
        
        // menu view
        CGFloat heightRatio = _calendarMenuViewHeight / _calendarHeight;
        CGFloat menuTransitionCenterY = - _calendarMenuViewHeight / 2 + fabs(_gestureTransitionY) * heightRatio * gestureProgress * 0.5;
        _calendarMenuView.center = CGPointMake(DEFAULT_WIDTH / 2, menuTransitionCenterY);
        
        // week view
        UIView *currentMonth = [self getCurrentMonth];
        
        for (int i = 0; i < currentMonth.subviews.count; i++) {
            // 位移变化计算
            UIView<JTCalendarWeek> *weekView = currentMonth.subviews[i];
//            CGFloat originCenterY = - _calendarMenuViewHeight;
            CGFloat originCenterY = 0;
            if (i == 0) {
//                originCenterY = _calendarWeekdayViewHeight / 2 - _calendarMenuViewHeight;
                originCenterY = _calendarWeekdayViewHeight / 2;
            }
            CGFloat heightRatio = (_calendarWeekdayViewHeight + _calendarWeekViewHeight * i) / _calendarContentHeight;
            CGPoint transitionCenter = CGPointMake(DEFAULT_WIDTH / 2, originCenterY + _gestureTransitionY * heightRatio *gestureProgress);
            
            weekView.center = transitionCenter;
            
            // alpha变化计算，当前周不改变alpha，其他周alpha降低
            if ([weekView respondsToSelector:@selector(startDate)]) { // weekday view没有这个方法，不判断会crash
                if ([_calendarManager.dateHelper date:weekView.startDate isTheSameWeekThan:[NSDate date]]) {
                    // do nothing for this week
                } else {
                    weekView.alpha = gestureProgress * 0.5 + 0.5;
                    
                }
            }
        }
    } else { // 大于阈值，拖动成功，执行剩余动画
        [self expandWithVelocity:0];
        _collapsed = NO;
    }
}

// 日历收起。上滑成功 或 下拉取消 时调用
- (void)collapseWithVelocity:(CGFloat)velocity
{
    UIView *currentMonth = [self getCurrentMonth];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1. initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // menu view
        _calendarMenuView.center = CGPointMake(DEFAULT_WIDTH / 2, - _calendarMenuViewHeight / 2);
        // content view必须要包含weekday view，否则weekday view的点击事件不能生效
        _calendarContentView.frame = CGRectMake(0, 0, DEFAULT_WIDTH, _calendarContentView.bounds.size.height);
        // week view
        for (UIView<JTCalendarWeek> *weekView in currentMonth.subviews) {
            // only week view responds to startDate
            if ([weekView respondsToSelector:@selector(startDate)]) {
//                weekView.center = CGPointMake(DEFAULT_WIDTH / 2, - _calendarWeekViewHeight / 2 - _calendarMenuViewHeight);
                weekView.center = CGPointMake(DEFAULT_WIDTH / 2, - _calendarWeekViewHeight / 2);
                // this week
                if ([_calendarManager.dateHelper date:weekView.startDate isTheSameWeekThan:[NSDate date]]) {
                    // do not change alpha
                } else {
                    // hides other week views
                    weekView.alpha = 0.;
                }
            } else {
                // week day view
//                weekView.center = CGPointMake(DEFAULT_WIDTH / 2, _calendarWeekdayViewHeight / 2 - _calendarMenuViewHeight);
                weekView.center = CGPointMake(DEFAULT_WIDTH / 2, _calendarWeekdayViewHeight / 2);
            }
        };
        // self
        self.frame = CGRectMake(0, 0, DEFAULT_WIDTH, _calendarWeekdayViewHeight);
        
        // 处理外部联动view
        if (!self.associatedView) {
            return;
        }
        CGFloat toFrameY = _calendarWeekdayViewHeight;
        // 60 nav, 49 tab
        CGFloat toHeightY = [UIScreen mainScreen].bounds.size.height - self.frame.size.height - 60 - 49;
        CGRect toFrame = CGRectMake(0, toFrameY, DEFAULT_WIDTH, toHeightY);
        self.associatedView.frame = toFrame;
        
        [[self getCurrentMonth] collapse];
    } completion:^(BOOL finished) {
        // 滑动成功后禁用水平scroll，一定要配对使用
        if (finished) {
            _calendarContentView.scrollEnabled = NO;
        }
    }];
}

// 日历展开。下拉成功 或 上滑取消 时调用
- (void)expandWithVelocity:(CGFloat)velocity
{
    UIView *currentMonth = [self getCurrentMonth];
    
    for (int i = 0; i < currentMonth.subviews.count; i++) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            // menu view
            CGFloat menuMoveToCenterY = _calendarMenuViewHeight / 2;
            _calendarMenuView.center = CGPointMake(DEFAULT_WIDTH / 2, menuMoveToCenterY);
            _calendarMenuView.alpha = 1.;
            
            // content view
            _calendarContentView.frame = CGRectMake(0, _calendarMenuViewHeight, DEFAULT_WIDTH, _calendarContentHeight);
            
            UIView<JTCalendarWeek> *weekView = currentMonth.subviews[i];
            // week day view
            if (i == 0) {
                weekView.center = CGPointMake(DEFAULT_WIDTH / 2, _calendarWeekdayViewHeight / 2);
            } else { // week view
                CGFloat targetCenterY = _calendarContentHeight - _calendarWeekViewHeight * (currentMonth.subviews.count - i) + _calendarWeekViewHeight / 2;
                weekView.center = CGPointMake(weekView.center.x, targetCenterY);
                weekView.alpha = 1.;
            }
            
            // self
            self.frame = CGRectMake(0, 0, DEFAULT_WIDTH, _viewHeight);
            
            // 处理外部联动view
            if (!self.associatedView) {
                return;
            }
            CGFloat toFrameY = _viewHeight;
            // 60 nav, 49 tab
            CGFloat toHeightY = [UIScreen mainScreen].bounds.size.height - self.frame.size.height - 60 - 49;
            CGRect toFrame = CGRectMake(0, toFrameY, DEFAULT_WIDTH, toHeightY);
            self.associatedView.frame = toFrame;
        } completion:^(BOOL finished) {
            // 滑动成功后启用水平scroll，一定要配对使用
            if (finished) {
                _calendarContentView.scrollEnabled = YES;
                [[self getCurrentMonth] expand];
            }
            
//            // 联动view有一个向下的推力
//            POPSpringAnimation *animation = [POPSpringAnimation animation];
//            animation.property = [POPAnimatableProperty propertyWithName:kPOPViewBounds];
//            animation.fromValue = [NSValue valueWithCGRect:self.associatedView.frame];
//            animation.toValue = [NSValue valueWithCGRect:self.associatedView.frame];
//            animation.velocity = @5.;
//            animation.springBounciness = 15.0;
//            animation.springSpeed = 5;
//            
//            [self.associatedView pop_addAnimation:animation forKey:nil];
        }];
    }
}

#pragma mark - Private Method

- (void)createShadow
{
    _calendarContentView.layer.shadowColor = [UIColor grayColor].CGColor;
    _calendarContentView.layer.shadowOffset = CGSizeMake(0, 0);
    _calendarContentView.layer.shadowOpacity = 1;
    _calendarContentView.layer.shadowRadius = 2;
    _calendarContentView.layer.masksToBounds = NO;
}

- (UIView<JTCalendarPage> *)getCurrentMonth
{
    return [_calendarContentView getCurrentPageView];
}

- (UIView *)getWeekdayView
{
    if (_calendarContentView.subviews.count > 0) {
        return _calendarContentView.subviews[0];
    }
    return nil;
}

- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event inContentView:(UIView *)view
{
    // 缩起状态下不可拖动
    return !_collapsed;
}

- (void)setDate:(NSDate *)date
{
    [_calendarManager setDate:date];
}

- (void)reload
{
    [_calendarManager reload];
}

#pragma mark - 日期区段选择

- (void)beginSelectMode
{
    self.selectMode = YES;
    [self removeGestureRecognizer:_scalerGestureRecognizer];
    [self addGestureRecognizer:_selectGestureRecognizer];
    _calendarContentView.scrollEnabled = NO;
}

- (void)endSelectMode
{
    self.selectMode = NO;
    [self removeGestureRecognizer:_selectGestureRecognizer];
    [self addGestureRecognizer:_scalerGestureRecognizer];
    _calendarContentView.scrollEnabled = YES;
}

- (void)colorDateRangeFrom:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    if (!fromDate || !toDate) {
        return;
    }
    
    NSDate *dateA, *dateB;
    if ([_calendarManager.dateHelper date:fromDate isEqualOrBefore:toDate]) {
        dateA = fromDate;
        dateB = toDate;
    } else {
        dateB = fromDate;
        dateA = toDate;
    }
    
    for (int i = 1; i < [self getCurrentMonth].subviews.count; i++) {
        UIView<JTCalendarWeek> *week = [self getCurrentMonth].subviews[i];
        for (JTCalendarDayView *dayView in week.subviews) {
            if ([_calendarManager.dateHelper date:dayView.date isEqualOrAfter:dateA andEqualOrBefore:dateB]) {
                // 显示背景色
                dayView.circleView.hidden = NO;
            } else {
                dayView.circleView.hidden = YES;
            }
        }
    }
}

@end
