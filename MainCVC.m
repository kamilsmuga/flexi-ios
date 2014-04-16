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

@interface MainCVC ()
@property (nonatomic, weak) CBLDatabase *db;
@property (nonatomic) BOOL debug;
@property (nonatomic) Profile *profile;
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
    
    NSError *error;
    CBLQuery *notes = [Note allNotesInDB:self.db forUserID:self.userID];
    CBLQueryEnumerator *rowEnum = [notes run:&error];
    for (CBLQueryRow* row in rowEnum) {
        NSArray *item = [[NSArray alloc] initWithObjects:row.value, row.key, nil];
        [self.data addObject:item];
    }

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
    NSArray *array = [_data objectAtIndex:section];
    return [array count];
    
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    Note *note;
    if (indexPath.item % 2) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bodyC" forIndexPath:indexPath];
        note = [Note getNoteFromDB:self.db withID:[[self.data objectAtIndex:indexPath.section] objectAtIndex:indexPath.item]];
        UILabel *label = (UILabel*) [cell viewWithTag:100];
        label.text = note.body;
    }
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"labelC" forIndexPath:indexPath];
        UILabel *label = (UILabel*) [cell viewWithTag:100];
        label.text = [[self.data objectAtIndex:indexPath.section] objectAtIndex:indexPath.item];
    }
    

    // [NSString stringWithFormat:@"section:%d, Item: %d" , indexPath.section, indexPath.item];
    //[cell.layer setBorderWidth:2.0f];
    // [cell.layer setBorderColor:[UIColor blackColor].CGColor];
    
    return cell;
    
}

@end
