//
//  Profile.m
//  flexi
//
//  Created by Kamil Smuga on 3/15/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "Profile.h"

#define kProfileDocType @"profile"

@implementation Profile

+ (CBLQuery*) queryProfilesInDatabase: (CBLDatabase*)db {
    CBLView* view = [db viewNamed: @"profiles"];
    if (!view.mapBlock) {
        // Register the map function, the first time we access the view:
        [view setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString:kProfileDocType])
                emit(doc[@"name"], nil);
        }) reduceBlock: nil version: @"1"]; // bump version any time you change the MAPBLOCK body!
    }
    return [view createQuery];
}

+ (instancetype) profileInDatabase: (CBLDatabase*)db forUserID: (NSString*)userID {
    NSParameterAssert(userID);
    NSString* profileDocId = [@"p:" stringByAppendingString:userID];
    CBLDocument *doc;
    if (profileDocId.length > 0)
        doc = [db documentWithID: profileDocId];
    return doc ? [Profile modelForDocument: doc] : nil;
}

- (instancetype) initCurrentUserProfileInDatabase: (CBLDatabase*)database
                                         withName: (NSString*)name
                                        andUserID: (NSString*)userId
                                         
{
    NSParameterAssert(name);
    NSParameterAssert(userId);
    
    CBLDocument* doc = [database documentWithID: [@"p:" stringByAppendingString:userId]];
    
    self = [super initWithDocument:doc];
    if (self) {
        self.name = name;
        self.user_id = userId;
        self.type = kProfileDocType;
    }
    
    return self;
}

@end