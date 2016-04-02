//
//  DemoMainViewController.m
//  LYAnimation
//
//  Created by Gu Jun on 3/29/16.
//  Copyright © 2016 liuyi. All rights reserved.
//
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#import "DemoMainViewController.h"
#import <POP/POP.h>

@interface DemoMainViewController ()

@end

@implementation DemoMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIImage *image = [UIImage imageNamed:@"header"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 1.2)];
    imageView.image = image;
    self.tableView.tableHeaderView = imageView;

//    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self p_animation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"New Subpage for Janet";
            cell.imageView.image = [UIImage imageNamed:@"avatar1"];
            cell.detailTextLabel.text = @"8 - 10am";
            break;
        case 1:
            cell.textLabel.text = @"Catch up with Tom";
            cell.imageView.image = [UIImage imageNamed:@"avatar1"];
            cell.detailTextLabel.text = @"11 - 12am Hangouts";
            break;
        case 2:
            cell.textLabel.text = @"Lunch with Diane";
            cell.imageView.image = [UIImage imageNamed:@"avatar1"];
            cell.detailTextLabel.text = @"12am Restaurant";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
//    return imageView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 450;
//}

#pragma mark - 登场动效

- (void)p_animation
{
    NSArray *visibleCells = self.tableView.visibleCells;
    double delayInSeconds = 0.;
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerTranslationY];
    animation.fromValue = @(-50.0);
    animation.toValue = @0.0;
    animation.duration = 1;
    
    [self.tableView.tableHeaderView.layer pop_addAnimation:animation forKey:nil];
    
    for (int i=0; i<visibleCells.count; i++) {
        UITableViewCell *cell = [visibleCells objectAtIndex:i];
        [cell setHidden:YES];
        delayInSeconds += 0.2;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [cell setHidden:NO];
            
            POPBasicAnimation *animation = [POPBasicAnimation animation];
            animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerTranslationY];
            animation.fromValue = @(-50.0);
            animation.toValue = @0.0;
            animation.duration = 1;
//            animation.springBounciness = 1.0;
//            animation.springSpeed = 2;
            [cell.layer pop_addAnimation:animation forKey:nil];
            
            POPBasicAnimation *alphaAnimation = [POPBasicAnimation animation];
            alphaAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
            alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            alphaAnimation.fromValue = @(0.);
            alphaAnimation.toValue = @(1.);
            alphaAnimation.duration = 1;
            [cell.contentView pop_addAnimation:alphaAnimation forKey:nil];
            
//            cell.contentView.layer.anchorPoint = CGPointMake(0.5, 1.0);
            
//            POPBasicAnimation *scaleAnimation = [POPBasicAnimation animation];
//            scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
//            scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//            scaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(2, 2)];
//            scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
//            scaleAnimation.duration = 1;
//            [cell.contentView.layer pop_addAnimation:scaleAnimation forKey:nil];
////            NSLog(@"%@", NSStringFromCGPoint(cell.contentView.center));
//            NSLog(@"%@", NSStringFromCGPoint(cell.contentView.layer.position));
//            NSLog(@"%@", NSStringFromCGPoint(cell.contentView.layer.anchorPoint));
            
            
            animation = [POPBasicAnimation animation];
            animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerPositionX];
            animation.fromValue = @(0.0);
            animation.toValue = @30.0;
            animation.duration = 1;
            //            animation.springBounciness = 1.0;
            //            animation.springSpeed = 2;
            [cell.imageView.layer pop_addAnimation:animation forKey:nil];
            
            animation = [POPBasicAnimation animation];
            animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleX];
            animation.fromValue = @1.3;
            animation.toValue = @1.0;
            animation.duration = 1;
            [cell.textLabel.layer pop_addAnimation:animation forKey:nil];
            
            animation = [POPBasicAnimation animation];
            animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleX];
            animation.fromValue = @1.3;
            animation.toValue = @1.0;
            animation.duration = 1;
            [cell.detailTextLabel.layer pop_addAnimation:animation forKey:nil];
            
            
//            cell.contentView.contentScaleFactor = 1.5;
//            cell.contentMode = UIViewContentModeCenter;
        });
        
    }
}

@end
