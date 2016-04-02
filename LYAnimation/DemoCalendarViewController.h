//
//  DemoCalendarViewController.h
//  LYAnimation
//
//  Created by Gu Jun on 3/29/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYCalendarView.h"

@interface DemoCalendarViewController : UIViewController<LYCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet LYCalendarView *calendarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
