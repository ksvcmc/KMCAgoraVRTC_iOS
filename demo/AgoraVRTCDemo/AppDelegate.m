//
//  AppDelegate.m
//  AgoraVRTCDemo
//
//  Created by 张俊 on 05/07/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "AppDelegate.h"
#import "KSYMainViewController.h"

#define kIsMultiAoraVR YES

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    CGRect cframe = [[UIScreen mainScreen] bounds];
    
    self.window = [[UIWindow alloc] initWithFrame:cframe];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.clipsToBounds = YES;
    KSYMainViewController *rootVC = [[KSYMainViewController alloc]init];
    UINavigationBar *bar = [UINavigationBar appearance];
    //设置显示的颜色
    bar.barTintColor = [UIColor colorWithRed:62/255.0 green:173/255.0 blue:176/255.0 alpha:1.0];
    //设置字体颜色
    bar.tintColor = [UIColor whiteColor];
    [bar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UINavigationController *  navController = [UINavigationController new];
    navController.navigationBar.clipsToBounds = NO;
    navController.navigationBar.hidden = NO;
    
    [navController.navigationBar
     setBackgroundImage:[UIImage imageNamed:@"pixel_blank"]
     forBarMetrics:UIBarMetricsDefault];
    [navController.navigationBar
     setShadowImage:[UIImage imageNamed:@"pixel_blank"]];
    navController.navigationBar.barStyle = UIBarMetricsDefault;
    
    [navController pushViewController:rootVC animated:NO];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
