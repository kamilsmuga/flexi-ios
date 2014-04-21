//
//  ProfileViewController.m
//  flexi
//
//  Created by Kamil Smuga on 11/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "MenuVC.h"
#import "MapVC.h"
#import "MainCVC.h"

@interface MenuVC ()
@property (weak, nonatomic) IBOutlet UIView *places;

@end

@implementation MenuVC

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
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForPlaces)];
    self.places.userInteractionEnabled = YES;
    [self.places addGestureRecognizer:singleTap];

}

-(void)addTapDetectedForPlaces
{
    MapVC *map = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mapVC"];
    map.data = ((MainCVC*)self.revealController.frontViewController).data;
    map.userID = ((MainCVC*)self.revealController.frontViewController).userID;
    [self.revealController setFrontViewController:map];
    [self.revealController showViewController:[self.revealController frontViewController] animated:YES completion:nil];
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
