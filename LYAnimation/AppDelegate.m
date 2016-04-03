//
//  AppDelegate.m
//  LYAnimation
//
//  Created by Gu Jun on 3/29/16.
//  Copyright © 2016 liuyi. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoMainViewController.h"
#import "DemoCalendarViewController.h"
#import "DemoLoginViewController.h"
#import "DemoSnapViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0/255. green:204/255. blue:202/255. alpha:1.];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    DemoMainViewController *mainViewController = [[DemoMainViewController alloc] init];
    DemoCalendarViewController *calendarViewController = [[DemoCalendarViewController alloc] init];
    DemoLoginViewController *loginViewController = [[DemoLoginViewController alloc] init];
    DemoSnapViewController *snapViewController = [[DemoSnapViewController alloc] init];
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:calendarViewController];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:snapViewController];
    [nav2.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    mainViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"first"] tag:1];
    nav2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"日历" image:[UIImage imageNamed:@"second"] tag:2];
    loginViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"登录" image:[UIImage imageNamed:@"first"] tag:3];
    snapViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"//吸附" image:[UIImage imageNamed:@"second"] tag:4];
    
    UITabBarController *controller = [UITabBarController new];
    controller.viewControllers = [NSArray arrayWithObjects:mainViewController,
                                  nav2,
                                  loginViewController,
                                  nav4,
                                  nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
