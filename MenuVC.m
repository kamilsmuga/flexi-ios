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
@property (weak, nonatomic) IBOutlet UIView *favs;
@property (strong, nonatomic) NSMutableDictionary *tagsSource;
@property (weak, nonatomic) IBOutlet UIView *tag1;
@property (weak, nonatomic) IBOutlet UIView *tag2;
@property (weak, nonatomic) IBOutlet UIView *tag3;
@property (weak, nonatomic) IBOutlet UIView *tag4;
@property (weak, nonatomic) IBOutlet UIView *tag5;
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

-(NSMutableArray*) data
{
    if (!_data) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
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
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForFavs)];
    self.favs.userInteractionEnabled = YES;
    [self.favs addGestureRecognizer:singleTap];
    }

-(void)addTapDetectedForTag:(MYTapGestureRecognizer *)sender
{
    MainCVC *main = ((MainCVC*)self.revealController.frontViewController);
    [main displayForTag:sender.name];
    [main reloadData];
}

-(void)addTapDetectedForFavs
{
    MainCVC *main = ((MainCVC*)self.revealController.frontViewController);
    [main displayFavs];
    [main reloadData];
    [[main revealController] showViewController:main];
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
    
    UILabel *tag = (UILabel*) [cell viewWithTag:300];
    [tag setText:[self.data objectAtIndex:indexPath.section]];
    
    return cell;
    
}


-(void) viewDidAppear:(BOOL)animated
{
    
    self.tagsSource = nil;
    
    [self.data addObjectsFromArray:[self sortedTags]];
    [self updateTagsOnUI];
    
    MYTapGestureRecognizer *mySingleTap = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForTag:)];
    MYTapGestureRecognizer *mySingleTap2 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForTag:)];
    MYTapGestureRecognizer *mySingleTap3 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForTag:)];
    MYTapGestureRecognizer *mySingleTap4 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForTag:)];
    MYTapGestureRecognizer *mySingleTap5 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapDetectedForTag:)];
    
    mySingleTap.name = ((UILabel*) [self.view viewWithTag:1]).text;
    self.tag1.userInteractionEnabled = YES;
    [self.tag1 addGestureRecognizer:mySingleTap];
    
    mySingleTap2.name = ((UILabel*) [self.view viewWithTag:2]).text;
    self.tag2.userInteractionEnabled = YES;
    [self.tag2 addGestureRecognizer:mySingleTap2];
    
    mySingleTap3.name = ((UILabel*) [self.view viewWithTag:3]).text;
    self.tag3.userInteractionEnabled = YES;
    [self.tag3 addGestureRecognizer:mySingleTap3];
    
    mySingleTap4.name = ((UILabel*) [self.view viewWithTag:4]).text;
    self.tag4.userInteractionEnabled = YES;
    [self.tag4 addGestureRecognizer:mySingleTap4];
    
    mySingleTap5.name = ((UILabel*) [self.view viewWithTag:5]).text;
    self.tag5.userInteractionEnabled = YES;
    [self.tag5 addGestureRecognizer:mySingleTap5];

}

-(void) updateTagsOnUI
{
    if ([self.data count] == 0) {
        [self.data addObjectsFromArray:[self sortedTags]];
    }
    int size = [self.data count];
    if (size > 5) {
        size = 5;
    }
    for (int i=0; i<size; i++) {
        NSString *tag = [self.data objectAtIndex:i];
        UILabel *label = (UILabel*) [self.view viewWithTag:i+1];
        [label setText:tag];
    }
}

-(NSArray*) sortedTags
{
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
    
    return myArray;
}

@end



@implementation MYTapGestureRecognizer

@end
