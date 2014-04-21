//
//  MapVC.m
//  flexi
//
//  Created by Kamil Smuga on 16/04/2014.
//  Copyright (c) 2014 iOSGo!. All rights reserved.
//

#import "MapVC.h"
#import "Note.h"
#import "NoteMapAnnotation.h"

@interface MapVC ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) id<MKAnnotation> annotation;
@end

@implementation MapVC



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
    [self loadDataAsynch];
}

- (void) loadDataAsynch
{
    // run in the background, on the default priority queue
    dispatch_async( dispatch_get_global_queue(0, 0), ^{
    
        NSMutableArray *annots = [[NSMutableArray alloc] init];
        for (Note* note in self.data)
        {
            if (!(note.latitute && note.longitude)) {
                continue;
            }
            CLLocationCoordinate2D coord;
            coord.longitude = [note.longitude floatValue];
            coord.latitude = [note.latitute floatValue];
            
            NoteMapAnnotation *annotation = [[NoteMapAnnotation alloc] initWithLocation:coord];
            annotation.title = note.subject;
            annotation.subtitle = [NSDateFormatter localizedStringFromDate:note.created
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterShortStyle];
            annotation.note = note.body;
            [annots addObject:annotation];
        }
        [self.mapView addAnnotations:annots];
    
    });
}


-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *pinIdentifier = @"pinIndentifier";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];;
    pinView.tag = 22;
    
    if (pinView == nil)
    {
        // if an existing pin view was not available, create one
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                              initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
        customPinView.pinColor = MKPinAnnotationColorGreen;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self
                        action:@selector(showDetails:)
              forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        return customPinView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    
    return pinView;
}


-(void)showDetails:(UIButton *)sender
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
