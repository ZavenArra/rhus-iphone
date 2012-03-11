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
}

@property(strong, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(nonatomic, strong) MKMapView * mapView;
@property(nonatomic, strong) UIView * timelineView;
@property(nonatomic, strong) UIView *timelineControlsView;
@property(nonatomic, strong) UIButton *mapInsetButton;
@property(nonatomic, strong) TimelineVisualizationView * timelineVisualizationView;

@property(nonatomic, strong) NSMutableArray * nextDocumentSet;
@property(nonatomic, strong) NSMutableArray * activeDocuments;
@property(nonatomic, strong) NSMutableArray * prevDocumentSet;
@property(nonatomic) NSInteger currentDetailIndex;
@property(nonatomic) NSInteger currentGalleryPage;
@property(nonatomic) BOOL userDataOnly;
@property(nonatomic) BOOL launchInGalleryMode;
@property(nonatomic) BOOL firstView;





//Gallery View Properties
@property(strong, nonatomic) IBOutlet UIScrollView * galleryScrollView;
@property(strong, nonatomic) IBOutlet UIScrollView * detailScrollView;
@property(strong, nonatomic) IBOutlet UIView * detailView;

@property(strong, nonatomic) IBOutlet   UIImageView * zoomView;

@property(strong, nonatomic) IBOutlet   TimelineVisualizationView * visualization;


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



@end
