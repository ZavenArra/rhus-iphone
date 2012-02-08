//
//  CameraViewController.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "MapDataModel.h"

@implementation CameraViewController

@synthesize imagePicker;
@synthesize pictureDialog, pictureInfo;
@synthesize fullscreenTransitionDelegate;
@synthesize reporter, comment;

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
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
#if !TARGET_IPHONE_SIMULATOR
	//	self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;	
#endif
	}
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    CGRect frame = self.imagePicker.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = 480;
    frame.size.height = 320;
    self.imagePicker.view.frame = frame;
    //[self.view addSubview:self.imagePicker.view];
    
    //SET cameraOverlayView on imagePicker if it is displaying on top of menu bar.
    
    //self.imagePicker.takePicture;
    
    // [self presentViewController:self.imagePicker animated:NO completion:nil];
    [self presentModalViewController:self.imagePicker animated:YES];

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

#pragma mark Interface Methods

- (void) secondTapTabButton{
    //[self.imagePicker takePicture];
    [self showPictureDialog];
    
}

/*TODO: this function should be called by imagePickerController:didFinishPickingMediaWithInfo:*/
- (void) showPictureDialog {
    CGRect frame = self.pictureDialog.frame;
    frame.origin.x = 58;
    frame.origin.y = 108;
    self.pictureDialog.frame = frame;
    [self.view addSubview:self.pictureDialog];
    //and Disable camera tab button
}

- (void) hidePictureDialog {
    [self.pictureDialog removeFromSuperview];
}

- (void) animateShowInfoBox {
    CGRect frame = self.pictureInfo.frame;
    frame.origin.x = 480;
    self.pictureInfo.frame = frame;
    [self.view addSubview:self.pictureInfo];
    [UIView beginAnimations:@"anim" context:nil];
    frame = self.pictureInfo.frame;
    frame.origin.x = 0;
    self.pictureInfo.frame = frame;
    
    frame = self.pictureDialog.frame;
    frame.origin.x = -frame.size.width;
    self.pictureDialog.frame = frame;
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView commitAnimations];
}

#pragma mark IBActions
- (IBAction) didTouchRetakeButton:(id)sender{
    [self hidePictureDialog];
}

- (IBAction) didTouchUploadButton:(id)sender{
    //First hide the tab bar and slide dialog
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationDuration:0.35];
    [fullscreenTransitionDelegate subviewRequestingFullscreen];
    
    CGRect frame = self.pictureDialog.frame;
    frame.origin.x = 0;
    self.pictureDialog.frame = frame;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animateShowInfoBox)];
    [UIView commitAnimations];
    
}

- (IBAction) didTouchSendButton:(id)sender{

    
     float latHigh = 42.362+1;
     float latLow = 42.293+1;
     float longHigh = -83.101;
     float longLow = -82.935;
     float lattitude = latLow + (latHigh-latLow) * ( arc4random() % 1000 )/1000;
     float longitude = longLow + (longHigh-longLow) * ( arc4random() % 1000 )/1000;
    
    
    NSDictionary * newDocument = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.reporter.text, @"reporter",
                                  self.comment.text, @"comment",
                                  [[NSNumber numberWithFloat: lattitude] stringValue], @"lattitude", 
                                  [[NSNumber numberWithFloat: longitude] stringValue], @"longitude",
                                  nil];
    [MapDataModel addDocument:newDocument];
    
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationDuration:0.50];
    CGRect frame = self.pictureInfo.frame;
    frame.origin.x = 480;
    self.pictureInfo.frame = frame;
    
    [fullscreenTransitionDelegate subviewReleasingFullscreen];
    [UIView commitAnimations];

}

- (IBAction) resignFirstResponder:(id)sender {
    [self resignFirstResponder];
}

#pragma mark UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

}


@end
