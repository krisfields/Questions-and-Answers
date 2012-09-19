//
//  AppDelegate.m
//  LocationProfiler
//
//  Created by Kris Fields on 9/16/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashViewController.h"
#import "QuestionsViewController.h"
#import "CreateAQuestionViewController.h"
#import "ProfilerStore.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    QuestionsViewController *questionsVC = [QuestionsViewController new];
    SplashViewController *splashVC = [SplashViewController new];
    CreateAQuestionViewController *createAQuestionVC = [[CreateAQuestionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *createAQuestionNavController = [[UINavigationController alloc] initWithRootViewController:createAQuestionVC];
    UINavigationController *questionsNavController = [[UINavigationController alloc] initWithRootViewController:questionsVC];
    createAQuestionNavController.navigationBar.tintColor =UIColorFromRGB(0x29264D);
    questionsNavController.navigationBar.tintColor =UIColorFromRGB(0x29264D);
    splashVC.tabBarController = [[UITabBarController alloc] init];
    [[[splashVC tabBarController] tabBar] setBackgroundImage:[UIImage imageNamed:@"bg-purple-footer.png"]];
    [[[splashVC tabBarController] tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"bg-purple-footer-cover.jpg"]];
    splashVC.tabBarController.viewControllers = @[questionsNavController, createAQuestionNavController];
    self.window.rootViewController = splashVC;
    [ProfilerStore setupProfilerStore];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
