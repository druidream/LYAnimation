//
//  LYLoginPresentationController.m
//  LYLoginButton
//
//  Created by Gu Jun on 3/18/16.
//  Copyright © 2016 Gu Jun. All rights reserved.
//


#import "LYLoginPresentationController.h"

@interface LYLoginPresentationController()

@property(nonatomic,strong)id <UIViewControllerTransitionCoordinator>transitionCoordinator;

@end

@implementation LYLoginPresentationController

- (void)presentationTransitionWillBegin
{
    [self.containerView addSubview:self.presentedView];
    
    // hide presented view at first
    self.presentedView.alpha = 0.0;
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    // do nothing
}

- (UIModalPresentationStyle)adaptivePresentationStyle
{
    return UIModalPresentationFullScreen;
}

@end
