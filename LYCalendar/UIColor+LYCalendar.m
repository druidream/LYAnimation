//
//  UIColor+LYCalendar.m
//  LYLoginButton
//
//  Created by Gu Jun on 3/26/16.
//  Copyright © 2016 Gu Jun. All rights reserved.
//

#import "UIColor+LYCalendar.h"

@implementation UIColor (LYCalendar)

+ (UIColor *)themeColor
{
    return [UIColor colorWithRed:0./255 green:204./255 blue:202./255 alpha:1.];
}

+ (UIColor *)menuBackgroundColor
{
    return [UIColor colorWithRed:243./255 green:243./255 blue:243./255 alpha:1.];
}

+ (UIColor *)menuFontColor
{
    return [self themeColor];
}

+ (UIColor *)menuSubFontColor
{
    return [UIColor colorWithRed:164./255 green:230./255 blue:230./255 alpha:1.];;
}

+ (UIColor *)weekdayBackgroundColor
{
    return [UIColor colorWithRed:243./255 green:243./255 blue:243./255 alpha:1.0];
}

+ (UIColor *)weekdayFontColor
{
//    return [UIColor colorWithRed:152./256. green:147./256. blue:157./256. alpha:1.];
    return [UIColor colorWithRed:200./255 green:200./255 blue:200./255 alpha:1.];
}

@end
