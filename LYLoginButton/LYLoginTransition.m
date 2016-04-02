//
//  LYLoginTransition.m
//  LYLoginButton
//
//  Created by Gu Jun on 3/18/16.
//  Copyright © 2016 Gu Jun. All rights reserved.
//

#import "LYLoginTransition.h"

@interface LYLoginTransition()

@end

@implementation LYLoginTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *presentedControllerView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIViewController *presentedController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // cancel default slide-up
    presentedControllerView.frame = [transitionContext finalFrameForViewController:presentedController];
    
    // show presented view
    [UIView animateWithDuration:1.0 animations:^{
        presentedControllerView.alpha = 1.0;
    }];
}

@end
