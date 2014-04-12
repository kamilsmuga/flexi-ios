//
//  DBTestDataFeed.m
//  flexi
//
//  Created by Kamil Smuga on 4/12/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "DBTestDataFeed.h"
#import "Note.h"

@interface DBTestDataFeed ()

@end

@implementation DBTestDataFeed

+(void)populateRandomNotesInDB: (CBLDatabase*)db
                     forUserID: (NSString*)userID
{
    NSArray *subjects = [NSArray arrayWithObjects:@"training results 12/04/14",
                         @"shopping list",
                         @"lorem ipsum",
                         nil];
    NSArray *bodies = [NSArray arrayWithObjects: @"weight: 79 \nduration: 59 \ncal: 700 \ndistance: 7.0",
                       @"bread \n chicken breast \n 6x Tyskie",
                       @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?",
                       nil];
    
    NSArray *latitudes = [NSArray arrayWithObjects:@"53.3243201", @"53.3198362", @"41.9100711", nil];
    NSArray *longitudes = [NSArray arrayWithObjects:@"-6.251695", @"-6.2566939", @"12.5359979", nil];
    
    NSError *error;
    
    for (int i = 0; i < [subjects count]; i++) {
        Note* note = [[Note alloc] initNoteInDB:db forUserID:userID withSubject:subjects[i] withBody:bodies[i] withLongitute:longitudes[i] withLatitude:latitudes[i]];
    
        [note save:&error];
        
        if (error) {
            NSLog(@"Oops. Sth went wrong while trying to persist notes!");
        }
        else {
            NSLog(@"Succesfully added note with ID: %@ to DB!", note.document.documentID);
        }
    }
}

@end
