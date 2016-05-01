//
//  DemoSnapViewController.m
//  LYAnimation
//
//  Created by Gu Jun on 4/2/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import "DemoSnapViewController.h"

@interface DemoSnapViewController ()
{
    CGFloat scrollStartOffset;
    CGFloat centerStart;
}

@end

@implementation DemoSnapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [self.indicator addGestureRecognizer:pan];
    self.indicator.userInteractionEnabled = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"foo%ld", (long)indexPath.row+1];
    cell.detailTextLabel.text = @"bar";
    cell.imageView.image = [UIImage imageNamed:@"image-placeholder"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollStartOffset = scrollView.contentOffset.y;
    centerStart = self.indicator.center.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat deltaY = scrollView.contentOffset.y - scrollStartOffset;
    CGPoint newCenter = CGPointMake(self.indicator.center.x, centerStart - deltaY);
    self.indicator.center = newCenter;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.indicator.center = [gesture locationInView:self.view];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateFailed ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        
        UITableViewCell *cell = [self nearestCellToPoint:[gesture locationInView:self.view]];

        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            CGPoint toPoint = CGPointMake(cell.center.x, cell.center.y - self.tableView.contentOffset.y);
            self.indicator.center = toPoint;
        } completion:nil];
    }
}

- (UITableViewCell *)nearestCellToPoint:(CGPoint)gesturePoint
{
    CGFloat minDeltaHeight = [UIScreen mainScreen].bounds.size.height;
    UITableViewCell *nearestCell;
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        CGPoint cellCenter = cell.center;
        CGPoint cellCenterInView = [self.tableView convertPoint:cellCenter toView:self.view];
        CGFloat deltaHeight = fabs(cellCenterInView.y - gesturePoint.y);
        if (deltaHeight < minDeltaHeight) {
            nearestCell = cell;
            minDeltaHeight = deltaHeight;
        }
    }
    
    return nearestCell;
}

@end
