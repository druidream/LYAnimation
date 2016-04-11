//
//  LYCalendarView.h
//  LYLoginButton
//
//  Created by Gu Jun on 3/20/16.
//  Copyright © 2016 Gu Jun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@protocol LYCalendarViewDelegate <NSObject>

@optional

- (BOOL)hasSponsorForDay:(NSDate *)date;    // 有赞助
- (BOOL)hasEventForDay:(NSDate *)date;      // 有活动
- (BOOL)hasCoincidenceForDay:(NSDate *)date;// 有缘人

- (void)dateDidSelect:(NSDate *)date;       // 选中日期后的回调
- (void)dateRangeDidSelectFrom:(NSDate *)fromDate to:(NSDate *)toDate; // 选中日期区段的回调

@end

@interface LYCalendarView : UIView

@property (weak, nonatomic) IBOutlet id<LYCalendarViewDelegate> delegate;
@property (weak, nonatomic) UIView *associatedView;

- (void)setDate:(NSDate *)date;
- (void)reload;

- (void)beginSelectMode;
- (void)endSelectMode;

@end
