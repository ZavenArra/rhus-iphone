//
//  MapViewController.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#include <stdlib.h>
#import "WOverlay.h"
#import "WOverlayView.h"
#import "MapDataModel.h"
#import "RhusMapAnnotation.h"

#define mapInsetOriginX 10
#define mapInsetOriginY 10
#define mapInsetWidth 97
#define mapInsetHeight 63
#define fullLatitudeDelta .1
#define fullLongitudeDelta .1
#define insetLatitudeDelta .03
#define insetLongitudeDelta .03
#define kMapCenterOnLoadLatitude 42.3
#define kMapCenterOnLoadLongitude -83.1

@implementation MapViewController

@synthesize mapView, timelineView, timelineControlsView;
@synthesize fullscreenTransitionDelegate;
@synthesize mapInsetButton;
@synthesize timelineVisualizationView;
@synthesize activeDocuments;

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
    center.latitude = kMapCenterOnLoadLatitude; 
    center.longitude = kMapCenterOnLoadLongitude; 
    coordinateRegion.center = center;
    MKCoordinateSpan span;
    span.latitudeDelta = fullLatitudeDelta;
    span.longitudeDelta = fullLongitudeDelta;
    coordinateRegion.span = span;
    self.mapView.region = coordinateRegion;
    

    //spoof an overlay geometry
    WOverlay * overlay = [[WOverlay alloc] init];
    [self.mapView addOverlay:overlay];


 
    self.timelineVisualizationView.delegate = self;
}

- (void) populateTestingData{
    //spoof map data
    //later on read this spoofed data from the data layer
    /*
     float latHigh = 42.362;
     float latLow = 42.293;
     float longHigh = -83.101;
     float longLow = -82.935;
     for(int i=0; i<10; i++){
     float latitude = latLow + (latHigh-latLow) * ( arc4random() % 1000 )/1000;
     float longitude = longLow + (longHigh-longLow) * ( arc4random() % 1000 )/1000;
     CLLocationCoordinate2D coordinate;
     coordinate.latitude = latitude;
     coordinate.longitude = longitude;
     [self.mapView addAnnotation:[SSMapAnnotation mapAnnotationWithCoordinate:coordinate title:@"Hey Guy!"] ];
     }*/
}

- (void) addAnnotations {

    //Cludgy way of removing all annotations
    //Once we switch to liveQuery this will be changed
    //TODO: Change when switch to live query
    for (int i =0; i < [mapView.annotations count]; i++) { 
        if ([[mapView.annotations objectAtIndex:i] isKindOfClass:[RhusMapAnnotation class]]) {                      
            [mapView removeAnnotation:[mapView.annotations objectAtIndex:i]]; 
        } 
    }
    self.activeDocuments = nil;
    self.activeDocuments = [[NSMutableArray alloc] init ];

    
    NSArray * documents = [MapDataModel getGalleryDocumentsWithStartKey:nil andLimit:nil];

    for( NSDictionary * document in documents){
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [ (NSString*) [document objectForKey:@"latitude"] floatValue];
        coordinate.longitude = [ (NSString*) [document objectForKey:@"longitude"] floatValue];
        
        //Constructor should be cleaned up
        NSString * created_at = [document objectForKey:@"created_at"];
        NSString * reports = [document objectForKey:@"reporter"];
        if(created_at == @"(null)"){
            created_at = @"";
        }
        if(reports == @"(null)"){
            reports = @"";
        }
        NSString * annotationText = [NSString stringWithFormat:@"%@ %@", 
                                     [document objectForKey:@"created_at"],
                                     [document objectForKey:@"reporter"]
                                     ];
        RhusMapAnnotation * rhusMapAnnotation = [RhusMapAnnotation mapAnnotationWithCoordinate:coordinate title:
                                                 annotationText
                                                 ];
        
        [activeDocuments addObject:document];
        
        NSInteger tag = [activeDocuments indexOfObject:document];
        rhusMapAnnotation.tag = tag;
        [self.mapView addAnnotation:rhusMapAnnotation];
    }
    
   }

- (void)viewWillAppear:(BOOL)animated {
    [self addAnnotations];
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

-(void) transitionFromMapToTimeline {
     [self transitionFromMapToTimelineWithIndex: nil andTimeline: nil];
}

-(void) transitionFromMapToTimelineWithIndex: (NSInteger) index {
    [self transitionFromMapToTimelineWithIndex: index andTimeline: nil];
}
-(void) transitionFromMapToTimelineWithIndex: (NSInteger) index andTimeline: (NSString *) timeline {
    
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    

    //Here is the answer to implementing a custom callout
    //Basically the idea is to add a 2nd annotation view when an annotation is selected
    //Not going to do this for the beta, unless I get excited.
    //http://stackoverflow.com/questions/8018841/customize-the-mkannotationview-callout
    
    
    RhusMapAnnotation * rhusMapAnnotation = (RhusMapAnnotation *) annotation;
    
    //ask database for the image file..       
    NSString * rhusMapAnnotationIdentifier = @"rhusMapAnnotationIdentifier";
    MKAnnotationView * annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:rhusMapAnnotationIdentifier];
    if(annotationView == nil){
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:rhusMapAnnotation reuseIdentifier:rhusMapAnnotationIdentifier];
    }

    annotationView.image = [UIImage imageNamed:@"mapPoint"];
    
    CGRect frame;
    frame.size.width = 32;
    frame.size.height = 32;
    
    UIButton * calloutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    calloutButton.contentMode = UIViewContentModeScaleToFill;
    calloutButton.frame = frame;
    UIImage * calloutImage = [[activeDocuments objectAtIndex:rhusMapAnnotation.tag] objectForKey:@"thumb"];
    [calloutButton setBackgroundImage:calloutImage forState:UIControlStateNormal];
    
    annotationView.leftCalloutAccessoryView = calloutButton;
    annotationView.canShowCallout = YES;
   // annotationView.tag = rhusMapAnnotation.tag;

    return annotationView; 
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay{
    WOverlayView * overlayView = [[WOverlayView alloc] initWithOverlay:overlay];
    return overlayView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *) control {
    
    [self centerMapOnCoodinates:view.annotation.coordinate];
    //NSString * key = [(NSDictionary *) [activeDocuments objectAtIndex:view.tag] objectForKey:@"_id"];
    [self transitionFromMapToTimelineWithIndex:view.tag andTimeline:nil ];
    [mapView deselectAnnotation:view.annotation animated:YES];
}


/*
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
        if (self.calloutAnnotation == nil) {
            self.calloutAnnotation = [[CalloutMapAnnotation alloc]
                                      initWithLatitude:view.annotation.coordinate.latitude
                                      andLongitude:view.annotation.coordinate.longitude];
        } else {
            self.calloutAnnotation.latitude = view.annotation.coordinate.latitude;
            self.calloutAnnotation.longitude = view.annotation.coordinate.longitude;
        }
        [self.mapView addAnnotation:self.calloutAnnotation];
        self.selectedAnnotationView = view;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if (self.calloutAnnotation && view.annotation == self.customAnnotation) {
        [self.mapView removeAnnotation: self.calloutAnnotation];
    }
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
