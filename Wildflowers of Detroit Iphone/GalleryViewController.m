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

@implementation GalleryViewController

@synthesize galleryScrollView;

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
    
    //Get user documents and lay out their thumbnails
    NSArray * userDocuments = [MapDataModel getUserDocuments];
    int scrollViewRows = ceil([userDocuments count] / 3);
    CGRect frame = self.galleryScrollView.frame;
    
    [self.galleryScrollView setContentSize:CGSizeMake(frame.size.width , scrollViewRows * kRowHeight)];
    
    for(int i=0; i<[userDocuments count]; i++){
        UIButton * thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame;
        frame.size.width = kThumbnailWidth;
        frame.size.height = kThumbnailHeight;
        frame.origin.x = (i % kThumbnailsPerRow) * (kThumbnailPaddingLeft + kThumbnailWidth);
        frame.origin.y = (i / kThumbnailsPerRow) * (kThumbnailHeight + kThumbnailPaddingVertical) + kThumbnailPaddingVertical;
        thumbnailButton.frame = frame;
        
        [thumbnailButton setBackgroundImage:[UIImage imageNamed:@"Default"] forState:UIControlStateNormal];
        
        [thumbnailButton addTarget:self action:@selector(didTouchThumbnail) forControlEvents:UIControlEventTouchUpInside];
        
        thumbnailButton.tag = i;
        
        
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
    //place detail scroll view
    CGRect frame;
    frame.origin.x = kThumbnailPaddingLeft;
    frame.origin.x = kThumbnailPaddingVertical;
    frame.size.width = kThumbnailWidth;
    frame.size.height = kThumbnailHeight;
    self.detailScrollView.frame = frame;
    
    [self.view addSubview:self.detailScrollView];
}
@end
