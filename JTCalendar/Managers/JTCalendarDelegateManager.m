//
//  JTCalendarDelegateManager.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarDelegateManager.h"

#import "JTCalendarManager.h"

#import "JTCalendarPageView.h"
#import "JTCalendarWeekDayView.h"
#import "JTCalendarWeekView.h"
#import "JTCalendarDayView.h"
#import "UIColor+LYCalendar.h"

@implementation JTCalendarDelegateManager

#pragma mark - Menu view

- (UIView *)buildMenuItemView
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarBuildMenuItemView:)]){
        return [_manager.delegate calendarBuildMenuItemView:self.manager];
    }
    
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor menuFontColor];
    label.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:24.];
    label.backgroundColor = [UIColor menuBackgroundColor];
    
    return label;
}

- (void)prepareMenuItemView:(UIView *)menuItemView date:(NSDate *)date
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendar:prepareMenuItemView:date:)]){
        [_manager.delegate calendar:self.manager prepareMenuItemView:menuItemView date:date];
        return;
    }
    
    NSString *text = nil;
    
    if(date){
        NSCalendar *calendar = _manager.dateHelper.calendar;
        NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        NSInteger currentMonthIndex = comps.month;
        
        static NSDateFormatter *dateFormatter = nil;
        if(!dateFormatter){
            dateFormatter = [_manager.dateHelper createDateFormatter];
        }

        dateFormatter.timeZone = _manager.dateHelper.calendar.timeZone;
        dateFormatter.locale = _manager.dateHelper.calendar.locale;
        
        while(currentMonthIndex <= 0){
            currentMonthIndex += 12;
        }

        // LYCalendar
        text = [NSString stringWithFormat:@"%ld", (long)currentMonthIndex];
//        text = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
        // Menu中添加年份
//        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//        UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth / 4 + 20, 30, 40, 14)];
//        yearLabel.text = [NSString stringWithFormat:@"%ld", (long)comps.year];
//        yearLabel.font = [UIFont fontWithName:@"RTWSBanHeiG0v1-Regular" size:14.];
//        yearLabel.textColor = [UIColor menuSubFontColor];
//        [menuItemView addSubview:yearLabel];
        
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

#pragma mark - Content view

- (UIView<JTCalendarPage> *)buildPageView
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarBuildPageView:)]){
        return [_manager.delegate calendarBuildPageView:self.manager];
    }
    
    return [JTCalendarPageView new];
}

- (BOOL)canDisplayPageWithDate:(NSDate *)date
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendar:canDisplayPageWithDate:)]){
        return [_manager.delegate calendar:self.manager canDisplayPageWithDate:date];
    }
    
    return YES;
}

- (NSDate *)dateForPreviousPageWithCurrentDate:(NSDate *)currentDate
{
    NSAssert(currentDate != nil, @"currentDate cannot be nil");
    
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendar:dateForPreviousPageWithCurrentDate:)]){
        return [_manager.delegate calendar:self.manager dateForPreviousPageWithCurrentDate:currentDate];
    }
    
    if(_manager.settings.weekModeEnabled){
        return [_manager.dateHelper addToDate:currentDate weeks:-1];
    }
    else{
        return [_manager.dateHelper addToDate:currentDate months:-1];
    }
}

- (NSDate *)dateForNextPageWithCurrentDate:(NSDate *)currentDate
{
    NSAssert(currentDate != nil, @"currentDate cannot be nil");
    
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendar:dateForNextPageWithCurrentDate:)]){
        return [_manager.delegate calendar:self.manager dateForNextPageWithCurrentDate:currentDate];
    }
    
    if(_manager.settings.weekModeEnabled){
        return [_manager.dateHelper addToDate:currentDate weeks:1];
    }
    else{
        return [_manager.dateHelper addToDate:currentDate months:1];
    }
}

#pragma mark - Page view

- (UIView<JTCalendarWeekDay> *)buildWeekDayView
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarBuildWeekDayView:)]){
        return [_manager.delegate calendarBuildWeekDayView:self.manager];
    }
    
    return [JTCalendarWeekDayView new];
}

- (UIView<JTCalendarWeek> *)buildWeekView
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarBuildWeekView:)]){
        return [_manager.delegate calendarBuildWeekView:self.manager];
    }
    
    return [JTCalendarWeekView new];
}

#pragma mark - Week view

- (UIView<JTCalendarDay> *)buildDayView
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarBuildDayView:)]){
        return [_manager.delegate calendarBuildDayView:self.manager];
    }
    
    return [JTCalendarDayView new];
}

- (void)didTouchWeekDayView:(NSUInteger)weekDayIndex
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendar:didTouchWeekDayView:)]){
        [_manager.delegate calendar:self.manager didTouchWeekDayView:weekDayIndex];
    }
}

#pragma mark - Day view

- (void)prepareDayView:(UIView<JTCalendarDay> *)dayView
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendar:prepareDayView:)]){
        [_manager.delegate calendar:self.manager prepareDayView:dayView];
    }
}

- (void)didTouchDayView:(UIView<JTCalendarDay> *)dayView
{
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendar:didTouchDayView:)]){
        [_manager.delegate calendar:self.manager didTouchDayView:dayView];
    }
}

@end
