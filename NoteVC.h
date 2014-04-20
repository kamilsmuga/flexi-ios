//
//  NewNoteVC.h
//  flexi
//
//  Created by Kamil Smuga on 16/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import <CoreLocation/CoreLocation.h>
#import "PKRevealController.h"
#import "TITokenField.h"
#import "Note.h"

@interface NoteVC : UIViewController <CLLocationManagerDelegate, TITokenFieldDelegate, UITextViewDelegate>
@property (nonatomic, weak) CBLDatabase *db;
@property (strong, nonatomic) NSString* userID;
@property (strong, nonatomic) Note* note;
@end
