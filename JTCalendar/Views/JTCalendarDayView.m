//
//  JTCalendarDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarDayView.h"

#import "JTCalendarManager.h"

@implementation JTCalendarDayView

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
    self.clipsToBounds = YES;
    
    _circleRatio = .9;
    _dotRatio = 1. / 9.;
    
    {
        _circleView = [UIView new];
        [self addSubview:_circleView];
        
//        _circleView.backgroundColor = [UIColor colorWithRed:0x33/256. green:0xB3/256. blue:0xEC/256. alpha:.5];
        _circleView.backgroundColor = [UIColor colorWithRed:0./255 green:204./255 blue:202./255 alpha:1.];
        _circleView.hidden = YES;

        _circleView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _circleView.layer.shouldRasterize = YES;
    }
    
    {
//        _dotView = [UIView new];
        _dotView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cornerTriangle"]];
        [self addSubview:_dotView];
        
//        _dotView.backgroundColor = [UIColor redColor];
        _dotView.hidden = YES;

        _dotView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _dotView.layer.shouldRasterize = YES;
    }
    
    {
        _textLabel = [UILabel new];
        [self addSubview:_textLabel];

        _textLabel.textAlignment = NSTextAlignmentLeft;
        // LYCalendar
//        _textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        _textLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch)];
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:gesture];
    }
    // LYCalendar
    {
        _leftTagView = [UIView new];
        [self addSubview:_leftTagView];
        
        _leftTagView.backgroundColor = [UIColor colorWithRed:252/255. green:130/255. blue:104/255. alpha:1.];
        _leftTagView.hidden = YES;
        
        _rightTagView = [UIView new];
        [self addSubview:_rightTagView];
        
        _rightTagView.backgroundColor = [UIColor colorWithRed:44/255. green:167/255. blue:233/255. alpha:1.];
        _rightTagView.hidden = YES;
    }
    
    // LYCalendar 给day view加白色边框
    [self.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.layer setBorderWidth:.5f];
}

- (void)layoutSubviews
{
    _textLabel.frame = CGRectMake(5, self.bounds.size.height / 2 - 5, self.bounds.size.width, self.bounds.size.height / 2);
    
    CGFloat sizeCircle = MIN(self.frame.size.width, self.frame.size.height);
    CGFloat sizeDot = sizeCircle;
    
    sizeCircle = sizeCircle * _circleRatio;
    sizeDot = sizeDot * _dotRatio;
    
    sizeCircle = roundf(sizeCircle);
    sizeDot = roundf(sizeDot);
    
    // LYCalender，circleView用作选中样式，改为方形
//    GRectMake(0, 0, sizeCircle, sizeCircle);
    _circleView.frame = self.frame;
    _circleView.center = CGPointMake(self.frame.size.width / 2., self.frame.size.height / 2.);
//    _circleView.layer.cornerRadius = sizeCircle / 2.;
    
    // LYCalendar，dotView用作 有缘人 的标识
//    _dotView.frame = CGRectMake(0, 0, sizeDot, sizeDot);
//    _dotView.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) +sizeDot * 2.5);
//    _dotView.layer.cornerRadius = sizeDot / 2.;
    _dotView.frame = CGRectMake(0, 0, 10, 10);
    
}

- (void)setDate:(NSDate *)date
{
    NSAssert(date != nil, @"date cannot be nil");
    NSAssert(_manager != nil, @"manager cannot be nil");
    
    self->_date = date;
    [self reload];
}

- (void)reload
{
    static NSDateFormatter *dateFormatter = nil;
    if(!dateFormatter){
        dateFormatter = [_manager.dateHelper createDateFormatter];
        [dateFormatter setDateFormat:@"d"];
    }
    
    _textLabel.text = [dateFormatter stringFromDate:_date];
        
    [_manager.delegateManager prepareDayView:self];
}

- (void)didTouch
{
    [_manager.delegateManager didTouchDayView:self];
}

@end
