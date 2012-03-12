//
//  CameraViewController.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "MapDataModel.h"
#import "DeviceUser.h"
#import "RHLocation.h"
#import "RHSettings.h"


#define kThreePetal 101
#define kFourPetal 102
#define kFivePetal 103
#define kSixPetal 104
#define kManyPetal 105

#define kIrregular 106
#define kComposite 107
#define kTree 108
#define kFruit 109

@implementation CameraViewController

@synthesize imagePicker;
@synthesize pictureDialog, pictureInfo;
@synthesize fullscreenTransitionDelegate;
@synthesize reporter, comment;
@synthesize imageView, currentImage;
@synthesize attributeTranslation, selectedAttributes;
@synthesize shutterView;
@synthesize activeImageOrientation;

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
    
    self.attributeTranslation = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"three_petal",[NSNumber numberWithInt:kThreePetal] ,
                                  @"four_petal",[NSNumber numberWithInt:kFourPetal] ,
                                  @"five_petal",[NSNumber numberWithInt:kFivePetal] ,
                                  @"six_petal",[NSNumber numberWithInt:kSixPetal] ,
                                  @"many_petal",[NSNumber numberWithInt:kManyPetal] ,
                                  @"irregulat",[NSNumber numberWithInt:kIrregular] ,
                                  @"composite",[NSNumber numberWithInt:kComposite] ,
                                  @"tree",[NSNumber numberWithInt:kTree] ,
                                  @"fruit",[NSNumber numberWithInt:kFruit] ,
                                 nil];
    
    self.selectedAttributes = [NSMutableArray array];
    self.imagePicker = [[UIImagePickerController alloc] init];

}

- (void)viewDidAppear:(BOOL)animated {

    if([RHSettings useCamera]) {
        [self showImagePickerView];
    }
    
}

- (void) showImagePickerView {
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if([RHSettings useCamera]) {
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;	
            self.imagePicker.showsCameraControls = NO;
            
        }else {       
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
	}
    self.imagePicker.view.transform =  
    
    CGAffineTransformScale (
                            CGAffineTransformTranslate(
                                                       CGAffineTransformMakeRotation(-M_PI/2),
                                                       70, 110),
                            // -25, 255),                           
                            // -50, 175), //half
                            // -100,350), //without scale
                            
                            //1.2,1.2) // this is closer to correct
                            1.2, 1.2)
    ;
    
    [self.view addSubview:self.imagePicker.view];

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
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


#pragma mark Interface Methods

- (void) secondTapTabButton{

    if([RHSettings useCamera]){
        [self.view addSubview:shutterView];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])){
            self.activeImageOrientation = kLandscapePhoto;
        } else {
            self.activeImageOrientation = kPortraitPhoto;
        }
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        
        [self.imagePicker takePicture];
    } else {
        //TODO: move testing data to RHSettings
        self.currentImage = [UIImage imageNamed:@"IMG_0015.jpg"];
        [imageView setImage:currentImage];
        [self showPictureDialog];
    }
}

/*TODO: this function should be called by imagePickerController:didFinishPickingMediaWithInfo:*/
- (void) showPictureDialog {
    CGRect frame = self.pictureDialog.frame;
    frame.origin.x = 480 - 58 - self.pictureDialog.frame.size.width;
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
    frame.origin.x = -480;
    self.pictureInfo.frame = frame;
    [self.view addSubview:self.pictureInfo];
    [UIView beginAnimations:@"anim" context:nil];
    frame = self.pictureInfo.frame;
    frame.origin.x = 0;
    self.pictureInfo.frame = frame;
    
    frame = self.pictureDialog.frame;
    frame.origin.x = 480;
    self.pictureDialog.frame = frame;
    
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView commitAnimations];
}

#pragma mark IBActions
- (IBAction) didTouchRetakeButton:(id)sender{
    [self hidePictureDialog];
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
}

- (IBAction) didTouchCancelUploadButton:(id)sender{
    [self.pictureInfo removeFromSuperview];
}

- (IBAction) didTouchUploadButton:(id)sender{
    //First hide the tab bar and slide dialog
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationDuration:0.35];
    [fullscreenTransitionDelegate subviewRequestingFullscreen];
    
    CGRect frame = self.pictureDialog.frame;
    frame.origin.x = 480;
    self.pictureDialog.frame = frame;
    
    
    //Moved from animate show info box
    frame = self.pictureInfo.frame;
    frame.origin.x = 480;
    self.pictureInfo.frame = frame;
    [self.view addSubview:self.pictureInfo];
    //[UIView beginAnimations:@"anim" context:nil];
    frame = self.pictureInfo.frame;
    frame.origin.x = 0;
    self.pictureInfo.frame = frame;
    
 
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
   // [UIView setAnimationDidStopSelector:@selector(animateShowInfoBox)];
    [UIView commitAnimations];
    
}

- (IBAction) didTouchSendButton:(id)sender{

    
    //Generate testing coordinates
    /*
     float latHigh = 42.454865;
     float latLow = 42.340973;
     float longHigh = -83.157413;
     float longLow = -82.930849;
     float latitude = latLow + (latHigh-latLow) * ( arc4random() % 1000 )/1000;
     float  longitude = longLow + (longHigh-longLow)* ( arc4random() % 1000 )/1000;
    */
    
    CGSize thumbSize;
    thumbSize.width = 100;
    thumbSize.height = 100;
    
    CGSize contentSize;
    contentSize.width = 500;
    contentSize.height = 500;
    
    // Create a bitmap graphics context
    // This will also set it as the current context
    UIGraphicsBeginImageContext(thumbSize);
    
    // Draw the scaled image in the current context
    /*
    [currentImage drawInRect:CGRectMake(3200/2 - contentSize.width/2  , 4800/2 - contentSize.height/2,
                                        contentSize.width, contentSize.height)];
    */
    [currentImage drawInRect:CGRectMake(0, 0, 100, 100)];
     
    // Create a new image from current context
    UIImage* thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    
    NSData * thumbImageDataJpeg = UIImageJPEGRepresentation(thumbImage, .8);

    
    
    //Medium size
    CGSize mediumSize;
    mediumSize.width = 480;
    mediumSize.height = 320;
    
    UIGraphicsBeginImageContext(mediumSize);
    [currentImage drawInRect:CGRectMake(0, 0, 480, 320)];
    UIImage* mediumImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * mediumImageDataJpeg = UIImageJPEGRepresentation(mediumImage, .8);

                                                
    /*
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
*/
    //Move some of this into a model for the app
    //Would be usefull to have a scenario like
    // [Document init]
    // [Document addAttachment]
    // [Document addAttachment]
    // [Document save]
    //  We want Rhus to be able to support easily writing a custom model
    //  The model could be queried for dynamic form setup
    

    
    NSMutableDictionary * newDocument = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         self.reporter.text, @"reporter",
                                         self.comment.text, @"comment",
                                         [RHLocation getLatitudeString], @"latitude", 
                                         [RHLocation getLongitudeString], @"longitude",
                                         [RESTBody JSONObjectWithDate: [NSDate date]], @"created_at",
                                         @"", @"thumb",
                                         @"", @"medium",
                                         [DeviceUser uniqueIdentifier], @"deviceuser_identifier",
                                         nil];

    for(NSString * attribute in selectedAttributes){
        [newDocument setObject:@"true" forKey:attribute];
    }
    
    /* */
    [MapDataModel addDocument:newDocument 
                  withAttachments: [NSArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     thumbImageDataJpeg,  @"data", 
                                     @"thumb.jpg", @"name", 
                                     @"image/jpeg", @"contentType",
                                     nil
                                     ],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     mediumImageDataJpeg,  @"data", 
                                     @"medium.jpg",  @"name", 
                                     @"image/jpeg", @"contentType", 
                                     nil
                                     ],
                                    /*
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     UIImageJPEGRepresentation(currentImage, 1.0),  @"data", 
                                     @"full.jpg",  @"name", 
                                     @"image/jpeg", @"contentType", 
                                     nil
                                     ],*/
                                    nil
                                    ]
     ];

    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationDuration:0.50];
    CGRect frame = self.pictureInfo.frame;
    frame.origin.x = 480;
    self.pictureInfo.frame = frame;
    
    [fullscreenTransitionDelegate subviewReleasingFullscreen];
    [UIView commitAnimations];
    
    [self clearFormFields];

    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];

}

- (IBAction) resignFirstResponder:(id)sender {
    [self resignFirstResponder];
}


- (void) setToggleButtonState:(UIButton *) button{
   // NSLog(@"Setting %d", button.tag);

    if(button.selected){
        button.selected = NO;
        NSString * attribute = (NSString *) [attributeTranslation objectForKey:[NSNumber numberWithInt:button.tag]];
        [selectedAttributes removeObject:attribute];

    } else {
        button.selected = YES;
        NSString * attribute = (NSString *) [attributeTranslation objectForKey:[NSNumber numberWithInt:button.tag]];
        [selectedAttributes addObject:attribute];
        
    }
}


//Generalize/Superclass
- (IBAction) didTouchPetalRadio:(id)sender{
    UIButton * button = (UIButton *) sender;
    
    [self setToggleButtonState: button];
    
    int radioFields[5] = {kThreePetal, kFourPetal, kFivePetal, kSixPetal, kManyPetal};
    for(int i=0; i<5; i++){
        int tag = radioFields[i];
    //    NSLog(@"%d", tag);
        if(radioFields[i]!=button.tag){
            UIButton * aButton = (UIButton *) [self.view viewWithTag:radioFields[i]];
            if(aButton.selected){
                aButton.selected = NO;
                NSString * attribute = (NSString *) [attributeTranslation objectForKey:[NSNumber numberWithInt:tag]];
                [selectedAttributes removeObject:attribute];
            }
        }
    }
    

}

- (IBAction) didTouchAttributeCheckbox:(id)sender{
    UIButton * button = (UIButton *) sender;
    [self setToggleButtonState: button ];
}

//abstract?
- (void) clearFormFields {
    int radioFields[9] = {kThreePetal, kFourPetal, kFivePetal, kSixPetal, kManyPetal,kIrregular,kComposite,kTree,kFruit};
    for(int i=0; i<9; i++){
        
        UIButton * button = (UIButton *) [self.view viewWithTag:radioFields[i]];
        button.selected = NO;
        NSString * attribute = (NSString *) [attributeTranslation objectForKey:[NSNumber numberWithInt:i]];
        [selectedAttributes removeObject:attribute];
        
    }
    
}


#pragma mark UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    currentImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [imageView setImage:currentImage];
    if(self.activeImageOrientation == kPortraitPhoto){
    //    imageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
    }
    [self.view insertSubview:imageView belowSubview:shutterView];
    [self showPictureDialog];
    [shutterView removeFromSuperview];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

}


@end
