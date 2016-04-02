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

- (BOOL)hasSponsorForDay:(NSDate *)date;
- (BOOL)hasEventForDay:(NSDate *)date;
- (BOOL)hasCoincidenceForDay:(NSDate *)date; // 有缘人

- (void)dateDidSelect:(NSDate *)date;

@end

@interface LYCalendarView : UIView<JTCalendarDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

// JTCalendar
@property (strong, nonatomic) JTCalendarMenuView *calendarMenuView;
@property (strong, nonatomic) JTHorizontalCalendarView *calendarContentView;

@property (strong, nonatomic) JTCalendarManager *calendarManager;

@property (weak, nonatomic) NSLayoutConstraint *calendarContentViewHeight;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

// LYCalendar
@property (weak, nonatomic) id<LYCalendarViewDelegate> delegate;
@property (weak, nonatomic) UIView *associatedView;

- (void)reload;

@end
