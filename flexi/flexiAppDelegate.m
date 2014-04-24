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
#import "TimelineVC.h"
#import "MenuVC.h"


// name of local database stored in iOS
#define localDBName @"flexi"

@interface flexiAppDelegate () <PKRevealing>

@property (strong, nonatomic) PKRevealController *revealController;

@end


@implementation flexiAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

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
    self.database = [manager databaseNamed: localDBName error: &error];
    if (error) {
        NSLog(@"error getting database %@",error);
        exit(-1);
    }

    // Create front view controller and init PKRevealController

    LoginVC *frontViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginVC"];
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController
                                                                     leftViewController:nil];
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    
    self.window.rootViewController = self.revealController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
