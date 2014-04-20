//
//  Note.h
//  flexi
//
//  Created by Kamil Smuga on 4/12/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <CouchbaseLite/CouchbaseLite.h>
#import "Profile.h"

@interface Note : CBLModel

+(CBLQuery*) getNoteInDB: (CBLDatabase*)db
               forUserID: (NSString*)userID
             withSubject: (NSString*)subject;

+(CBLQuery*) getNotesInDB: (CBLDatabase*)db
                forUserID: (NSString*)userID
                  withTag: (NSString*)tag;

+(CBLQuery*) getAllNotesInDB: (CBLDatabase*)db
              forUserID: (NSString*)userID;

+(CBLQuery*) getFavNotesFromDB:(CBLDatabase *)db
                  forUserID:(NSString *)userID;

+(CBLQuery*) getTagsFromDB:(CBLDatabase *)db
                 forUserID:(NSString *)userID;

-(instancetype) initNoteInDB: (CBLDatabase*)db
                   forUserID: (NSString*)userID
                 withSubject: (NSString*)subject
                    withBody: (NSString*)body
               withLongitute: (NSString*)longitude
                withLatitude: (NSString*)latitude
                    withTags: (NSArray*)tags;

+(instancetype) getNoteFromDB: (CBLDatabase*) db
                       withID: (NSString*) noteID;

// headline
@property (readwrite) NSString *subject;

// content of note
@property (readwrite) NSString *body;

// owner of a doc
@property (readwrite) NSString* ownerID;

// people to share doc with
@property (readwrite) NSArray *members;

// tags
@property (readwrite) NSArray *tags;

// coordinates of note creation
@property (readwrite) NSString *latitute;
@property (readwrite) NSString *longitude;

// date of creation
@property (readwrite) NSDate *created;

// date of update
@property (readwrite) NSDate *updated;

// type - note
@property (readwrite) NSString* type;

@property (readwrite) bool isFav;

@end
