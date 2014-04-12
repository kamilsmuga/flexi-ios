//
//  DBTestDataFeed.h
//  flexi
//
//  Created by Kamil Smuga on 4/12/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface DBTestDataFeed : NSObject

+(void)populateRandomNotesInDB: (CBLDatabase*)db
                     forUserID: (NSString*)userID;

@end
