//
//  MapVC.h
//  flexi
//
//  Created by Kamil Smuga on 16/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PKRevealController.h"

@interface MapVC : UIViewController <MKMapViewDelegate>
@property (nonatomic, readwrite) NSMutableArray *data;
@property (nonatomic, strong) NSString *userID;
@end
