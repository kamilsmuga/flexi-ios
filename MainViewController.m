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

@interface MainViewController ()
@property (nonatomic, weak) CBLDatabase *db;
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
    
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    NSString *email = [user objectForKey:@"email"];
    
    CBLQuery *q = [Profile queryProfilesInDatabase:self.db];
    
    
    NSError *error = nil;
    CBLQueryEnumerator *rowEnum = [q run: &error];
    for (CBLQueryRow* row in rowEnum) {
        NSLog(@"Doc ID = %@", row.key);
    }
    
    Profile *test = [Profile profileInDatabase:self.db  forUserID:email];
    
    if (!test) {
        NSError *error = nil;
        Profile *profile = [[Profile alloc] initCurrentUserProfileInDatabase:self.db withName:user.name andUserID:email];
        if (error) {
            NSLog(@"Cos poszlo nie tak przy zapisywaniu do bazy profilu!");
        }
        [profile save:&error];
        NSLog(@"New user!");
    }
    else {
        NSLog(@"Stary pryk");
    }
    
    self.FBPicOutlet.profileID = user.id;
    self.nameLabel.text = user.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
