//
//  MapViewController.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#include <stdlib.h>
#import "SSMapAnnotation.h"
#import "WOverlay.h"
#import "WOverlayView.h"
#import "MapDataModel.h"

#define mapInsetOriginX 10
#define mapInsetOriginY 10
#define mapInsetWidth 97
#define mapInsetHeight 63
#define fullLatitudeDelta .05
#define fullLongitudeDelta .05
#define insetLatitudeDelta .03
#define insetLongitudeDelta .03

@implementation MapViewController

@synthesize mapView, timelineView, timelineControlsView;
@synthesize fullscreenTransitionDelegate;
@synthesize mapInsetButton;
@synthesize timelineVisualizationView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    MKCoordinateRegion coordinateRegion;
    CLLocationCoordinate2D center;
    center.latitude = 42.35;
    center.longitude = -83.07;
    coordinateRegion.center = center;
    MKCoordinateSpan span;
    span.latitudeDelta = fullLatitudeDelta;
    span.longitudeDelta = fullLongitudeDelta;
    coordinateRegion.span = span;
    self.mapView.region = coordinateRegion;
    
    //spoof map data
    //later on read this spoofed data from the data layer
    
    NSArray * items = [MapDataModel getUserDocuments];
    /*
    float latHigh = 42.362;
    float latLow = 42.293;
    float longHigh = -83.101;
    float longLow = -82.935;
    for(int i=0; i<10; i++){
        float lattitude = latLow + (latHigh-latLow) * ( arc4random() % 1000 )/1000;
        float longitude = longLow + (longHigh-longLow) * ( arc4random() % 1000 )/1000;
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = lattitude;
        coordinate.longitude = longitude;
        [self.mapView addAnnotation:[SSMapAnnotation mapAnnotationWithCoordinate:coordinate title:@"Hey Fucker"] ];
    }*/
    
    for( NSDictionary * object in items){
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [ (NSString*) [object objectForKey:@"lattitude"] floatValue];
        coordinate.longitude = [ (NSString*) [object objectForKey:@"longitude"] floatValue];
        [self.mapView addAnnotation:[SSMapAnnotation mapAnnotationWithCoordinate:coordinate title:
                                     [object objectForKey:@"reporter"]
                                     ]];
    }
    
    //spoof an overlay geometry
    WOverlay * overlay = [[WOverlay alloc] init];
    [self.mapView addOverlay:overlay];
 
    self.timelineVisualizationView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - 
#pragma make Interface Methods
-(void) transitionFromMapToTimeline{
    
    [self.view insertSubview:self.timelineView belowSubview: self.mapView];
    
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.50];
    
    [fullscreenTransitionDelegate subviewRequestingFullscreen];

    
    CGRect frame = self.mapView.frame;
    frame.origin.x = mapInsetOriginX;
    frame.origin.y = mapInsetOriginY;
    frame.size.width = mapInsetWidth;
    frame.size.height = mapInsetHeight;
    self.mapView.frame = frame;
    
    MKCoordinateRegion coordinateRegion = self.mapView.region;
    MKCoordinateSpan span;
    span.latitudeDelta = insetLatitudeDelta;
    span.longitudeDelta = insetLongitudeDelta;
    coordinateRegion.span = span;
    self.mapView.region = coordinateRegion;
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(placeMapInsetButton)];
    [UIView commitAnimations];
    
    //when the anim completes, add an invisible button on top of shrunken map.
}

-(void) transitionFromTimelineToMap{
    
    if(self.mapInsetButton){
        [mapInsetButton removeFromSuperview];
    }
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.50];
    
    [fullscreenTransitionDelegate subviewReleasingFullscreen];
    
    
    CGRect frame = self.mapView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = 480;
    frame.size.height = 320;
    self.mapView.frame = frame;
    
    MKCoordinateRegion coordinateRegion = self.mapView.region;
    MKCoordinateSpan span;
    span.latitudeDelta = fullLatitudeDelta;
    span.longitudeDelta = fullLongitudeDelta;
    coordinateRegion.span = span;
    self.mapView.region = coordinateRegion;
    
    [UIView commitAnimations];

}

-(void) placeMapInsetButton{
    if(!self.mapInsetButton){
        self.mapInsetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = self.mapInsetButton.frame;
        frame.origin.x = mapInsetOriginX;
        frame.origin.y = mapInsetOriginY;
        frame.size.width = mapInsetWidth;
        frame.size.height = mapInsetHeight;
        self.mapInsetButton.frame = frame;
    }
    
    [self.mapInsetButton addTarget:self action:@selector(didTapMapInsetButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.mapInsetButton];
}

-(void) centerMapOnCoodinates:(CLLocationCoordinate2D) coordinate{
    self.mapView.centerCoordinate = coordinate;
}

#pragma mark - IBActions
-(void) didTapMapInsetButton:(id)sender{
    [self transitionFromTimelineToMap];
}


#pragma mark - 
#pragma make MapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation{
    MKAnnotationView * annotationView = [[MKAnnotationView alloc] init ];
    annotationView.image = [UIImage imageNamed:@"mapPoint"];
    annotationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:
        [UIImage imageNamed:@"mapPointPopup"]
    ];
    annotationView.canShowCallout = YES;

    return annotationView; 
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay{
    WOverlayView * overlayView = [[WOverlayView alloc] initWithOverlay:overlay];
    return overlayView;
}
/*
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    [self centerMapOnCoodinates:view.annotation.coordinate];
    [self transitionFromMapToTimeline];
}
 */

#pragma mark - 
#pragma make TimelineVisualizationView

//TODO: This function currently spoofs data that should be loaded from the data layer
- (NSArray *) dataForVisualization{
    NSMutableArray * data = [NSMutableArray array];
    
    int numLevels = 4;
    for(int i=0; i<52; i++){
        
        int level = arc4random() % numLevels;
//        float randy;
//        randy = (level)/numLevels;
        

        [data addObject: [NSValue valueWithCGPoint:
                          CGPointMake(i, level)]];
    }

    return data;
}
- (CGFloat) dataRange {
    return 51;
}
- (CGFloat) dataDomain{
    return 4;
}


@end
