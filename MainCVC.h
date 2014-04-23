//
//  MainViewController.h
//  flexi
//
//  Created by Kamil Smuga on 3/15/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>
#import "PKRevealController.h"

@interface MainCVC : UICollectionViewController <FBLoginViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSString* userID;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, readwrite) NSMutableArray *data;

-(void) displayForTag:(NSString*)tag;
-(void) displayFavs;
-(void) initDataSource;
-(void) reloadData;

@end
