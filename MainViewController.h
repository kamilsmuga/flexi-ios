//
//  MainViewController.h
//  flexi
//
//  Created by Kamil Smuga on 3/15/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MainViewController : UIViewController <FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *picture;
@property (strong, nonatomic) NSString* userID;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end
