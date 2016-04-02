//
//  DemoLoginViewController.h
//  LYAnimation
//
//  Created by Gu Jun on 3/29/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYLoginButton.h"

@interface DemoLoginViewController : UIViewController<UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet LYLoginButton *loginButton;

@end
