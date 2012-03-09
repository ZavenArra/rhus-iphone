//
//  GalleryViewController.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullscreenTransitionDelegate.h"
#import "TimelineVisualizationView.h"

@interface GalleryViewController : UIViewController
{
    id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
    UIScrollView * galleryScrollView;
    UIView * detailView;
    UIScrollView * detailScrollView;
    
    UIImageView * zoomView;
    UIView * infoView;
    UITextView * infoTextView;
    TimelineVisualizationView * visualization;

}

@property(strong, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(strong, nonatomic) IBOutlet UIScrollView * galleryScrollView;
@property(strong, nonatomic) IBOutlet UIScrollView * detailScrollView;
@property(strong, nonatomic) IBOutlet UIView * detailView;

@property(strong, nonatomic) IBOutlet   UIImageView * zoomView;
@property(strong, nonatomic) IBOutlet   UIView * infoView;
@property(strong, nonatomic) IBOutlet   UITextView * infoTextView;

@property(strong, nonatomic) IBOutlet   TimelineVisualizationView * visualization;

@property(nonatomic, strong) NSMutableArray * nextDocumentSet;
@property(nonatomic, strong) NSMutableArray * activeDocuments;
@property(nonatomic, strong) NSMutableArray * prevDocumentSet;


- (void)showDetailView;
- (void)hideDetailView;
- (void)showInfoView;
- (void)hideInfoView;


- (IBAction)didTouchThumbnail:(id)sender;
- (IBAction)didTouchDetailCloseButton:(id)sender;
- (IBAction)didTouchDetailInfoButton:(id)sender;
- (IBAction)didTouchInfoCloseButton:(id)sender;
- (IBAction)didTouchLeftScrollButton:(id)sender;
- (IBAction)didTouchRightScrollButton:(id)sender;




@end
