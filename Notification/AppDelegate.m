//
//  AppDelegate.m
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "NSObject+Notification.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self addObserver:self block:^(Notification * _Nonnull notification) {
        NSLog(@"-------123-----test1--");
    } name:@"Test" object:nil];
    
    [self addObserver:self selector:@selector(updateWithNotification:address:telphone:) name:@"PersonInfo" object:nil];
    [self addObserver:self block:^(Notification * _Nonnull notification, NSString * _Nonnull address, NSString *telphone) {
        NSLog(@"block address:%@, telphone:%@", address, telphone);
    } name:@"PersonInfo" object:nil];
    
    ViewController *viewController = [[ViewController alloc] init];
    self.window.rootViewController = viewController;
    
    
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self removeObserver:self];
    
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

- (void)updateWithNotification:(NSNotification *)notification address:(NSString *)address telphone:(NSString *)telphone
{
    NSLog(@"SEL address:%@, telphone:%@", address, telphone);
}

@end
