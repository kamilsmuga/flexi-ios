//
//  LoginViewController.h
//  flexi
//
//  Created by Kamil Smuga on 16/01/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PKRevealController.h"

@interface LoginVC : UIViewController <FBLoginViewDelegate, NSURLConnectionDelegate>

@end
