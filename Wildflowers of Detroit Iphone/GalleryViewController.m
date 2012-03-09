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
#define kDetailScrollPreloadCount 5

@implementation GalleryViewController

@synthesize galleryScrollView, detailScrollView, detailView;
@synthesize fullscreenTransitionDelegate;
@synthesize zoomView, infoTextView, infoView;
@synthesize visualization;

@synthesize activeDocuments, nextDocumentSet, prevDocumentSet;

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
    
    activeDocuments = [[NSMutableArray alloc] init];
    
    //Get first 50 user documents and lay out their thumbnails
    NSArray * userDocuments = [MapDataModel
                               
                               getGalleryDocumentsWithStartKey: nil andLimit: nil];
    int scrollViewRows = ceil([userDocuments count] / 3);
    CGRect frame = self.galleryScrollView.frame;
    
    [self.galleryScrollView setContentSize:CGSizeMake(frame.size.width , scrollViewRows * kRowHeight)];

    
    for(int i=0; i<[userDocuments count]; i++){
        NSDictionary * document = [userDocuments objectAtIndex:i];
        UIButton * thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [activeDocuments addObject:document];
        
        CGRect frame;
        frame.size.width = kThumbnailWidth;
        frame.size.height = kThumbnailHeight;
        frame.origin.x = (i % kThumbnailsPerRow) * kThumbnailWidth + (i % kThumbnailsPerRow +1) * kThumbnailPaddingLeft;
        frame.origin.y = (i / kThumbnailsPerRow) * (kThumbnailHeight + kThumbnailPaddingVertical) + kThumbnailPaddingVertical;
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

- (void)showDetailView{
    /*
     layout some scroll images for demoing
     */
    NSArray * userDocuments = [MapDataModel getGalleryDocumentsWithStartKey:nil andLimit:nil ];
    int scrollViewPages = [userDocuments count];
    
    [self.detailScrollView setContentSize:CGSizeMake( scrollViewPages * 480, 320)];
    
    for(int i=0; i<[userDocuments count]; i++){
        NSDictionary * document = [userDocuments objectAtIndex:i];
        
        UIImage * image = [UIImage imageWithData:[document objectForKey:@"medium"]];
        
        UIImageView * scrollPage = [[UIImageView alloc]init ];
        scrollPage.image = image;
        
        scrollPage.tag =  [[document objectForKey:@"_id"] intValue];
        
        CGRect pageFrame = scrollPage.frame;
        pageFrame.origin.x = i*480;
        pageFrame.origin.y = 0;
        pageFrame.size.width = 480;
        pageFrame.size.height = 320;
        scrollPage.frame = pageFrame;
        
        [self.detailScrollView addSubview:scrollPage];
    }
    
    
    [self.view addSubview: self.detailView];
    [self.zoomView removeFromSuperview];
}

- (void)hideDetailView{
    [self.detailView removeFromSuperview];
    [fullscreenTransitionDelegate subviewReleasingFullscreen];

}

- (void)layoutDetailView{
    [self.detailScrollView setContentSize:CGSizeMake(480 * kDetailScrollPreloadCount, 320)];
    //???
}

- (void)showInfoView{
    CGRect frame = self.infoView.frame;
    frame.origin.x = (480 - frame.size.width) / 2;
    frame.origin.y = (320 - frame.size.height) /2;
    self.infoView.frame = frame;
    [self.view addSubview:self.infoView];
}

- (void)hideInfoView{
    [self.infoView removeFromSuperview];
}

- (IBAction)didTouchRightScrollButton:(id)sender{
    CGPoint offset = self.detailScrollView.contentOffset;
    if(offset.x < self.detailScrollView.contentSize.width){
        offset.x += 480;
        self.detailScrollView.contentOffset = offset;
    }
}

- (IBAction)didTouchLeftScrollButton:(id)sender{
    CGPoint offset = self.detailScrollView.contentOffset;
    if(offset.x > 0){
        offset.x -= 480;
        self.detailScrollView.contentOffset = offset;
    }
}


#pragma mark - IBActions

- (IBAction)didTouchThumbnail:(id)sender{
    
    UIButton * senderButton = (UIButton *) sender;
    NSDictionary * relevantDocument =  (NSDictionary *) [activeDocuments objectAtIndex:senderButton.tag];
    UIImage * zoomImage = [relevantDocument objectForKey:@"medium"];
    self.zoomView.image = zoomImage;
    
    CGPoint senderOrigin = [senderButton.superview convertPoint:senderButton.frame.origin toView:self.view];
// User this sender origin to place the zoom view
    
    //place detail scroll view
    CGRect frame;
    frame.origin.x = senderOrigin.x;
    frame.origin.y = senderOrigin.y ;    
  //     + (kThumbnailHeight - kThumbnailWidth * 320 / 480) / 2; // this term is the vert offset of the actual image
    frame.size.width = kThumbnailWidth;
    frame.size.height = frame.size.width; // 320 * kThumbnailWidth / 480;
    
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
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showDetailView)];
    [UIView commitAnimations];	
    
}

- (IBAction)didTouchDetailCloseButton:(id)sender{
    [self hideDetailView];
}

- (IBAction)didTouchDetailInfoButton:(id)sender {
    [self showInfoView];
}

- (IBAction)didTouchInfoCloseButton:(id)sender{
    [self hideInfoView];
}


@end
