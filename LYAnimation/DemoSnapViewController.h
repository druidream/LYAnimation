//
//  DemoSnapViewController.h
//  LYAnimation
//
//  Created by Gu Jun on 4/2/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoSnapViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *indicator;


@end
