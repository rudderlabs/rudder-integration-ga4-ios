//
//  RSAppDelegate.m
//  Rudder-GA4
//
//  Created by Arnab on 11/30/2022.
//  Copyright (c) 2022 Arnab. All rights reserved.
//

#import "RSAppDelegate.h"
#import <Rudder/Rudder.h>
#import "RudderGA4Factory.h"

@implementation RSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *DATA_PLANE_URL = @"https://rudderstacbumvdrexzj.dataplane.rudderstack.com";
    NSString *WRITE_KEY = @"203EnCjvGV6qhvrcaz7MyWiQmJx";
    
    // Override point for customization after application launch.
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withDataPlaneUrl:DATA_PLANE_URL];
    [builder withFactory:[RudderGA4Factory instance]];
    [builder withLoglevel:RSLogLevelNone];
    [builder withTrackLifecycleEvens:@NO];
    [RSClient getInstance:WRITE_KEY config:[builder build]];
    
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
