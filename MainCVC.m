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
#import "NoteVC.h"
#import "MapVC.h"


@interface MainCVC ()
@property (weak, nonatomic) IBOutlet UIImageView *menu;
@property (weak, nonatomic) IBOutlet UIImageView *addNote;
@property (nonatomic, weak) CBLDatabase *db;
@property (nonatomic) BOOL debug;
@property (nonatomic) Profile *profile;
@property (nonatomic, weak) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIImageView *favsView;
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
    
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
    
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = YES;
    
    [self initDataSource];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForNew)];
    singleTap.numberOfTapsRequired = 1;
    self.addNote.userInteractionEnabled = YES;
    [self.addNote addGestureRecognizer:singleTap];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForFavs)];
    self.favsView.userInteractionEnabled = YES;
    [self.favsView addGestureRecognizer:singleTap];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForMenu)];
    self.menu.userInteractionEnabled = YES;
    [self.menu addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
    [doubleTapFolderGesture setNumberOfTapsRequired:2];
    [doubleTapFolderGesture setNumberOfTouchesRequired:1];
    [self.collView addGestureRecognizer:doubleTapFolderGesture];
    
}


#pragma mark Button related methods


-(void) addTapDetectedForMenu
{
    [self.revealController showViewController:[self.revealController leftViewController]];
}

-(void) processDoubleTap:(UIGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self.collView];
        NSIndexPath *indexPath = [self.collView indexPathForItemAtPoint:point];
        if (indexPath)
        {
            Note* note = (Note*)[self.data objectAtIndex:indexPath.section];
            NoteVC *new = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"newNoteVC"];
            new.userID = self.userID;
            new.note = note;
            [self.revealController setFrontViewController:new];
        }
    }
}

-(void)addTapDetectedForNew {
    NoteVC *new = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"newNoteVC"];
    new.userID = self.userID;
    new.note = nil;
    [self.revealController setFrontViewController:new];
}

-(void)addTapDetectedForFavs {

    NSError *error;
    NSMutableArray *newData = [[NSMutableArray alloc]init];
    CBLQuery *notes = [Note getFavNotesFromDB:self.db forUserID:self.userID];
    notes.descending = YES;
    CBLQueryEnumerator *rowEnum = [notes run:&error];
    for (CBLQueryRow* row in rowEnum) {
        Note *note = [Note getNoteFromDB:self.db withID:row.value];
        [newData addObject:note];
    }
    self.data = newData;
    [self.collView reloadData];
}


- (IBAction)doFavButton:(UIButton*)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.collView];
    NSIndexPath *indexPath = [self.collView indexPathForItemAtPoint:buttonPosition];
    Note *note;
    note = (Note*)[self.data objectAtIndex:indexPath.section];
    NSError *error;
    if (note.isFav) {
        ((Note*)[self.data objectAtIndex:indexPath.section]).isFav = NO;
        [note save:&error];
        UIImage *btnImage = [UIImage imageNamed:@"star-off"];
        sender.selected = NO;
        [sender setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        ((Note*)[self.data objectAtIndex:indexPath.section]).isFav = YES;
        [note save:&error];
        UIImage *btnImage = [UIImage imageNamed:@"star-on"];
        sender.selected = YES;
        [sender setImage:btnImage forState:UIControlStateSelected];
    }
    if (error) {
        NSLog(@"Error while trying to add to favorites");
    }
}



#pragma mark other


-(void) reloadData
{
    [self.collView reloadData];
}

-(void) initDataSource
{
    // init data source object
    NSError *error;
    CBLQuery *notes = [Note getAllNotesInDB:self.db forUserID:self.userID];
    notes.descending = YES;
    CBLQueryEnumerator *rowEnum = [notes run:&error];
    for (CBLQueryRow* row in rowEnum) {
        Note *note = [Note getNoteFromDB:self.db withID:row.value];
        [self.data addObject:note];
    }
}

-(void) initDataSourceRecent
{
    [self initDataSource];
    NSMutableArray *new_data = [[NSMutableArray alloc] init];
    for (Note* note in self.data) {
        if (note.created >= [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60]) {
            [new_data addObject:note];
        }
    }
    self.data = new_data;
    }

-(void) displayForTag:(NSString*)tag
{
    NSMutableArray *new_data = [[NSMutableArray alloc] init];
    for (Note* note in self.data) {
        if ([note.tags containsObject:tag])
            [new_data addObject:note];
    }
    self.data = new_data;
}

-(void) displayFavs
{
    NSMutableArray *new_data = [[NSMutableArray alloc] init];
    for (Note* note in self.data) {
        if (note.isFav)
            [new_data addObject:note];
    }
    self.data = new_data;
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
    UILabel *date = (UILabel*) [cell viewWithTag:102];
    UIButton *fav = (UIButton*) [cell viewWithTag:200];
    
    subject.text = note.subject;
    body.text = note.body;
    date.text = [NSDateFormatter localizedStringFromDate:note.updated
                                               dateStyle:NSDateFormatterShortStyle
                                               timeStyle:NSDateFormatterShortStyle];
    
    UIImage *btnImageOn = [UIImage imageNamed:@"star-on"];
    UIImage *btnImageOff = [UIImage imageNamed:@"star-off"];
    if (note.isFav > 0) {
        fav.selected = YES;
        [fav setImage:btnImageOn forState:UIControlStateSelected];
    }
    else {
        fav.selected = NO;
        [fav setImage:btnImageOff forState:UIControlStateNormal];
    }
  
    return cell;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
