//
//  AppDelegate.h
//  LocationProfiler
//
//  Created by Kris Fields on 9/16/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>


@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;


- (NSURL *)applicationDocumentsDirectory;

@end
