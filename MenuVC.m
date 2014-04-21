//
//  ProfileViewController.m
//  flexi
//
//  Created by Kamil Smuga on 11/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "MenuVC.h"
#import "MapVC.h"
#import "MainCVC.h"
#import "Note.h"
#import "flexiAppDelegate.h"

@interface MenuVC ()
@property (weak, nonatomic) IBOutlet UIView *places;
@property (strong, nonatomic) NSMutableDictionary *tagsSource;
@property (strong, nonatomic) CBLDatabase *db;
@end

@implementation MenuVC


-(CBLDatabase *)db
{
    if (!_db) {
        _db = ((flexiAppDelegate*)[UIApplication sharedApplication].delegate).database;
    }
    return _db;
}

-(NSMutableDictionary*) tagsSource
{
    if (!_tagsSource) {
        _tagsSource = [[NSMutableDictionary alloc] init];
        CBLQuery *q = [Note getTagsFromDB:self.db forUserID:((MainCVC*)self.revealController.frontViewController).userID];
        NSError *error;
        CBLQueryEnumerator *rowEnum = [q run:&error];
        for (CBLQueryRow *row in rowEnum)
        {
            Note *note = [Note getNoteFromDB:self.db withID:row.value];
            for (NSString *tag in note.tags) {
                if ([_tagsSource objectForKey:tag]) {
                    NSString *val = [_tagsSource valueForKey:tag];
                    int valInt = [val intValue];
                    valInt += 1;
                    [_tagsSource setValue:[NSString stringWithFormat:@"%d", valInt] forKey:tag];
                }
                else
                    [_tagsSource setValue:[NSString stringWithFormat:@"%d", 1] forKey:tag];
            }
        }
    }
    return _tagsSource;
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
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForPlaces)];
    self.places.userInteractionEnabled = YES;
    [self.places addGestureRecognizer:singleTap];

}

-(void)addTapDetectedForPlaces
{
    MapVC *map = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mapVC"];
    map.data = ((MainCVC*)self.revealController.frontViewController).data;
    map.userID = ((MainCVC*)self.revealController.frontViewController).userID;
    [self.revealController setFrontViewController:map];
    [self.revealController showViewController:[self.revealController frontViewController] animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
  //  note = (Note*)[self.data objectAtIndex:indexPath.section];

    
    return cell;
    
}

-(void) viewDidAppear:(BOOL)animated
{
    
    self.tagsSource = nil;
     for (id key in self.tagsSource) {
     NSLog(@"key: %@, value: %@ \n", key, [self.tagsSource objectForKey:key]);
     }
    
    NSArray *myArray;
    
    myArray = [self.tagsSource keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    for (id obj in myArray) {
        NSLog(@"sorted obj: %@", obj);
    }
}

@end