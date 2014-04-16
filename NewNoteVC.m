//
//  NewNoteVC.m
//  flexi
//
//  Created by Kamil Smuga on 16/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "NewNoteVC.h"
#import "flexiAppDelegate.h"
#import "Note.h"
#import "MainCVC.h"


@interface NewNoteVC ()
@property (weak, nonatomic) IBOutlet UITextView *bodyText;
@property (weak, nonatomic) IBOutlet UITextView *subjectText;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@end

@implementation NewNoteVC 


-(CBLDatabase *)db
{
    if (!_db) {
        _db = ((flexiAppDelegate*)[UIApplication sharedApplication].delegate).database;
    }
    return _db;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)done:(id)sender {
    CLLocationCoordinate2D location = [self getLocation];
    Note *note = [[Note alloc] initNoteInDB:self.db forUserID:self.userID withSubject:self.subjectText.text withBody:self.bodyText.text withLongitute:[NSString stringWithFormat:@"%lf", location.longitude] withLatitude:[NSString stringWithFormat:@"%lf", location.latitude]];
    NSError *error;
    [note save:&error];
    if (error) {
        NSLog(@"Error when saving new note. This is bad!");
    }
    MainCVC *main = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainCVC"];
    main.userID = self.userID;
    [self.revealController setFrontViewController:main];
    
    
}
- (IBAction)cancel:(id)sender {
    MainCVC *main = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainCVC"];
    main.userID = self.userID;
    [self.revealController setFrontViewController:main];
}

-(CLLocationCoordinate2D) getLocation{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    return coordinate;
}
@end
