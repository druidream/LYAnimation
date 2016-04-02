//
//  LYLoginButton.m
//  LYLoginButton
//
//  Created by Gu Jun on 3/17/16.
//  Copyright © 2016 Gu Jun. All rights reserved.
//

#import "LYLoginButton.h"

@interface LYLoginButton ()
{
    CGFloat VIEW_HEIGHT;
    CGFloat VIEW_WIDTH;
    CGFloat DIAMETER;
}
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CAShapeLayer *loadingShapeLayer;
@property (nonatomic, strong) UIBezierPath *loadingPath;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSUInteger angleIncrement;
@property (nonatomic, assign) BOOL starting;
@property (nonatomic, assign) BOOL stopping;

@end

@implementation LYLoginButton

-(instancetype)init
{
    NSLog(@"LYLoginButton init");
    self = [super init];
    
    if (self) {
        //
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"%s", __FUNCTION__);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"%s", __FUNCTION__);
    VIEW_WIDTH = self.frame.size.width;
    VIEW_HEIGHT = self.frame.size.height;
    DIAMETER = VIEW_HEIGHT;
    
    _shapeLayer = [[CAShapeLayer alloc] init];
    if (!_color) {
        _color = [UIColor colorWithRed:253.0/255 green:51.0/255 blue:104.0/255 alpha:1.0];
    }
    _shapeLayer.backgroundColor = _color.CGColor;
    _shapeLayer.frame = self.bounds;
    _shapeLayer.cornerRadius = DIAMETER / 2;
    _shapeLayer.masksToBounds = YES;
    _shapeLayer.actions = @{@"position":[NSNull null],@"bounds":[NSNull null],@"path":[NSNull null]};
    [self.layer addSublayer:_shapeLayer];
    
    _loadingShapeLayer = [[CAShapeLayer alloc] init];
    _loadingShapeLayer.frame = CGRectMake(0, 0, DIAMETER, DIAMETER);
    _loadingShapeLayer.fillColor = nil;
    _loadingShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_loadingShapeLayer];
    
    [self p_addTapGesture];
    
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    if (!_text) {
        _text = @"Sign In";
    }
    _label.text = _text;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor whiteColor];
    [self addSubview:_label];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLoadingShape:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = YES;
}

- (void)startAnimating
{
    [self p_removeTapGesture];
    
    [self p_animateShapeBounds_start];

    [UIView animateWithDuration:0.5 animations:^{
        _label.alpha = 0.0;
    }];
    
    _starting = YES;
    _displayLink.paused = NO;
}

- (void)stopAnimating
{
    _stopping = YES;
    
    [self p_animateShapeBounds_stop];
    [self p_animateShapeCornerRadius_stop];
    [self p_animateShapeOpacity_stop];
}

- (void)updateLoadingShape:(id)sender
{
    float angle = (_angleIncrement % 360) / 360.0 * M_PI * 2;
    float startAngle, endAngle;
    
    if (_starting) {
        startAngle = -M_PI_2;
        endAngle = -M_PI_2 + angle;
        if (angle > M_PI) {
            _starting = NO;
        }
    } else if (_stopping) {
//        NSLog(@"%f", angle);
        startAngle = M_PI_2 + angle;
        endAngle = -M_PI_2 + angle;
        if (angle > 0 && angle < M_PI) {
            startAngle = M_PI_2 + angle;
            endAngle = -M_PI_2;
            if (angle > M_PI * 0.8) {
                startAngle = -M_PI_2;
                endAngle = -M_PI_2;
                _displayLink.paused = YES;
            }
        }
    } else {
        startAngle = M_PI_2 + angle;
        endAngle = -M_PI_2 + angle;
    }
    _loadingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(VIEW_WIDTH/2, VIEW_HEIGHT/2) radius:DIAMETER / 4 startAngle:startAngle endAngle:endAngle clockwise:YES];
    _loadingShapeLayer.path = _loadingPath.CGPath;
    
    _angleIncrement += 20;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished
{
    if (finished) {
        if ([_shapeLayer animationForKey:@"bounds_start"] == anim) {
            _shapeLayer.bounds = CGRectMake(0, 0, DIAMETER, DIAMETER);
        }
    }
}

#pragma mark - private methods

- (void)p_addTapGesture
{
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startAnimating)];
    [self addGestureRecognizer:_tapGesture];
}

- (void)p_removeTapGesture
{
    [self removeGestureRecognizer:_tapGesture];
}

- (void)p_animateShapeBounds_start
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.delegate = self;
    animation.duration = 0.6;
    animation.removedOnCompletion = FALSE;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSValue valueWithCGRect:_shapeLayer.bounds];
    animation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, DIAMETER, DIAMETER)];
    [_shapeLayer addAnimation:animation forKey:@"bounds_start"];
}

- (void)p_animateShapeBounds_stop
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.delegate = self;
    animation.duration = .5;
    animation.removedOnCompletion = FALSE;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSValue valueWithCGRect:_shapeLayer.bounds];
    animation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 1000, 1000)];
    [_shapeLayer addAnimation:animation forKey:@"bounds_stop"];
}

- (void)p_animateShapeCornerRadius_stop
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.delegate = self;
    animation.duration = .5;
    animation.removedOnCompletion = FALSE;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:_shapeLayer.cornerRadius];
    animation.toValue = [NSNumber numberWithFloat:500];
    [_shapeLayer addAnimation:animation forKey:@"cornerRadius"];
}

- (void)p_animateShapeOpacity_stop
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.delegate = self;
    animation.duration = .5;
    animation.removedOnCompletion = FALSE;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0];
    [_shapeLayer addAnimation:animation forKey:@"opacity"];
}


@end
