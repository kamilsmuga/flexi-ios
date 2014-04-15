//
//  MainViewController.m
//  flexi
//
//  Created by Kamil Smuga on 3/15/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "MainViewController.h"
#import "Profile.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "flexiAppDelegate.h"
#import "DBTestDataFeed.h"
#import "Note.h"
#import "PKRevealController.h"

@interface MainViewController ()
@property (nonatomic, weak) CBLDatabase *db;
@property (nonatomic) BOOL debug;
@end

@implementation MainViewController


-(CBLDatabase *)db
{
    if (!_db) {
        _db = ((flexiAppDelegate*)[UIApplication sharedApplication].delegate).database;
    }
    return _db;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.picture.image) {
        [self loadPictureAndName];
    }
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    if (!self.picture.image) {
        [self loadPictureAndName];
    }
}

-(void)loadPictureAndName
{
    Profile *profile = [Profile profileInDatabase:self.db forUserID:self.userID];
    CBLAttachment *at = [profile attachmentNamed:@"profilePicture"];
    NSData *imgData = [at content];
    UIImage *img = [UIImage imageWithData:imgData];
    self.picture = [self.picture initWithImage:img];
    self.picture.userInteractionEnabled = YES;
    self.nameLabel.text = [profile.name componentsSeparatedByString:@" "][0];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    [super touchesBegan:touches withEvent:event];
    if ([touch view] == self.picture) {
        [self.revealController showViewController:self.revealController.leftViewController];
    }
}

@end
