//
//  MapViewController.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FullscreenTransitionDelegate.h"
#import "TimelineVisualizationView.h"




@interface MapViewController : UIViewController
<MKMapViewDelegate, TimelineVisualizationViewDelegate, UIScrollViewDelegate>
{
    id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;

    IBOutlet MKMapView * mapView;
    IBOutlet UIView * timelineView;
    IBOutlet UIView * timelineControlsView;
    IBOutlet TimelineVisualizationView * timelineVisualizationView;
    
    UIButton * mapInsetButton;
    
    NSInteger currentDetailIndex;
    NSInteger currentGalleryPage;

    BOOL userDataOnly;
    BOOL launchInGalleryMode;
    BOOL firstView;
    BOOL mapShowing;
}

@property(retain, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(nonatomic, retain) MKMapView * mapView;
@property(nonatomic, retain) UIView * timelineView;
@property(nonatomic, retain) UIView *timelineControlsView;
@property(nonatomic, retain) UIButton *mapInsetButton;
@property(nonatomic, retain) TimelineVisualizationView * timelineVisualizationView;
@property(nonatomic, retain) IBOutlet UIView * overlayView;

@property(nonatomic, retain) NSMutableArray * nextDocumentSet;
@property(nonatomic, retain) NSMutableArray * activeDocuments;
@property(nonatomic, retain) NSMutableArray * prevDocumentSet;
@property(nonatomic) NSInteger currentDetailIndex;
@property(nonatomic) NSInteger currentGalleryPage;
@property(nonatomic) BOOL userDataOnly;
@property(nonatomic) BOOL launchInGalleryMode;
@property(nonatomic) BOOL firstView;
@property(nonatomic) BOOL mapShowing;






//Gallery View Properties
@property(retain, nonatomic) IBOutlet UIScrollView * galleryScrollView;
@property(retain, nonatomic) IBOutlet UIScrollView * detailScrollView;
@property(retain, nonatomic) IBOutlet UIView * detailView;

@property(retain, nonatomic) IBOutlet   UIImageView * zoomView;

@property(retain, nonatomic) IBOutlet   TimelineVisualizationView * visualization;

//detailView
@property(retain, nonatomic) IBOutlet   UILabel * detailDate;

//infoView
@property(retain, nonatomic) IBOutlet   UIView * infoView;
@property(retain, nonatomic) IBOutlet   UITextView * comment;
@property(retain, nonatomic) IBOutlet   UILabel * location;
@property(retain, nonatomic) IBOutlet   UILabel * reporter;

//Map Functions
-(void) didRequestMapView:(id)sender;
-(void) placeMapInsetButton;
-(void) centerMapOnAnnotation:(CLLocationCoordinate2D) coordinate;
-(void) addAnnotations;


-(void) transitionFromMapToTimeline;
-(void) transitionFromMapToTimelineWithIndex: (NSInteger) index;
-(void) transitionFromMapToTimelineWithIndex: (NSInteger) index andTimeline: (NSString *) timeline;


//Gallery Functions
- (void)showDetailView;
- (void)hideDetailView;
- (void)showInfoViewForIndex: (NSInteger) index;
- (void)showDetailViewForIndex: (NSInteger) index;

- (void)hideInfoView;


- (IBAction)didTouchThumbnail:(id)sender;
- (IBAction)didTouchDetailCloseButton:(id)sender;
- (IBAction)didTouchDetailInfoButton:(id)sender;
- (IBAction)didTouchInfoCloseButton:(id)sender;
- (IBAction)didTouchLeftScrollButton:(id)sender;
- (IBAction)didTouchRightScrollButton:(id)sender;
- (IBAction)didRequestMapView:(id)sender;
- (IBAction)didRequestMenu:(id)sender;
- (IBAction)didTapGalleryButton:(id)sender;
- (IBAction)didTapOverlay:(id)sender;



@end
