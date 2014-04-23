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
@property (nonatomic, strong) UILabel *tag;
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

-(NSMutableArray*) cellViews
{
    if (!_cellViews) {
        _cellViews = [[NSMutableArray alloc] init];
    }
    return _cellViews;
}

-(UILabel*) tag
{
    if (!_tag) {
        _tag = [[UILabel alloc] init];
    }
    return _tag;
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
        sender.selected = NO;
        [sender reloadInputViews];

    }
    else {
        ((Note*)[self.data objectAtIndex:indexPath.section]).isFav = YES;
        [note save:&error];
        sender.selected = YES;
        [sender reloadInputViews];
    }
    if (error) {
        NSLog(@"Error while trying to add to favorites");
    }
}

- (IBAction)doDeleteButton:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.collView];
    NSIndexPath *indexPath = [self.collView indexPathForItemAtPoint:buttonPosition];
    Note *note;
    NSError *error;
    note = (Note*)[self.data objectAtIndex:indexPath.section];
    
        [self.data removeObject:note];
        [note deleteDocument:&error];
        [self.collView reloadData];
}

- (IBAction)doEditButton:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.collView];
    NSIndexPath *indexPath = [self.collView indexPathForItemAtPoint:buttonPosition];
    Note *note;
    note = (Note*)[self.data objectAtIndex:indexPath.section];
    NoteVC *new = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"newNoteVC"];
    new.userID = self.userID;
    new.note = note;
    [self.revealController setFrontViewController:new];
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
        if ([note.created compare:[NSDate dateWithTimeIntervalSinceNow:-7*24*60*60]] == NSOrderedDescending) {
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
    UIButton *favs = (UIButton*) [cell viewWithTag:400];
    
    subject.text = note.subject;
    body.text = note.body;
    date.text = [NSDateFormatter localizedStringFromDate:note.updated
                                               dateStyle:NSDateFormatterShortStyle
                                               timeStyle:NSDateFormatterShortStyle];

    // render proper image for favorites button
    if (note.isFav) {
        favs.selected = YES;
        [favs reloadInputViews];
    }
    
    // display tags
    CGPoint offset = CGPointMake(13.0, 160.0);
    
    for (int i=0; i<[note.tags count]; i++) {
        self.tag = [[UILabel alloc] init];
        self.tag.frame = CGRectMake(offset.x, offset.y, 20.0, 15.0);
        NSMutableString *str = [[NSMutableString alloc] initWithString:@" "];
        [str appendString:note.tags[i]];
        [str appendString:@" "];
        self.tag.text = str;
        self.tag.font = [UIFont boldSystemFontOfSize:10.0];
        self.tag.textColor = [UIColor whiteColor];
        self.tag.backgroundColor = [UIColor purpleColor];
        [self.tag sizeToFit];
        [self.tag.layer setMasksToBounds:YES];
        [self.tag.layer setCornerRadius:5.0];
        [cell addSubview:self.tag];
        offset.x = offset.x + self.tag.frame.size.width +2;
        
    }
    
    [self.cellViews addObject:cell];
    return cell;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
