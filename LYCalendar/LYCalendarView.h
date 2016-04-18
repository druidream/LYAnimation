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
@property (nonatomic, assign) CGFloat gestureTransitionY;         // 手势拖动Y轴位移
@property (nonatomic, assign) BOOL collapsed;                     // 日历状态，NO：展开状态；YES：缩起状态

- (void)setDate:(NSDate *)date;
- (void)reload;

- (void)beginSelectMode;
- (void)endSelectMode;

- (void)collapseWithVelocity:(CGFloat)velocity;
- (void)expandWithVelocity:(CGFloat)velocity;

@end
