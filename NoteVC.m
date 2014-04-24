//
//  NewNoteVC.m
//  flexi
//
//  Created by Kamil Smuga on 16/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "NoteVC.h"
#import "flexiAppDelegate.h"
#import "MainCVC.h"


@interface NoteVC ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *newTags;
@property (strong, nonatomic) NSArray *existingTags;
@property (strong, nonatomic) NSMutableArray *tagsSource;
@property (weak, nonatomic) IBOutlet UIImageView *done;
@property (weak, nonatomic) IBOutlet UIImageView *cancel;

@end

@implementation NoteVC {
    TITokenFieldView * _tokenFieldView;
}


-(NSMutableArray*) tagsSource
{
    if (!_tagsSource) {
        _tagsSource = [[NSMutableArray alloc] init];
        CBLQuery *q = [Note getTagsFromDB:self.db forUserID:self.userID];
        NSError *error;
        CBLQueryEnumerator *rowEnum = [q run:&error];
        for (CBLQueryRow *row in rowEnum)
        {
            Note *note = [Note getNoteFromDB:self.db withID:row.value];
            for (NSString *tag in note.tags) {
                if ([_tagsSource containsObject:tag]) {
                    continue;
                }
                [self.tagsSource addObject:tag];
            }
        }
    }
    return _tagsSource;
}

-(NSArray*) existingTags
{
    if (!_existingTags) {
        if (_note) {
            _existingTags = [[NSMutableArray alloc] init];
            _existingTags = _note.tags;
        }
    }
    return _existingTags;
}

-(NSArray*) newTags
{
    if (!_newTags) {
        _newTags = [[NSArray alloc]init];
    }
    return _newTags;
}

-(CBLDatabase *)db
{
    if (!_db) {
        _db = ((flexiAppDelegate*)[UIApplication sharedApplication].delegate).database;
    }
    return _db;
}

-(CLLocationManager*) locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
 
    _tokenFieldView = [[TITokenFieldView alloc] initWithFrame:CGRectMake(0.0, 64, self.view.frame.size.width, self.view.frame.size.height/2)];
    [_tokenFieldView setSourceArray:self.tagsSource];
	[self.view addSubview:_tokenFieldView];
    [_tokenFieldView.tokenField setDelegate:self];
	[_tokenFieldView setShouldSearchInBackground:NO];
	[_tokenFieldView setShouldSortResults:NO];
    
	[_tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]];
    // Default is a comma
    [_tokenFieldView.tokenField setPromptText:@"Tags:"];
	[_tokenFieldView.tokenField setPlaceholder:@"Enter associated tags"];
    
    [_tokenFieldView.tokenField addTokensWithTitleArray:self.existingTags];
    
    if (self.note) {
        self.bodyText.text = self.note.body;
        self.subjectText.text = self.note.subject;
    }

    [self.subjectText setDelegate:self];
    [self.bodyText setDelegate:self];
    
    [_tokenFieldView.contentView addSubview:self.subjectText];
    [_tokenFieldView.contentView addSubview:self.bodyText];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetectedForDone)];
    singleTap.numberOfTapsRequired = 1;
    [self.done addGestureRecognizer:singleTap];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetectedForCancel)];
    singleTap.numberOfTapsRequired = 1;
    [self.cancel addGestureRecognizer:singleTap];
    
    [self.bodyText becomeFirstResponder];

}


-(void)tapDetectedForDone {
    CLLocationCoordinate2D location = [self getLocation];
    self.newTags = _tokenFieldView.tokenTitles;
    if (!self.note) {
        self.note = [[Note alloc] initNoteInDB:self.db forUserID:self.userID withSubject:self.subjectText.text withBody:self.bodyText.text withLongitute:[NSString stringWithFormat:@"%lf", location.longitude] withLatitude:[NSString stringWithFormat:@"%lf", location.latitude ] withTags:self.newTags];
    }
    else {
        self.note.subject = self.subjectText.text;
        self.note.body = self.bodyText.text;
        self.note.tags = self.newTags;
        self.note.updated = [NSDate date];
    }
    NSError *error;
    [self.note save:&error];
    if (error) {
        NSLog(@"Error when saving new note. This is bad!");
    }
    MainCVC *main = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainCVC"];
    main.userID = self.userID;
    self.locationManager.delegate = main;
    main.locationManager = self.locationManager;
    [self.revealController setFrontViewController:main];
}

-(void)tapDetectedForCancel {
    
    MainCVC *main = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainCVC"];
    main.userID = self.userID;
    [self.revealController setFrontViewController:main];
   }

-(CLLocationCoordinate2D) getLocation{
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    return coordinate;
}
@end
