//
//  Profile.h
//  flexi
//
//  Created by Kamil Smuga on 3/15/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//


#import <CouchbaseLite/CouchbaseLite.h>

@interface Profile : CBLModel

// return all profiles in DB
+ (CBLQuery*) queryProfilesInDatabase: (CBLDatabase*)db;

// find a profile using user ID
+ (instancetype) profileInDatabase: (CBLDatabase*)db forUserID: (NSString*)userID;

// init DB with provided details
- (instancetype) initCurrentUserProfileInDatabase: (CBLDatabase*)database
                                         withName: (NSString*)name
                                        andUserID: (NSString*)userId;

// full user name
@property (readwrite) NSString* name;

// user ID - email
@property (readwrite) NSString* userID;

// type - profile
@property (readwrite) NSString* type;

// member since date
@property (readwrite) NSDate* joined;

// last login
@property (readwrite) NSDate* lastLogin;

@end