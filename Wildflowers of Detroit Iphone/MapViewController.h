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
<MKMapViewDelegate, TimelineVisualizationViewDelegate>
{
    id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;

    IBOutlet MKMapView * mapView;
    IBOutlet UIView * timelineView;
    IBOutlet UIView * timelineControlsView;
    IBOutlet TimelineVisualizationView * timelineVisualizationView;
    
    UIButton * mapInsetButton;
}

@property(strong, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(nonatomic, strong) MKMapView * mapView;
@property(nonatomic, strong) UIView * timelineView;
@property(nonatomic, strong) UIView *timelineControlsView;
@property(nonatomic, strong) UIButton *mapInsetButton;
@property(nonatomic, strong) TimelineVisualizationView * timelineVisualizationView;


-(void) didTapMapInsetButton:(id)sender;
-(void) placeMapInsetButton;
-(void) centerMapOnAnnotation:(CLLocationCoordinate2D) coordinate;
-(void) addAnnotations;


-(void) transitionFromMapToTimelin;
-(void) transitionFromMapToTimelineWithKey: (NSString *) key;
-(void) transitionFromMapToTimelineWithKey: (NSString *) key andTimeline: (NSString *) timeline;

@end
