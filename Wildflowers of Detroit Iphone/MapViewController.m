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
#import "RhusDocument.h"

//Map Settings
#define mapInsetOriginX 10
#define mapInsetOriginY 10
#define mapInsetWidth 97
#define mapInsetHeight 63

#define insetLatitudeDelta .03
#define insetLongitudeDelta .03

//TODO: Target preferences via specific implementation and class methods
//http://stackoverflow.com/questions/3323816/xcode-multiple-targets-ifdefs-running-over

//Detroit
//#define DETROIT 1
#ifdef DETROIT
#define fullLatitudeDelta .1
#define fullLongitudeDelta .1
#define kMapCenterOnLoadLatitude 42.3
#define kMapCenterOnLoadLongitude -83.1

#else
//other
#define fullLatitudeDelta 50
#define fullLongitudeDelta 50
#define kMapCenterOnLoadLatitude 42.3
#define kMapCenterOnLoadLongitude -83.1

#endif

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

@implementation MapViewController

@synthesize mapView, timelineView, timelineControlsView;
@synthesize fullscreenTransitionDelegate;
@synthesize mapInsetButton;
@synthesize timelineVisualizationView;
@synthesize activeDocuments;
@synthesize galleryScrollView, detailScrollView, detailView;
@synthesize zoomView, infoView;
@synthesize visualization;
@synthesize comment, location, reporter;
@synthesize currentDetailIndex, currentGalleryPage;


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
    
    //Set up some tags
    self.detailScrollView.tag = kDetailScrollViewTag;
    self.galleryScrollView.tag = kGalleryScrollViewTag;
    
    
    
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


- (void) setupGalleryScrollView{
    
    activeDocuments = [[NSMutableArray alloc] init];
    
    //Get first 50 user documents and lay out their thumbnails
    NSArray * userDocuments = [MapDataModel
                               getGalleryDocumentsWithStartKey: nil andLimit: nil];
    float count = [userDocuments count];
    int scrollViewPages = ceil( count / 21.0);
    CGRect frame = self.galleryScrollView.frame;
    
    [self.galleryScrollView setContentSize:CGSizeMake(kGalleryPageWidth * scrollViewPages , frame.size.height)];
    
    
    for(int i=0; i<[userDocuments count]; i++){
        NSDictionary * document = [userDocuments objectAtIndex:i];
        UIButton * thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [activeDocuments addObject:document];
        
        CGRect frame;
        frame.size.width = kThumbnailWidth;
        frame.size.height = kThumbnailHeight;
        frame.origin.x = (i % kThumbnailsPerRow) * kThumbnailWidth + (i % kThumbnailsPerRow +1) * kThumbnailPaddingLeft
        + kGalleryPageWidth * (i / 21);
        frame.origin.y = ((i%21 / kThumbnailsPerRow) * (kThumbnailHeight + kThumbnailPaddingVertical) + kThumbnailPaddingVertical);
        thumbnailButton.frame = frame;
        
        
        [thumbnailButton setImage: [document valueForKey:@"thumb"]
                         forState:UIControlStateNormal];
        
        [thumbnailButton addTarget:self action:@selector(didTouchThumbnail:) forControlEvents:UIControlEventTouchUpInside];
        
        thumbnailButton.tag =  [activeDocuments indexOfObject:document];
        
        thumbnailButton.contentMode = UIViewContentModeCenter;
        thumbnailButton.imageView.contentMode = UIViewContentModeCenter;
        
        [self.galleryScrollView addSubview:thumbnailButton];
    }
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
    
    //TODO: Obviously both of these shouldn't be called
    [self setupGalleryScrollView];

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
    
    /*
    MKCoordinateRegion coordinateRegion = self.mapView.region;
    MKCoordinateSpan span;
    span.latitudeDelta = insetLatitudeDelta;
    span.longitudeDelta = insetLongitudeDelta;
    coordinateRegion.span = span;
    self.mapView.region = coordinateRegion;
    */
    
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
    
    /*
    MKCoordinateRegion coordinateRegion = self.mapView.region;
    MKCoordinateSpan span;
    span.latitudeDelta = fullLatitudeDelta;
    span.longitudeDelta = fullLongitudeDelta;
    coordinateRegion.span = span;
    self.mapView.region = coordinateRegion;
    */
     
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

-(void) centerMapAtLatitude: (float) latitude andLongitude:(float) longitude {
    CLLocationCoordinate2D center;
    center.latitude = latitude; 
    center.longitude = longitude; 
    [self centerMapOnCoodinates:center];
}



#pragma mark MapViewDelegate
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


#pragma mark - gallery methods

//Gallery View Methods
- (void)showDetailViewForIndex: (NSInteger) index{
    /*
     layout some scroll images for demoing
     */
    int scrollViewPages = [activeDocuments count];
    
    [self.detailScrollView setContentSize:CGSizeMake( scrollViewPages * 480, 320)];
    
    for(int i=0; i<[activeDocuments count]; i++){
        NSDictionary * document = [activeDocuments objectAtIndex:i];
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
        
        
        
        [self.detailScrollView addSubview:scrollPage];
    }
    
    
    [self.timelineView insertSubview: self.detailView belowSubview:self.zoomView];
    [self.zoomView removeFromSuperview];
}

- (void)showDetailView {
    [self showDetailViewForIndex:self.currentDetailIndex];
}

- (void)hideDetailView{
    [self.detailView removeFromSuperview];
    
}

- (void)layoutDetailView{
    [self.detailScrollView setContentSize:CGSizeMake(480 * kDetailScrollPreloadCount, 320)];
    //???
}

- (void)showInfoViewForIndex: (NSInteger) index{
    RhusDocument * document = [activeDocuments objectAtIndex:index];
    
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


#pragma mark - IBActions

-(void) didTapMapInsetButton:(id)sender{
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
    
    //place detail scroll view
    CGRect frame;
    frame.origin.x = senderOrigin.x;
    frame.origin.y = senderOrigin.y ;    
    //     + (kThumbnailHeight - kThumbnailWidth * 320 / 480) / 2; // this term is the vert offset of the actual image
    frame.size.width = kThumbnailWidth;
    frame.size.height = frame.size.width; // 320 * kThumbnailWidth / 480;
    
    self.zoomView.frame = frame;
    
    [self.timelineView insertSubview:self.zoomView belowSubview:self.timelineControlsView];    
    
    CGPoint detailScrollContentOffset;
    detailScrollContentOffset.y = 0;
    detailScrollContentOffset.x = senderButton.tag * 480;
    [self.detailScrollView setContentOffset:detailScrollContentOffset  animated:NO];

    
    //animate the zoom in, making the detail scroll view fill the screen
    [UIView beginAnimations:nil context:NULL];
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
        
        RhusDocument * document = [activeDocuments objectAtIndex:currentDetailIndex];
        [self centerMapAtLatitude:[document getLatitude] andLongitude:[document getLongitude]];
        

        
    } else if(scrollView.tag == kGalleryScrollViewTag){
        NSInteger page;

        page = x / kGalleryPageWidth;
    }
    
    
}


@end
