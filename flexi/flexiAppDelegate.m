//
//  flexiAppDelegate.m
//  flexi
//
//  Created by Kamil Smuga on 16/01/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "flexiAppDelegate.h"
#import "LoginVC.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PKRevealController.h"
#import "SearchVC.h"
#import "ProfileVC.h"


// name of local database stored in iOS
#define localDBName @"flexi-sync"
// remote DB URL
#define remoteDBUrl @"http://sync.couchbasecloud.com/flexidb/"
// #define kFBAppId @"241876219329233"

@interface flexiAppDelegate () <PKRevealing>

@property (strong, nonatomic) PKRevealController *revealController;

@end


@implementation flexiAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class];

    // store remoteDBUrl in UserDefaults
    #ifdef remoteDBUrl
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *appdefaults = [NSDictionary dictionaryWithObject:remoteDBUrl
                                                            forKey:@"syncpoint"];
        [defaults registerDefaults:appdefaults];
        [defaults synchronize];
    #endif
    
    // create or attach to a local DB in iOS
    CBLManager *manager = [CBLManager sharedInstance];
    NSError *error;
    self.database = [manager databaseNamed: @"flexi" error: &error];
    if (error) {
        NSLog(@"error getting database %@",error);
        exit(-1);
    }
    
    
    // Step 1: Create your controllers.

    LoginVC *frontViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginVC"];
    
    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
    SearchVC *rightViewController = [[SearchVC alloc] init];
    rightViewController.view.backgroundColor = [UIColor redColor];
    ProfileVC *leftViewController = [[ProfileVC alloc] init];
    
    
    // Step 2: Instantiate.
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontNavigationController
                                                                     leftViewController:leftViewController
                                                                    rightViewController:rightViewController];
    // Step 3: Configure.
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    
    // Step 4: Apply.
    self.window.rootViewController = self.revealController;
    
    [self.window makeKeyAndVisible];

    
    
        return YES;
    
    
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
