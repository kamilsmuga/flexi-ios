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
    
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    self.debug = YES;
    NSError *error = nil;
    
    NSString *email = [user objectForKey:@"email"];
    
    Profile *existingProfile = [Profile profileInDatabase:self.db  forUserID:email];

    if (!existingProfile) {
        Profile *profile = [[Profile alloc] initCurrentUserProfileInDatabase:self.db withName:user.name andUserID:email];
        [profile save:&error];
        if (self.debug) {
            NSLog(@"New user created!");
            NSLog(@"profile email: %@", profile.userID);
            NSLog(@"member since: %@", profile.joined);
            NSLog(@"profile id: %@", [profile getValueOfProperty: @"_id"]);
        }
    }
    else {
        existingProfile.lastLogin = [NSDate date];
        [existingProfile save:&error];
        
        if (self.debug) {
           NSLog(@"This is an existing user.");
           NSLog(@"profile email: %@", existingProfile.userID);
           NSLog(@"member since: %@", existingProfile.joined);
           NSLog(@"last login: %@", existingProfile.lastLogin);
        }
    }
    if (error) {
        NSLog(@"Error while trying to save the profile. This is bad!");
    }
   
    /*
    [DBTestDataFeed populateRandomNotesInDB:self.db forUserID:email];
    
    CBLQuery *q = [Note allNotesInDB:self.db forUserID:email];
    CBLQueryEnumerator *rowEnum = [q run:&error];
    for (CBLQueryRow* row in rowEnum) {
        NSLog(@"Doc id = %@ and subject = %@", row.key, row.value);
    }
    */
    self.FBPicOutlet.profileID = user.id;
    self.nameLabel.text = user.name;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
