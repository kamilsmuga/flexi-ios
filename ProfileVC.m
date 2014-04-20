//
//  ProfileViewController.m
//  flexi
//
//  Created by Kamil Smuga on 11/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "ProfileVC.h"

@interface ProfileVC ()


@end

@implementation ProfileVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setProfile:(Profile *)profile
{
    _profile = profile;
    [_name setText:[profile.name componentsSeparatedByString:@" "][0]];
}

-(void)setPicture:(NSMutableData *)picture
{
    _picture = picture;
    UIImage *img = [UIImage imageWithData:picture];
    self.profilePic = [self.profilePic initWithImage:img];
    [self.view reloadInputViews];
}

@end
