//
//  ProfileViewController.h
//  flexi
//
//  Created by Kamil Smuga on 11/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Profile.h"
#import "PKRevealController.h"

@interface MenuVC : UIViewController 
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) Profile *profile;
@property (strong, nonatomic) NSMutableData *picture;

@end
