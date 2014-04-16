//
//  MainViewController.m
//  flexi
//
//  Created by Kamil Smuga on 3/15/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "MainCVC.h"
#import "Profile.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "flexiAppDelegate.h"
#import "DBTestDataFeed.h"
#import "Note.h"
#import "PKRevealController.h"
#import "NewNoteVC.h"

@interface MainCVC ()
@property (weak, nonatomic) IBOutlet UIImageView *addNote;
@property (nonatomic, weak) CBLDatabase *db;
@property (nonatomic) BOOL debug;
@property (nonatomic) Profile *profile;
@property (weak, nonatomic) IBOutlet UIImageView *map;
@property (nonatomic, readwrite) NSMutableArray *data;
@end

@implementation MainCVC

-(NSMutableArray*) data
{
    if (!_data) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

-(CBLDatabase *)db
{
    if (!_db) {
        _db = ((flexiAppDelegate*)[UIApplication sharedApplication].delegate).database;
    }
    return _db;
}

-(Profile*) profile
{
    if (!_profile) {
        _profile = [Profile profileInDatabase:self.db forUserID:self.userID];
    }
    return _profile;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = YES;
    if (!self.picture.image) {
        [self loadPictureAndName];
    }
    
    
    // init data source object
    NSError *error;
    CBLQuery *notes = [Note allNotesInDB:self.db forUserID:self.userID];
    notes.descending = YES;
    CBLQueryEnumerator *rowEnum = [notes run:&error];
    for (CBLQueryRow* row in rowEnum) {
        Note *note = [Note getNoteFromDB:self.db withID:row.value];
        [self.data addObject:note];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForNew)];
    singleTap.numberOfTapsRequired = 1;
    self.addNote.userInteractionEnabled = YES;
    [self.addNote addGestureRecognizer:singleTap];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForMap)];
    self.map.userInteractionEnabled = YES;
    [self.map addGestureRecognizer:singleTap];
}

-(void)addTapDetectedForMap {
    
    [self.revealController setRightViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mapVC"]];
    [self.revealController showViewController:[self.revealController rightViewController]];
}

-(void)addTapDetectedForNew {
    NewNoteVC *new = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"newNoteVC"];
    new.db = self.db;
    new.userID = self.userID;
    [self.revealController setFrontViewController:new];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    if (!self.picture.image) {
        [self loadPictureAndName];
    }
}

-(void)loadPictureAndName
{
    CBLAttachment *at = [self.profile attachmentNamed:@"profilePicture"];
    NSData *imgData = [at content];
    UIImage *img = [UIImage imageWithData:imgData];
    self.picture = [self.picture initWithImage:img];
    self.picture.userInteractionEnabled = YES;
    self.nameLabel.text = [self.profile.name componentsSeparatedByString:@" "][0];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    [super touchesBegan:touches withEvent:event];
    if ([touch view] == self.picture) {
        [self.revealController showViewController:self.revealController.leftViewController];
    }
}

#pragma mark Collection View Methods

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_data count];
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return 1;
    
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    Note *note;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"noteCell" forIndexPath:indexPath];
    note = (Note*)[self.data objectAtIndex:indexPath.section];
    
    UILabel *subject = (UILabel*) [cell viewWithTag:100];
    UILabel *body = (UILabel*) [cell viewWithTag:101];
    
    subject.text = note.subject;
    body.text = note.body;

    return cell;
    
}

@end
