//
//  DemoLoginViewController.m
//  LYAnimation
//
//  Created by Gu Jun on 3/29/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import "DemoLoginViewController.h"
#import "LYLoginPresentationController.h"
#import "LYLoginTransition.h"

@interface DemoLoginViewController ()

@end

@implementation DemoLoginViewController

- (IBAction)stopButtonDidClick:(UIButton *)sender {
    [_loginButton stopAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self mock_backgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mock_backgroundView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-bg2.jpg"]];
    imageView.frame = self.view.bounds;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
}

@end
