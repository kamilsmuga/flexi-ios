//
//  NoteMapAnnotation.m
//  flexi
//
//  Created by Kamil Smuga on 4/17/14.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "NoteMapAnnotation.h"

@implementation NoteMapAnnotation
@synthesize coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)coord
{

    self.coordinate = coord;
    
}

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}


@end