//
//  GalleryViewController.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"
#import "MapDataModel.h"

#define kRowHeight 100
#define kRowWidth 422
#define kThumbnailPaddingLeft 20
#define kThumbnailPaddingVertical 10
#define kThumbnailWidth 106
#define kThumbnailHeight 106
#define kThumbnailsPerRow 3
#define kTabBarWidth 58
#define kUserDocumentsPerPage 50

@implementation GalleryViewController

@synthesize galleryScrollView, detailScrollView, detailView;
@synthesize fullscreenTransitionDelegate;
@synthesize zoomView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    //Get first 50 user documents and lay out their thumbnails
    NSArray * userDocuments = [MapDataModel getUserDocumentsWithOffset:0 andLimit:kUserDocumentsPerPage];
    int scrollViewRows = ceil([userDocuments count] / 3);
    CGRect frame = self.galleryScrollView.frame;
    
    [self.galleryScrollView setContentSize:CGSizeMake(frame.size.width , scrollViewRows * kRowHeight)];
    self.galleryScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    for(int i=0; i<[userDocuments count]; i++){
        NSDictionary * document = [userDocuments objectAtIndex:i];
        UIButton * thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame;
        frame.size.width = kThumbnailWidth;
        frame.size.height = kThumbnailHeight;
        frame.origin.x = (i % kThumbnailsPerRow) * kThumbnailWidth + (i % kThumbnailsPerRow +1) * kThumbnailPaddingLeft;
        frame.origin.y = (i / kThumbnailsPerRow) * (kThumbnailHeight + kThumbnailPaddingVertical) + kThumbnailPaddingVertical;
        thumbnailButton.frame = frame;
        
        UIImage * image = [MapDataModel getThumbnailForId:[document objectForKey:@"id"]];
        [thumbnailButton setBackgroundImage:image
                                   forState:UIControlStateNormal];
        
        [thumbnailButton addTarget:self action:@selector(didTouchThumbnail:) forControlEvents:UIControlEventTouchUpInside];
        
        thumbnailButton.tag =  [[document objectForKey:@"id"] intValue];
       
        /*
        thumbnailButton.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | 
        UIViewAutoresizingFlexibleBottomMargin;
       */
         
        thumbnailButton.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.galleryScrollView addSubview:thumbnailButton];
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

#pragma mark - IBActions

- (IBAction)didTouchThumbnail:(id)sender{
    
    UIButton * senderButton = (UIButton *) sender;
    UIImage * zoomImage = [MapDataModel getImageForId:[NSString stringWithFormat:@"%d", senderButton.tag]];
    self.zoomView.image = zoomImage;
    
    CGPoint senderOrigin = [senderButton.superview convertPoint:senderButton.frame.origin toView:nil];
// User this sender origin to place the zoom view
    
    //place detail scroll view
    CGRect frame;
    frame.origin.x = senderButton.frame.origin.x + 58;
    frame.origin.y = senderButton.frame.origin.y ;    
       + (kThumbnailHeight - kThumbnailWidth * 320 / 480) / 2; // this term is the vert offset of the actual image
    frame.size.width = kThumbnailWidth;
    frame.size.height = 320 * kThumbnailWidth / 480;
    
    self.zoomView.frame = frame;
    
    [self.view addSubview:self.zoomView];

    
    self.detailScrollView.autoresizingMask = 0;
    /*UIViewAutoresizingFlexibleWidth  |
    UIViewAutoresizingFlexibleHeight |
   // UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    //UIViewAutoresizingFlexibleTopMargin | 
    UIViewAutoresizingFlexibleBottomMargin;
    */
    
    //animate the zoom in, making the detail scroll view fill the screen
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.50];
    
    
    [fullscreenTransitionDelegate subviewRequestingFullscreen];
    
   // CGRect viewFrame = self.view.frame;
   // viewFrame.origin.x = - self.detailScrollView.frame.origin.x;
   // viewFrame.origin.y = - self.detailScrollView.frame.origin.y;
   // viewFrame.size.width = 480 * 480 / kThumbnailWidth;
   // viewFrame.size.height = 320 * 480 / kThumbnailWidth;
   // self.view.frame = viewFrame;

    CGRect zoomFrame= self.zoomView.frame;
    zoomFrame.origin.x = 0;
    zoomFrame.origin.y = 0;
    zoomFrame.size.width = 480;
    zoomFrame.size.height = 320;
    self.zoomView.frame = zoomFrame;
    

    [UIView commitAnimations];	
    
    
   }
@end
