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
#import "ProjectsTableViewController.h"




@interface MapViewController : UIViewController
<MKMapViewDelegate, TimelineVisualizationViewDelegate, UIScrollViewDelegate, ProjectsTableViewControllerDelegate>
{
    id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;

    IBOutlet MKMapView * mapView;
    IBOutlet UIView * timelineView;
    IBOutlet UIView * timelineControlsView;
    IBOutlet TimelineVisualizationView * timelineVisualizationView;
    IBOutlet UIButton * syncButton;
    IBOutlet UIView * spinnerContainerView;
    IBOutlet UIView * overlayView;
    IBOutlet ProjectsTableViewController * projectsViewController;

    
    UIButton * mapInsetButton;
    
    NSInteger currentDetailIndex;
    NSInteger currentGalleryPage;

    BOOL userDataOnly;
    BOOL launchInGalleryMode;
    BOOL firstView;
    BOOL mapShowing;
}

@property(strong, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(nonatomic, strong) MKMapView * mapView;
@property(nonatomic, strong) UIView * timelineView;
@property(nonatomic, strong) UIView *timelineControlsView;
@property(nonatomic, strong) UIButton *mapInsetButton;
@property(nonatomic, strong) TimelineVisualizationView * timelineVisualizationView;
@property(nonatomic, strong) UIButton * syncButton;
@property(nonatomic, strong) UIView * spinnerContainerView;
@property(nonatomic, strong) UIView * overlayView;
@property(nonatomic, strong) ProjectsTableViewController * projectsViewController;

//@property(nonatomic, strong) NSMutableArray * nextDocumentSet;
@property(nonatomic, strong) NSMutableArray * activeDocuments;
//@property(nonatomic, strong) NSMutableArray * prevDocumentSet;
@property(nonatomic) NSInteger currentDetailIndex;
@property(nonatomic) NSInteger currentGalleryPage;
@property(nonatomic) BOOL userDataOnly;
@property(nonatomic) BOOL launchInGalleryMode;
@property(nonatomic) BOOL firstView;
@property(nonatomic) BOOL mapShowing;


//Gallery View Properties
@property(strong, nonatomic) IBOutlet UIScrollView * galleryScrollView;
@property(strong, nonatomic) IBOutlet UIScrollView * detailScrollView;
@property(strong, nonatomic) IBOutlet UIView * detailView;

@property(strong, nonatomic) IBOutlet   UIImageView * zoomView;

@property(strong, nonatomic) IBOutlet   TimelineVisualizationView * visualization;
@property(strong, nonatomic) IBOutlet   UILabel * galleryHeading2;
@property(strong, nonatomic) IBOutlet   UILabel * myDataHeadingGallery;


//detailView
@property(strong, nonatomic) IBOutlet   UILabel * detailDate;
@property(strong, nonatomic) IBOutlet   UILabel * heading2;


//infoView
@property(strong, nonatomic) IBOutlet   UIView * infoView;
@property(strong, nonatomic) IBOutlet   UITextView * comment;
@property(strong, nonatomic) IBOutlet   UILabel * location;
@property(strong, nonatomic) IBOutlet   UILabel * reporter;

//Map Functions
-(void) didRequestMapView:(id)sender;
-(void) placeMapInsetButton;
-(void) centerMapOnAnnotation:(CLLocationCoordinate2D) coordinate;
-(void) addAnnotations;

-(void) transitionFromMapToTimeline;
-(void) transitionFromMapToTimelineWithIndex: (NSInteger) index;
-(void) transitionFromMapToTimelineWithIndex: (NSInteger) index andTimeline: (NSString *) timeline;

- (IBAction)didTouchProjects:(id)sender;


//Gallery Functions
- (void)showDetailView;
- (void)hideDetailView;
- (void)showInfoViewForIndex: (NSInteger) index;
- (void)showDetailViewForIndex: (NSInteger) index;

- (void)hideInfoView;
- (void) populate;


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
- (IBAction)didTapSync:(id)sender;



@end
