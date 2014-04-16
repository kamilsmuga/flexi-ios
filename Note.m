//
//  Note.m
//  flexi
//
//  Created by Kamil Smuga on 4/12/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "Note.h"

#define kProfileDocType @"note"

@implementation Note

@dynamic subject, body, ownerID, members, latitute, longitude, created, updated, type, tags;

+(CBLQuery*) noteInDB: (CBLDatabase*)db
               forUserID: (NSString*)userID
             withSubject: (NSString*)subject
{
    NSParameterAssert(userID);
    NSParameterAssert(subject);
    NSParameterAssert(db);
    
    CBLView* view = [db viewNamed: @"notesForUserAndSubject"];
    if (!view.mapBlock) {
        // Register the map function, the first time we access the view:
        [view setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString:kProfileDocType] &&
                [doc[@"subject"] isEqualToString:subject] &&
                [doc[@"ownerID"] isEqualToString:userID])
                
                emit(doc[@"_id"], doc[@"subject"]);
        }) reduceBlock: nil version: @"1"]; // bump version any time you change the MAPBLOCK body!
    }
    return [view createQuery];
}

+(CBLQuery*) allNotesInDB:(CBLDatabase *)db
                forUserID:(NSString *)userID
{
    NSParameterAssert(db);
    NSParameterAssert(userID);
    
    CBLView* view = [db viewNamed: @"notesForUser"];
    if (!view.mapBlock) {
        // Register the map function, the first time we access the view:
        [view setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString:kProfileDocType]
               &&[doc[@"ownerID"] isEqualToString:userID])
            
                emit(doc[@"updated"], doc[@"_id"]);
        }) reduceBlock: nil version: @"2"]; // bump version any time you change the MAPBLOCK body!
    }
    return [view createQuery];

}

+(CBLQuery*) notesInDB: (CBLDatabase*)db
             forUserID: (NSString*)userID
               withTag: (NSString*)tag
{
    NSParameterAssert(db);
    NSParameterAssert(userID);
    NSParameterAssert(tag);
    
    CBLView* view = [db viewNamed: [@"notesForTag" stringByAppendingString:tag]];
    if (!view.mapBlock) {
        // Register the map function, the first time we access the view:
        [view setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString:kProfileDocType]
                &&[doc[@"ownerID"] isEqualToString:userID]
                &&[doc[@"tag"] isEqualToString:tag])
                
                emit(doc[@"_id"], doc[@"subject"]);
        }) reduceBlock: nil version: @"1"]; // bump version any time you change the MAPBLOCK body!
    }
    return [view createQuery];
    
}

-(instancetype) initNoteInDB: (CBLDatabase*)db
                   forUserID: (NSString*)userID
                 withSubject: (NSString*)subject
                    withBody: (NSString*)body
               withLongitute: (NSString*)longitude
                withLatitude: (NSString*)latitude
{
    NSParameterAssert(db);
    NSParameterAssert(userID);
    NSParameterAssert(subject);
    NSParameterAssert(body);
    // longitute and laptitute are optional
    
    CBLDocument* doc = [db createDocument];
    
    self = [super initWithDocument:doc];
    if (self) {
        self.subject= subject;
        self.body = body;
        self.ownerID = userID;
        self.type = kProfileDocType;
        self.created= [NSDate date];
        self.updated = self.created;
        self.longitude = longitude;
        self.latitute = latitude;
        self.members = [[NSArray alloc] initWithObjects:userID, nil];
    }
    return self;
}

+(instancetype) getNoteFromDB: (CBLDatabase*) db
                       withID: (NSString*) noteID
{
    NSParameterAssert(db);
    NSParameterAssert(noteID);
    
    CBLDocument *doc = [db existingDocumentWithID:noteID];
    
    return doc ? [Note modelForDocument: doc] : nil;
}

@end
