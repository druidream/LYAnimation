//
//  LYLoginButton.h
//  LYLoginButton
//
//  Created by Gu Jun on 3/17/16.
//  Copyright © 2016 Gu Jun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYLoginButton : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *text;

- (void)startAnimating;
- (void)stopAnimating;

@end
