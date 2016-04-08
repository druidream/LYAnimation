//
//  JTCalendarWeekDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarWeekDayView.h"

#import "JTCalendarManager.h"
#import "UIColor+LYCalendar.h"

#define NUMBER_OF_DAY_BY_WEEK 7.

@implementation JTCalendarWeekDayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor weekdayBackgroundColor];
    
    NSMutableArray *dayViews = [NSMutableArray new];
    
    for(int i = 0; i < NUMBER_OF_DAY_BY_WEEK; ++i){
        UILabel *label = [UILabel new];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor weekdayFontColor];
        label.font = [UIFont boldSystemFontOfSize:12.];
        
        [self addSubview:label];
        [dayViews addObject:label];
    }
    
    // LYCalendar
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch:)];
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:gesture];
    }
    
    _dayViews = dayViews;
    
    UILabel *selectIndicator = [UILabel new];
    selectIndicator.backgroundColor = [UIColor colorWithRed:0.773  green:0.773  blue:0.773 alpha:1];
    selectIndicator.textColor = [UIColor whiteColor];
    selectIndicator.textAlignment = NSTextAlignmentCenter;
    selectIndicator.text = @"";
    selectIndicator.hidden = YES;
    _selectIndicator = selectIndicator;
    
    [self addSubview:selectIndicator];
}

- (void)reload
{
    NSAssert(_manager != nil, @"manager cannot be nil");
    
    NSDateFormatter *dateFormatter = [_manager.dateHelper createDateFormatter];
    NSMutableArray *days = nil;
    
    dateFormatter.timeZone = _manager.dateHelper.calendar.timeZone;
    dateFormatter.locale = _manager.dateHelper.calendar.locale;
    
    switch(_manager.settings.weekDayFormat) {
        case JTCalendarWeekDayFormatSingle:
            days = [[dateFormatter veryShortStandaloneWeekdaySymbols] mutableCopy];
            break;
        case JTCalendarWeekDayFormatShort:
            days = [[dateFormatter shortStandaloneWeekdaySymbols] mutableCopy];
            break;
        case JTCalendarWeekDayFormatFull:
            days = [[dateFormatter standaloneWeekdaySymbols] mutableCopy];
            break;
    }
    
    for(NSInteger i = 0; i < days.count; ++i){
        NSString *day = days[i];
        [days replaceObjectAtIndex:i withObject:[day uppercaseString]];
    }
    
    // Redorder days for be conform to calendar
    {
        NSCalendar *calendar = [_manager.dateHelper calendar];
        NSUInteger firstWeekday = (calendar.firstWeekday + 6) % 7; // Sunday == 1, Saturday == 7
        
        for(int i = 0; i < firstWeekday; ++i){
            id day = [days firstObject];
            [days removeObjectAtIndex:0];
            [days addObject:day];
        }
    }
    
    for(int i = 0; i < NUMBER_OF_DAY_BY_WEEK; ++i){
        UILabel *label =  _dayViews[i];
        label.text = days[i];
    }
}

- (void)layoutSubviews
{
    if(!_dayViews){
        return;
    }
    
    CGFloat x = 0;
    CGFloat dayWidth = self.frame.size.width / NUMBER_OF_DAY_BY_WEEK;
    CGFloat dayHeight = self.frame.size.height;
    
    for(UIView *dayView in _dayViews){
        dayView.frame = CGRectMake(x, 0, dayWidth, dayHeight);
        _selectIndicator.frame = CGRectMake(x, 0, dayWidth, dayHeight);
        x += dayWidth;
    }
    
}

- (void)didTouch:(UIGestureRecognizer *)gesture
{
    CGFloat dayWidth = self.frame.size.width / NUMBER_OF_DAY_BY_WEEK;
    CGFloat dayHeight = self.frame.size.height;
    NSUInteger touchInWeekdayIndex = [gesture locationInView:self].x / dayWidth;
    
    NSCalendar *cal = _manager.dateHelper.calendar;
    NSDateComponents *componentsCurrentDate = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth fromDate:_manager.date];
    
    NSDateComponents *componentsNewDate = [NSDateComponents new];
    
    componentsNewDate.year = componentsCurrentDate.year;
    componentsNewDate.month = componentsCurrentDate.month;
    componentsNewDate.weekOfMonth = componentsCurrentDate.weekOfMonth;
    componentsNewDate.weekday = touchInWeekdayIndex + 1;
    
    NSDate *newDate = [cal dateFromComponents:componentsNewDate];
    [_manager setDate:newDate];
    NSDateComponents *weekdayComponents = [cal components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:newDate];
    NSInteger day = [weekdayComponents day];
    
    _selectIndicator.frame = CGRectMake(dayWidth * touchInWeekdayIndex, 0, dayWidth, dayHeight);
    _selectIndicator.text = [NSString stringWithFormat:@"%ld", (long)day];
    
    [_manager.delegateManager didTouchWeekDayView:touchInWeekdayIndex];
}

- (void)compactMode
{
    NSDate *today = _manager.date;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];
    NSInteger day = [weekdayComponents day];
    NSInteger weekday = [weekdayComponents weekday];
    
    CGFloat dayWidth = self.frame.size.width / NUMBER_OF_DAY_BY_WEEK;
    CGFloat dayHeight = self.frame.size.height;
    _selectIndicator.frame = CGRectMake(dayWidth * (weekday - 1), 0, dayWidth, dayHeight);
    
    _selectIndicator.text = [NSString stringWithFormat:@"%ld", (long)day];
    
    _selectIndicator.hidden = NO;
}

- (void)fullMode
{
    _selectIndicator.hidden = YES;
}

@end
