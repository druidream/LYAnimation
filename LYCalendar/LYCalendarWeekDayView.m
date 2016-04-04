//
//  LYCalendarWeekDayView.m
//  LYAnimation
//
//  Created by Gu Jun on 4/3/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import "LYCalendarWeekDayView.h"
#import "UIColor+LYCalendar.h"

@interface LYCalendarWeekDayView()

@property (nonatomic, readwrite) NSArray *dayViews;

@end

@implementation LYCalendarWeekDayView
@synthesize dayViews;

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
    NSMutableArray *array = [NSMutableArray new];
    
    for(int i = 0; i < 7; ++i){
        UILabel *label = [UILabel new];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor weekdayFontColor];
        label.font = [UIFont boldSystemFontOfSize:12.];
        label.backgroundColor = [UIColor weekdayBackgroundColor];
        
        [self addSubview:label];
        [array addObject:label];
    }
    
    self.dayViews = array;
}

@end
