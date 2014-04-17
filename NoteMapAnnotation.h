//
//  NoteMapAnnotation.h
//  flexi
//
//  Created by Kamil Smuga on 4/17/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface NoteMapAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *note;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
