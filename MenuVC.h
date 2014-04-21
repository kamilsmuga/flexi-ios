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

@interface MenuVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) Profile *profile;
@property (strong, nonatomic) NSMutableData *picture;
@property (nonatomic, readwrite) NSMutableArray *data;

@end
