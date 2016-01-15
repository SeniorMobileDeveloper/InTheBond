//
//  AppDelegate.m
//  InTheBond
//
//  Created by Nala on 6/28/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "AppDelegate.h"
#import <Quickblox/Quickblox.h>
#import "ChatService.h"
#import "SVProgressHUD.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [QBApplication sharedApplication].applicationId = 23967;
    [QBConnection registerServiceKey:@"jhuDYc5j7aUs4kW"];
    [QBConnection registerServiceSecret:@"cXGYwaYZg-WYVWY"];
    [QBSettings setAccountKey:@"Y7nzbpzpWPz7s7mZKktS"];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[ChatService shared] logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([QBChat instance].currentUser == nil){
        return;
    }
    [SVProgressHUD showWithStatus:@"Restoring chat session"];
    [[ChatService shared] loginWithUser:[QBChat instance].currentUser completionBlock:^{
        [SVProgressHUD dismiss];
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Subscribe to push notifications
    //
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //
    [QBRequest registerSubscriptionForDeviceToken:deviceToken uniqueDeviceIdentifier:deviceIdentifier
                                     successBlock:^(QBResponse *response, NSArray *subscriptions) {
                                         
                                     } errorBlock:^(QBError *error) {
                                         
                                     }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"New Push received\n: %@", userInfo);
}
@end
