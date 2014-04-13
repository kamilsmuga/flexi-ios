//
//  PKRevealControllerCustom.m
//  flexi
//
//  Created by Kamil Smuga on 4/13/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "PKRevealControllerCustom.h"
#import "PKRevealController.h"
#import "SearchViewController.h"

@interface PKRevealControllerCustom
@property (strong, nonatomic) PKRevealController *revealController;
@end

@implementation PKRevealControllerCustom
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.revealController = (PKRevealController *)self.window.rootViewController;
    UIViewController *rightViewController = [[SearchViewController alloc] init];
    SearchViewController *frontViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"frontViewController"];
    [self.revealController setFrontViewController:frontViewController];
    [self.revealController setRightViewController:rightViewController];
    return YES;
}
@end
