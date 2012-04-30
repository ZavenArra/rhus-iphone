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
#import "RHDataModel.h"
#import "RHMapAnnotation.h"
#import "RHDocument.h"
#import "RHSettings.h"
#import "RHDeviceUser.h"
#import "AppDelegate.h"

//Map Settings
#define mapInsetOriginX 10
#define mapInsetOriginY 10
#define mapInsetWidth 97
#define mapInsetHeight 63

#define insetLatitudeDelta .03
#define insetLongitudeDelta .03
#define kLargeLatitudeDelta 1
#define kLargeLongitudeDelta 1




//Gallery Settings
#define kGalleryRowHeight 60
#define kGalleryPageWidth 430
#define kThumbnailPaddingLeft 10
#define kThumbnailPaddingVertical 10
#define kThumbnailWidth 50
#define kThumbnailHeight 50
#define kThumbnailsPerRow 7
#define kTabBarWidth 58
#define kUserDocumentsPerPage 50
#define kDetailScrollPreloadCount 5

#define kDetailScrollViewTag 1001
#define kGalleryScrollViewTag 1002


//Declare Private Methods
@interface MapViewController()
- (void) setMapViewToInset;
- (void) placeInGalleryMode;
- (void) centerMapAtLatitude: (float) latitude andLongitude:(float) longitude;
- (void) transitionToFullScreen;

@end

@implementation MapViewController

@synthesize mapView, timelineView, timelineControlsView;
@synthesize fullscreenTransitionDelegate;
@synthesize mapInsetButton;
@synthesize timelineVisualizationView;
@synthesize activeDocuments;
@synthesize galleryScrollView, detailScrollView, detailView;
@synthesize overlayView;
@synthesize zoomView, infoView;
@synthesize visualization;
@synthesize comment, location, reporter;
@synthesize currentDetailIndex, currentGalleryPage;
@synthesize userDataOnly;
@synthesize launchInGalleryMode;
@synthesize firstView;
@synthesize detailDate;
@synthesize mapShowing;
@synthesize heading2;
@synthesize galleryHeading2;
@synthesize myDataHeadingGallery;
@synthesize syncButton;
@synthesize spinnerContainerView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.userDataOnly = false;
        self.firstView = true;
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
    
    
    //Set up some tags
    self.detailScrollView.tag = kDetailScrollViewTag;
    self.galleryScrollView.tag = kGalleryScrollViewTag;
    
    
    if(!launchInGalleryMode) {
        MKCoordinateRegion coordinateRegion;
        CLLocationCoordinate2D center;
        center.latitude = [RHSettings mapCenterLatitudeOnLoad]; 
        center.longitude = [RHSettings mapCenterLongitudeOnLoad]; 
        coordinateRegion.center = center;
        MKCoordinateSpan span;
        span.latitudeDelta = [RHSettings mapDeltaLatitudeOnLoad]; 
        span.longitudeDelta = [RHSettings mapDeltaLongitudeOnLoad]; 
        coordinateRegion.span = span;
        self.mapView.region = coordinateRegion;
    }
        

    //spoof an overlay geometry
    WOverlay * overlay = [[WOverlay alloc] init];
    [self.mapView addOverlay:overlay];


 
    self.timelineVisualizationView.delegate = self;
    
    if(launchInGalleryMode){
        [self placeInGalleryMode];
    } else {
        mapShowing = TRUE;
        self.heading2.hidden = TRUE;
        self.myDataHeadingGallery.hidden = TRUE;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if(launchInGalleryMode || (!mapShowing && !firstView) ) {
        [self transitionToFullScreen];
    }

}

- (void) placeInGalleryMode{
    [self.view insertSubview:self.timelineView belowSubview: self.mapView];
    [mapView removeFromSuperview];
    //[self placeMapInsetButton];

}


- (void) setupGalleryScrollView{
    
    for(RHDocument * document in activeDocuments){
        UIButton * thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
                
        int index = [activeDocuments indexOfObject:document];
        int i = index;
        
        CGRect frame;
        frame.size.width = kThumbnailWidth;
        frame.size.height = kThumbnailHeight;
        frame.origin.x = (i % kThumbnailsPerRow) * kThumbnailWidth + (i % kThumbnailsPerRow +1) * kThumbnailPaddingLeft
        + kGalleryPageWidth * (i / 21);
        frame.origin.y = ((i%21 / kThumbnailsPerRow) * (kThumbnailHeight + kThumbnailPaddingVertical) + kThumbnailPaddingVertical);
        thumbnailButton.frame = frame;
        
        UIImage * thumbnailImage = [document valueForKey:@"thumb"];
        if(thumbnailImage != nil){
            [thumbnailButton setImage: thumbnailImage
                             forState:UIControlStateNormal];
        
            [thumbnailButton addTarget:self action:@selector(didTouchThumbnail:) forControlEvents:UIControlEventTouchUpInside];
        
            thumbnailButton.tag =  index;
        
            thumbnailButton.contentMode = UIViewContentModeCenter;
            thumbnailButton.imageView.contentMode = UIViewContentModeCenter;
            
        }
        
        [self.galleryScrollView addSubview:thumbnailButton];
    }
    CGSize gallerySize;
    gallerySize.height = 177;
    gallerySize.width = kGalleryPageWidth * ([activeDocuments count] / 21 + 1);
    galleryScrollView.contentSize = gallerySize;
    return;
    

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
        if ([[mapView.annotations objectAtIndex:i] isKindOfClass:[RHMapAnnotation class]]) {                      
            [mapView removeAnnotation:[mapView.annotations objectAtIndex:i]]; 
        } 
    }
    self.activeDocuments = nil;
    self.activeDocuments = [[NSMutableArray alloc] init ];

    NSArray * documents;
    if(self.userDataOnly){
        documents = [RHDataModel getDeviceUserGalleryDocumentsWithStartKey:nil andLimit:nil];
    } else {
        documents = [RHDataModel getGalleryDocumentsWithStartKey:nil andLimit:nil];
    }
    
    self.galleryHeading2.text = [NSString stringWithFormat:@"%i Images", [documents count]];
        
    for( RHDocument * document in documents){
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [ (NSString*) [document objectForKey:@"latitude"] floatValue];
        coordinate.longitude = [ (NSString*) [document objectForKey:@"longitude"] floatValue];
        if(coordinate.latitude == 0 && coordinate.longitude==0){
            continue;
        }
       // NSLog(@"%f %f", coordinate.latitude, coordinate.longitude );
        RHMapAnnotation * rhusMapAnnotation = (RHMapAnnotation *) [RHMapAnnotation 
                                                 mapAnnotationWithCoordinate: coordinate
                                                 title:  [document getDateString]
                                                 subtitle:  [document getReporter]
                                                 ];
        
        [activeDocuments addObject:document];
        
        NSInteger tag = [activeDocuments indexOfObject:document];
        rhusMapAnnotation.tag = tag;
        [self.mapView addAnnotation:rhusMapAnnotation];
    }
    
   }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    //TODO: Obviously both of these shouldn't be called
    //RE: setupGalleryScroll is called in viewWillAppear 
    //  - actually it's not, because something isn't in place yet, and nothing loads
    //Both should be key-value observers and already be updated
    //by the time the user clicks on the button.
    [self addAnnotations];
    
    [self setupGalleryScrollView];
    
    if(launchInGalleryMode) {
        [UIView beginAnimations:nil context:NULL];
        [fullscreenTransitionDelegate subviewRequestingFullscreen];
        [UIView commitAnimations];
        firstView = FALSE;
    }
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




#pragma mark - Interface Methods

-(void) setMapViewToInset{
    
    CGRect frame = self.mapView.frame;
    frame.origin.x = mapInsetOriginX;
    frame.origin.y = mapInsetOriginY;
    frame.size.width = mapInsetWidth;
    frame.size.height = mapInsetHeight;
    self.mapView.frame = frame;
    
}

-(void) mapToTimelineAnimation {
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.50];
    
    [fullscreenTransitionDelegate subviewRequestingFullscreen];
    
    if(!launchInGalleryMode){
        MKCoordinateRegion coordinateRegion = self.mapView.region;
        MKCoordinateSpan span;
        span.latitudeDelta = insetLatitudeDelta;
        span.longitudeDelta = insetLongitudeDelta;
        coordinateRegion.span = span;
        self.mapView.region = coordinateRegion;
    
        [self setMapViewToInset];
    }
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(placeMapInsetButton)];
    [UIView commitAnimations];
    
}


-(void) detailToGallery {
    [self.view insertSubview:self.timelineView aboveSubview: self.detailView];
    if(!launchInGalleryMode){
        [self.view addSubview:mapView];
    }
    [self.detailView removeFromSuperview];
}


-(void) transitionFromMapToTimeline {
    [self.view insertSubview:self.timelineView belowSubview: self.mapView];
    [self mapToTimelineAnimation];
    mapShowing = FALSE;
    
    
}

-(void)centerMapAtCurrentDocument {
    
    RHDocument * document = [activeDocuments objectAtIndex:currentDetailIndex];
    [self centerMapAtLatitude:[document getLatitude] andLongitude:[document getLongitude]];
}


-(void) transitionFromMapToTimelineWithIndex: (NSInteger) index {
    [self transitionFromMapToTimelineWithIndex: index andTimeline: nil];
}


-(void) transitionFromMapToTimelineWithIndex: (NSInteger) index andTimeline: (NSString *) timeline {
    [self.view insertSubview:self.timelineView belowSubview: self.mapView];
    self.currentDetailIndex = index;
    [self showDetailViewForIndex: index];
    [self mapToTimelineAnimation];


    [self centerMapAtCurrentDocument];
    mapShowing = FALSE;
}


-(void) transitionFromTimelineToMap{

    
    if(self.mapInsetButton){
        [mapInsetButton removeFromSuperview];
    }
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.50];
    
    [fullscreenTransitionDelegate subviewReleasingFullscreen];
    
    
    CGRect frame = mapView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = 480;
    frame.size.height = 320;
    mapView.frame = frame;
    
    
    MKCoordinateRegion coordinateRegion = self.mapView.region;
    MKCoordinateSpan span;
    span.latitudeDelta = kLargeLatitudeDelta;
    span.longitudeDelta = kLargeLongitudeDelta;
    coordinateRegion.span = span;
    self.mapView.region = coordinateRegion;
    
 
   // [self.view insertSubview:mapView atIndex:0];
    [UIView commitAnimations];
    
    
    [timelineView removeFromSuperview];

    [self.view addSubview:mapView];

    
    mapShowing = TRUE;
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
    
    [self.mapInsetButton addTarget:self action:@selector(didRequestMapView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.mapInsetButton];
}

-(void) centerMapOnCoodinates:(CLLocationCoordinate2D) coordinate{
    self.mapView.centerCoordinate = coordinate;
}

-(void) centerMapAtLatitude: (float) latitude andLongitude:(float) longitude {
    CLLocationCoordinate2D center;
    center.latitude = latitude; 
    center.longitude = longitude; 
    [self centerMapOnCoodinates:center];
}



#pragma mark - MapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    

    //Here is the answer to implementing a custom callout
    //Basically the idea is to add a 2nd annotation view when an annotation is selected
    //Not going to do this for the beta, unless I get excited.
    //http://stackoverflow.com/questions/8018841/customize-the-mkannotationview-callout
    
    
    RHMapAnnotation * rhusMapAnnotation = (RHMapAnnotation *) annotation;
    
    //ask database for the image file..       
    NSString * rhusMapAnnotationIdentifier = @"rhusMapAnnotationIdentifier";
    MKAnnotationView * annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:rhusMapAnnotationIdentifier];
    if(annotationView == nil){
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:rhusMapAnnotation reuseIdentifier:rhusMapAnnotationIdentifier];
    }

    NSString * documentDeviceUserIdentifier = [[activeDocuments objectAtIndex:rhusMapAnnotation.tag] objectForKey:@"deviceuser_identifier"];
    NSString * deviceUserIdentifier = [RHDeviceUser uniqueIdentifier];
    if([deviceUserIdentifier isEqualToString: documentDeviceUserIdentifier] ){
        annotationView.image = [UIImage imageNamed:@"mapDeviceUserPoint"];
    } else {
        annotationView.image = [UIImage imageNamed:@"mapPoint"];
    }
        
    CGRect frame;
    frame.size.width = 32;
    frame.size.height = 32;
    
    UIButton * calloutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    calloutButton.contentMode = UIViewContentModeScaleToFill;
    calloutButton.frame = frame;
    RHDocument * doc = [activeDocuments objectAtIndex:rhusMapAnnotation.tag];
    
    UIImage * calloutImage = [doc objectForKey:@"thumb"];
    [calloutButton setBackgroundImage:calloutImage forState:UIControlStateNormal];
    
    annotationView.leftCalloutAccessoryView = calloutButton;
    annotationView.canShowCallout = YES;
    annotationView.tag = rhusMapAnnotation.tag;
   
    return annotationView; 
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay{
    WOverlayView * overlayView = [[WOverlayView alloc] initWithOverlay:overlay];
    return overlayView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *) control {
    
    [self centerMapOnCoodinates:view.annotation.coordinate];
    NSInteger tag = view.tag;
    NSLog(@"Transitioning with index: %i", tag); 

    [self transitionFromMapToTimelineWithIndex:tag andTimeline:nil ];
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


#pragma mark - gallery methods

//Gallery View Methods
- (void)showDetailViewForIndex: (NSInteger) index{
    /*
     layout some scroll images for demoing
     */
    int scrollViewPages = [activeDocuments count];
    
    [self.detailScrollView setContentSize:CGSizeMake( scrollViewPages * 480, 320)];
    
    //TODO: currently this reruns the layout every time you click a thumb/callout
    for(int i=0; i<[activeDocuments count]; i++){
        RHDocument * document = [activeDocuments objectAtIndex:i];
        if([document objectForKey:@"medium"] == nil){
            continue;
        }
        
        UIImage * image = [document objectForKey:@"medium"];
        
        UIImageView * scrollPage = [[UIImageView alloc]init ];
        scrollPage.image = image;
        scrollPage.tag = index;
        scrollPage.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRect pageFrame = scrollPage.frame;
        pageFrame.origin.x = i*480;
        pageFrame.origin.y = 0;
        pageFrame.size.width = 480;
        pageFrame.size.height = 320;
        scrollPage.frame = pageFrame;
        
        [self.detailDate setText:[document getDateString]];
        
        [self.detailScrollView addSubview:scrollPage];
    }
    
    CGPoint detailScrollContentOffset;
    detailScrollContentOffset.y = 0;
    detailScrollContentOffset.x = index * 480;
    [self.detailScrollView setContentOffset:detailScrollContentOffset  animated:NO];
    
    [self.timelineView insertSubview: self.detailView belowSubview:self.zoomView];
    [self.zoomView removeFromSuperview];
}

- (void)showDetailView {
    [self showDetailViewForIndex:self.currentDetailIndex];
}

- (void)hideDetailView{
    [self.detailView removeFromSuperview];
}

- (void)showInfoViewForIndex: (NSInteger) index{
    RHDocument * document = [activeDocuments objectAtIndex:index];
    
    CGRect frame = self.infoView.frame;
    frame.origin.x = (480 - frame.size.width) / 2;
    frame.origin.y = (320 - frame.size.height) /2;
    self.infoView.frame = frame;
    

    self.comment.text = [document getComment];
    self.reporter.text = [document getReporter];
    self.location.text = [document getLocationString];
    
    [self.view addSubview:self.infoView];
}

- (void)hideInfoView{
    [self.infoView removeFromSuperview];
}

- (void)transitionToFullScreen {
    
    [UIView beginAnimations:nil context:nil];
    [fullscreenTransitionDelegate subviewRequestingFullscreen];
    [self.overlayView removeFromSuperview];
    [UIView commitAnimations];

}

#pragma mark - IBActions
- (IBAction)didTapGalleryButton:(id)sender {
    [self detailToGallery];
}

-(IBAction) didRequestMapView:(id)sender{
    [self transitionFromTimelineToMap];
}

- (IBAction)didTouchThumbnail:(id)sender{
    
    UIButton * senderButton = (UIButton *) sender;
    NSDictionary * relevantDocument =  (NSDictionary *) [activeDocuments objectAtIndex:senderButton.tag];
    UIImage * zoomImage = [relevantDocument objectForKey:@"medium"];
    self.zoomView.image = zoomImage;
    
    CGPoint senderOrigin = [senderButton.superview convertPoint:senderButton.frame.origin toView:self.view];
    // User this sender origin to place the zoom view
    
    int tag = senderButton.tag;
    self.currentDetailIndex = tag;
    
    //place zoom view
    CGRect frame;
    frame.origin.x = senderOrigin.x;
    frame.origin.y = senderOrigin.y ;    
    frame.size.width = kThumbnailWidth;
    frame.size.height = frame.size.width; // 320 * kThumbnailWidth / 480;    
    self.zoomView.frame = frame;
    
    [self.timelineView insertSubview:self.zoomView belowSubview:self.timelineControlsView];    
    
    CGPoint detailScrollContentOffset;
    detailScrollContentOffset.y = 0;
    detailScrollContentOffset.x = senderButton.tag * 480;
    [self.detailScrollView setContentOffset:detailScrollContentOffset  animated:NO];
    
    
    [self centerMapAtCurrentDocument];
    
    //animate the zoom in, making the detail scroll view fill the screen
    [UIView beginAnimations:@"Anim" context:NULL];
	[UIView setAnimationDuration: 0.50];
        
    [fullscreenTransitionDelegate subviewRequestingFullscreen];
    
    CGRect zoomFrame= self.zoomView.frame;
    zoomFrame.origin.x = 0;
    zoomFrame.origin.y = 0;
    zoomFrame.size.width = 480;
    zoomFrame.size.height = 320;
    self.zoomView.frame = zoomFrame;
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showDetailView)];
    [UIView commitAnimations];	
    
}

- (IBAction)didTouchDetailCloseButton:(id)sender{
    [self hideDetailView];
}

- (IBAction)didTouchDetailInfoButton:(id)sender {
    [self showInfoViewForIndex: currentDetailIndex];
}

- (IBAction)didTouchInfoCloseButton:(id)sender{
    [self hideInfoView];
}

- (IBAction)didRequestMenu:(id)sender{
    [UIView beginAnimations:nil context:nil];
    [fullscreenTransitionDelegate subviewReleasingFullscreen];
    [self.view addSubview:self.overlayView];
    [UIView commitAnimations];
}

- (IBAction)didTapOverlay:(id)sender{
    [self transitionToFullScreen];
}

- (IBAction)didTabSync:(id)sender{
    if( ! [ (AppDelegate *) [[UIApplication sharedApplication] delegate] internetActive] ) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Internet Not Available"
                               message: @"The internet is not currently available.  Please wait until you are able to connect to the interet in order to sync"
                               delegate: nil
                               cancelButtonTitle: @"OK"
                               otherButtonTitles: nil];
        [alert show];
        return;
        
    }
    
    
    [self.view addSubview:self.spinnerContainerView];
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinnerContainerView addSubview:ai];
    [ai startAnimating];
   
    [[RHDataModel instance] updateSyncURLWithCompletedBlock:^{
        [[RHDataModel instance] forgetSync];
        [self.spinnerContainerView removeFromSuperview];
    }
     ];
 
}

#pragma mark - TimelineVisualizationView

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

- (void) asyncLoadNextGalleryPage{
    NSLog(@"asyncLoadNextGalleryPage not yet implemented");
}


#pragma mark - UIScrollViewDelegate Functions

- (void) updateTimestampView {
    RHDocument * document = [activeDocuments objectAtIndex:currentDetailIndex];
    self.detailDate.text = [document objectForKey:@"created_at"];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	CGFloat x = scrollView.contentOffset.x;
    if(scrollView.tag == kDetailScrollViewTag){
        //Set current index/tag of this detail view
        currentDetailIndex = x / 480;
        NSInteger page = currentDetailIndex / 21;
        CGPoint contentOffset;
        contentOffset.y = 0;
        contentOffset.x = page * kGalleryPageWidth;
        [self.galleryScrollView setContentOffset:contentOffset animated:NO];
        //async load next gallery page of data!
        currentGalleryPage = page;
        
        RHDocument * document = [activeDocuments objectAtIndex:currentDetailIndex];
        [self centerMapAtLatitude:[document getLatitude] andLongitude:[document getLongitude]];
        if(!launchInGalleryMode){
           // self.heading2.text = [document objectForKey:
        }
        

        
    } else if(scrollView.tag == kGalleryScrollViewTag){
        NSInteger page;

        page = x / kGalleryPageWidth;
    }
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateTimestampView];   
}



@end
