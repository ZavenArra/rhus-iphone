//
//  SwoopTabViewController.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SwoopTabViewController.h"
#import "CameraViewController.h" /*TODO: refactor this out, once camera controls are figured out*/
#import "AppDelegate.h"
#import "RHDataModel.h"
#import "RHRemoteUploader.h"
#import "MBProgressHUD.h"
#import "RHSettings.h"

#define kTop 1
#define kMiddle 2
#define kBottom 3

@implementation SwoopTabViewController

@synthesize topButton, middleButton, bottomButton, uploadButton;
@synthesize controlsBackgroundImage, controlsView  ;
@synthesize topBackground, middleBackground, bottomBackground;
@synthesize topViewController, middleViewController, bottomViewController;
@synthesize tabsHidden, currentTab;
@synthesize manualAppearCallbacks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentTab = kMiddle;
    }
    return self;
}

- (id) init {
    self = [super init];
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    if (ver_float < 5.0) 
        manualAppearCallbacks = FALSE;//TRUE;
    else
        manualAppearCallbacks = FALSE;

    firstRun = true;
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load and cache swoop graphics
    self.topBackground = [UIImage imageNamed:@"swoopBarTop"];
    self.middleBackground = [UIImage imageNamed:@"swoopBarMiddle"];
    self.bottomBackground = [UIImage imageNamed:@"swoopBarBottom"];

    if  (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation] ))
        NSLog(@"LandScape");
    else
        NSLog(@"not LandScape = %d",[[UIDevice currentDevice] orientation]);
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if  (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation] ))
        NSLog(@"LandScape");
    else
        NSLog(@"not LandScape = %d",[[UIDevice currentDevice] orientation]);
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    if  (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation] ))
        NSLog(@"LandScape");
    else
        NSLog(@"not LandScape = %d",[[UIDevice currentDevice] orientation]);
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if  (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation] ))
        NSLog(@"LandScape");
    else
        NSLog(@"not LandScape = %d",[[UIDevice currentDevice] orientation]);
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


#pragma mark - IBActions
- (IBAction)didTouchTopButton:(id)sender{
    [self updateTabBackground:kTop];
    [uploadButton setHidden:YES];
    self.topButton.selected = YES;
    self.middleButton.selected = NO;
    self.bottomButton.selected = NO;

    [middleViewController.view removeFromSuperview];
    [bottomViewController.view removeFromSuperview];
    if(manualAppearCallbacks)
        [topViewController viewWillAppear:NO];
    [self.view insertSubview:topViewController.view atIndex:0];
    if(manualAppearCallbacks)
        [topViewController viewDidAppear:NO];
    
    currentTab = kTop;
}

- (IBAction)didTouchMiddleButton:(id)sender{
    if(self.middleButton.selected == YES){
        [(CameraViewController *) self.middleViewController secondTapTabButton];
        if(manualAppearCallbacks){
            CameraViewController * cameraViewController = (CameraViewController*) middleViewController;
            [self presentModalViewController:cameraViewController.imagePicker animated:YES];
        }
        return;
    }
    [uploadButton setHidden:YES];
    [self updateTabBackground:kMiddle];
    self.topButton.selected = NO;
    self.middleButton.selected = YES;
    self.bottomButton.selected = NO;
    
    [topViewController.view removeFromSuperview];
    [bottomViewController.view removeFromSuperview];
    if(manualAppearCallbacks)
        [middleViewController viewWillAppear:NO];
    [self.view insertSubview:middleViewController.view atIndex:0];
    if(manualAppearCallbacks)
        [middleViewController viewDidAppear:NO];
    
    
    if(manualAppearCallbacks){
        CameraViewController * cameraViewController = (CameraViewController*) middleViewController;
        cameraViewController.imagePicker.delegate = self;
        [self presentModalViewController:cameraViewController.imagePicker animated:YES];
    }
    
    currentTab = kMiddle;
}

- (IBAction)didTouchBottomButton:(id)sender{
    [self updateTabBackground:kBottom];
    self.topButton.selected = NO;
    self.middleButton.selected = NO;
    self.bottomButton.selected = YES;
    [self updateUploadButton]; // show/hide button based on reachability status
    
    [topViewController.view removeFromSuperview];
    [middleViewController.view removeFromSuperview];
    if(manualAppearCallbacks)
        [bottomViewController viewWillAppear:NO];
    
    [self.view insertSubview:bottomViewController.view atIndex:0];
    
    if(!firstRun){
        if(manualAppearCallbacks)
            [bottomViewController viewDidAppear:NO];
    }
    firstRun = NO;
    
    currentTab = kBottom;


}

- (IBAction)didTouchUploadButton2:(id)sender {
    
    // DEBUG purpose only
    //docsToUpload = [RHDataModel getAllDocuments];
    //for (id obj in docsToUpload)
    //{
    //    //[obj setObject:@"NO" forKey:@"uploaded"];
    //    [obj removeObjectForKey:@"uploaded"];
    //    [RHDataModel updateDocument:obj];
    //}
    // end DEBUG
    
    
    docsToUpload = [RHDataModel getAllDocumentsNotUploaded];
    //documents = [RHDataModel getAllDocuments];
    NSInteger totalItem = [docsToUpload count];
    NSLog(@"local db doc size = %d",totalItem);
    if (totalItem==0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Upload"
                                    message:@"Nothing to upload."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //totalItem = 1;
    nUnsuccessfulUploadCtr = 0;
    [self uploadToRemoteDB:0 totalItem:totalItem progressUI:hud];
    
    /*
    for (NSInteger i=0; i<totalItem; i++)
    {
        id obj = [documents objectAtIndex:i];
        [hud setLabelText:[NSString stringWithFormat:@"Uploading %d of %d",i+1,totalItem]];
    
        RHRemoteUploader *rhupload = [[RHRemoteUploader alloc] initWithHostName:@"jrmfelipe.iriscouch.com"
                                                                       port:nil
                                                                     useSSL:NO
                                                                   username:@"jrmfelipe"
                                                                   password:@"mc1999"
                                                                   database:@"testing"];
        [rhupload setDocument:obj];
        [rhupload uploadWithFinishedBlock:^(NSDictionary *result) {
            NSLog(@"didTouchUploadButton2 uploadWithFinishedBlock %@", result);
            if ((i+1)>=totalItem)
            {
                [hud hide:YES];
                [[[UIAlertView alloc] initWithTitle:@"Upload"
                                            message:@"Upload Successful"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        } errorBlock:^(NSDictionary *result, NSError *error) {
                NSLog(@"didTouchUploadButton2 error result %@", result);
                NSLog(@"didTouchUploadButton2 error block %@", error);
                [hud hide:YES];
                NSString *strCaption = [NSString stringWithFormat:@"Upload Error (%d)", error.code];
                [[[UIAlertView alloc] initWithTitle:strCaption
                                            message:[error localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            }];
    }
    */
   // http://winterroot:dieis8835nd@data.winterroot.net:5984/houseofsaltmarsh
}

- (void)uploadToRemoteDB:(NSInteger)index totalItem:(NSInteger)total progressUI:(MBProgressHUD *)hud
{
    __block NSInteger idx = index;
    
    id obj = [docsToUpload objectAtIndex:index];
    [hud setLabelText:[NSString stringWithFormat:@"Uploading %d of %d",index+1,total]];
    
    RHRemoteUploader *rhupload = [[RHRemoteUploader alloc] initWithHostName:[RHSettings databaseHost]
                                                                       port:nil
                                                                     useSSL:NO
                                                                   username:[RHSettings databaseUser]
                                                                   password:[RHSettings databasePassword]
                                                                   database:[RHSettings databaseName] ];
    [rhupload setDocument:obj];
    [rhupload uploadWithFinishedBlock:^(NSDictionary *result) {
        NSLog(@"didTouchUploadButton2 uploadWithFinishedBlock %@", result);
        if ((index+1)>=total)
        {
            [obj setObject:@"YES" forKey:@"uploaded"];
            BOOL bResult = [RHDataModel updateDocument:obj];
            NSLog(@"bResult(%d) = %d",index,bResult);
            [hud hide:YES];
            if (nUnsuccessfulUploadCtr>0)
            {
                [[[UIAlertView alloc] initWithTitle:@"Upload"
                                            message:[NSString stringWithFormat:@"%d out of %d items was successfully uploaded.",total-nUnsuccessfulUploadCtr, total]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Upload Successful"
                                            message:[NSString stringWithFormat:@"%d items uploaded.",total]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }
        else
        {
            //update local DB
            [obj setObject:@"YES" forKey:@"uploaded"];
            BOOL bResult = [RHDataModel updateDocument:obj];
            NSLog(@"bResult(%d) = %d",index,bResult);
            idx++;
            [self uploadToRemoteDB:idx totalItem:total progressUI:hud];
        }
    } errorBlock:^(NSDictionary *result, NSError *error) {
        nUnsuccessfulUploadCtr++;
        idx++;
        //Stop the upload on specific error such as timeout
        if (error.code!=101) //"The request timed out." or any other NSURLRequest error
        {
            [hud hide:YES];
            NSString *strCaption = [NSString stringWithFormat:@"Upload Error (%d)", error.code];
            NSString *strMessage = [NSString stringWithFormat:@"%@\nUpload operation halted",[error localizedDescription]];
            if (nUnsuccessfulUploadCtr!=idx)
            {
                strMessage = [NSString stringWithFormat:@"%@\n%d out of %d uploaded",[error localizedDescription],idx-nUnsuccessfulUploadCtr, total];
            }
            [[[UIAlertView alloc] initWithTitle:strCaption
                                        message:strMessage
                                       delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil] show];
            return;
        }
        
        
        
        if ((index+1)>=total)
        {
            [hud hide:YES];
            if (nUnsuccessfulUploadCtr==total)
            {
                if (total==1)
                {
                    NSString *strCaption = [NSString stringWithFormat:@"Upload Error (%d)", error.code];
                    [[[UIAlertView alloc] initWithTitle:strCaption
                                                message:[error localizedDescription]
                                               delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:@"Upload Error"
                                                message:@"All document upload failed."
                                               delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Upload"
                                            message:[NSString stringWithFormat:@"%d out of %d items was successfully uploaded.",total-nUnsuccessfulUploadCtr, total]
                                           delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            }
        }
        else
            [self uploadToRemoteDB:idx totalItem:total progressUI:hud];
        /*
        NSLog(@"didTouchUploadButton2 error result %@", result);
        NSLog(@"didTouchUploadButton2 error block %@", error);
        [hud hide:YES];
        NSString *strCaption = [NSString stringWithFormat:@"Upload Error (%d)", error.code];
        NSString *strMessage = [NSString stringWithFormat:@"%@\n\n%d out of %d uploaded",[error localizedDescription],idx,total];
        [[[UIAlertView alloc] initWithTitle:strCaption
                                    message:strMessage
                                   delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
         */
    }];
}

- (IBAction)didTouchUploadButton:(id)sender {
    AppDelegate *delegate = APPDELEGATE;
    if (delegate.internetActive==NO)
    {
        [[[UIAlertView alloc] initWithTitle:@"Upload Error"
                                    message:@"Internet connection is required to upload."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    [self didTouchUploadButton2:sender];
    return;
    NSLog(@"didTouchUploadButton");
    
    
    NSArray * documents;
    documents = [RHDataModel getAllDocuments];
    NSLog(@"local db doc size = %d", [documents count]);
    NSDictionary *obj = [documents objectAtIndex:1];
    //NSLog(@"documents = %@",obj);
    
    NSDictionary *attachments = [obj objectForKey:@"_attachments"];
    NSMutableArray *arrAttachments = [NSMutableArray array];
    if ([attachments count]>0)
    {
        // get the list image name
        NSArray *imgNames = [attachments allKeys];
        for (NSString *name in imgNames)
        {
            NSString *strExt = @".jpg";
            NSString *cleanName = [name substringToIndex:[name length]-[strExt length]];
            [arrAttachments addObject:cleanName];
        }
    }
    
    NSArray *keys = [obj allKeys];
    NSString *strID = @"";
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    for (NSString *key in keys)
    {
        
        if ([key isEqualToString:@"_id"])
        {
            strID = [obj objectForKey:key];
            continue;
        }
        else if ([key isEqualToString:@"_attachments"])
            continue;
        else if ([key isEqualToString:@"_rev"])
            continue;
        BOOL bContinue = NO;
        for (NSString *imgName in arrAttachments)
        {
            if ([key isEqualToString:imgName])
            {
                bContinue = YES;
                break;
            }
        }
        if (bContinue)
            continue;
        [param setObject:[obj objectForKey:key] forKey:key];
    }
        
    /*
    NSError* error;
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSDictionary* dic = [NSJSONSerialization
                          JSONObjectWithData:myData
                          options:kNilOptions
                          error:&error];
    if (error!=nil)
        NSLog(@"error = %@",error);
     
    NSLog(@"dic = %@",dic);
    */
    //AppDelegate *delegate = APPDELEGATE;
    ////http://winterroot:dieis8835nd@data.winterroot.net:5984/houseofsaltmarsh
    NSString *strPath = [NSString stringWithFormat:@"testing/%@",strID];
    MKNetworkOperation *op = [delegate.networkEngine operationWithPath:strPath
                                                                params:param
                                                            httpMethod:@"PUT"
                                                                   ssl:NO];
    [op setUsername:@"jrmfelipe" password:@"mc1999" basicAuth:YES];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"%@", [operation responseString]);
       // NSString *strResponse = [operation responseString];
        NSError* error;
        NSDictionary* response = [NSJSONSerialization
                              JSONObjectWithData:[operation responseData] //1
                              
                              options:kNilOptions
                              error:&error];
        
        //NSLog(@"jsonArray count = %d",[jsonArray count]);
        NSLog(@"response = %@",response);
        NSString *strRev = [response objectForKey:@"rev"];
        NSLog(@"rev = %@",strRev);
        [self uploadPhotoToDoc:obj revision:strRev];
       
    } errorHandler:^(MKNetworkOperation *operation,NSError *error) {
         NSLog(@"%@", error);
    }]; 
    [delegate.networkEngine enqueueOperation:op];
}

- (void)uploadPhotoToDoc:(NSDictionary *)docObj revision:(NSString *)strRev {
    NSLog(@"documents = %@",docObj);
    NSLog(@"rev = %@",strRev);
    NSString *strID = [docObj objectForKey:@"_id"];
    
    
    NSDictionary *attachments = [docObj objectForKey:@"_attachments"];
    NSMutableArray *arrAttachments = [NSMutableArray array];
    if ([attachments count]>0)
    {
        // get the list image name
        NSArray *imgNames = [attachments allKeys];
        for (NSString *name in imgNames)
        {
            NSString *strExt = @".jpg";
            NSString *cleanName = [name substringToIndex:[name length]-[strExt length]];
            [arrAttachments addObject:cleanName];
        }
    }
    
    NSArray *keys = [docObj allKeys];
    NSData *imgData = nil;
    NSString *strAttachmentName = @"";
    for (NSString *key in keys)
    {
        if ([key isEqualToString:@"_id"])
            continue;
        else if ([key isEqualToString:@"_attachments"])
            continue;
        else if ([key isEqualToString:@"_rev"])
            continue;
        BOOL bGotImage = NO;
        for (NSString *imgName in arrAttachments)
        {
            if ([key isEqualToString:imgName])
            {
                bGotImage = YES;
                strAttachmentName = key;
                imgData = [NSData dataFromBase64String:[docObj objectForKey:key]];
                break;
            }
        }
        if (bGotImage)
            break;
    }
    
    //NSDictionary *attachmentObj = [attachments objectForKey:[NSString stringWithFormat:@"%@.jpg",strAttachmentName]];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"image/jpeg" forKey:@"Content-Type"];
    
    NSLog(@"imgData length = %d",[imgData length]);
    
    AppDelegate *delegate = APPDELEGATE;
    NSString *strPath = [NSString stringWithFormat:@"testing/%@/%@.jpg?rev=%@",strID,strAttachmentName,strRev];
    MKNetworkOperation *op = [delegate.networkEngine operationWithPath:strPath
                                                                params:nil
                                                            httpMethod:@"PUT"
                                                                   ssl:NO];
    [op addRawData:imgData];
    //[op addData:imgData forKey:strAttachmentName mimeType:@"image/jpeg" fileName:strAttachmentName];
    [op setUsername:@"jrmfelipe" password:@"mc1999" basicAuth:YES];
    //[op setPostDataEncoding:MKNKPostDataEncodingTypeCustom];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"%@", [operation responseString]);
        // NSString *strResponse = [operation responseString];
        NSError* error;
        NSDictionary* response = [NSJSONSerialization
                                  JSONObjectWithData:[operation responseData] //1
                                  
                                  options:kNilOptions
                                  error:&error];
        
        //NSLog(@"jsonArray count = %d",[jsonArray count]);
        NSLog(@"response = %@",response);
        NSString *strRev = [response objectForKey:@"rev"];
        NSLog(@"rev = %@",strRev);
        
    } errorHandler:^(MKNetworkOperation *operation,NSError *error) {
        NSLog(@"%@", error);
    }];
    [delegate.networkEngine enqueueOperation:op];
}


#pragma mark - Interface Functions

- (void) updateTabBackground:(int) backgroundSelected {
    switch(backgroundSelected){
        case kTop:
            controlsBackgroundImage.image = self.topBackground;
            break;
        case kMiddle:
            controlsBackgroundImage.image = self.middleBackground;
            break;
        case kBottom:
            controlsBackgroundImage.image = self.bottomBackground;
            break;
    }
}

- (void) updateUploadButton
{
    AppDelegate *delegate = APPDELEGATE;
    if (delegate.internetActive==NO)
    {
        [uploadButton setHidden:YES];
    }
    else
    {
        if ([self.bottomButton isSelected])
            [uploadButton setHidden:NO];
    }
}


- (void) createHideTabsAnimation{
    CGRect frame = self.controlsView.frame;
    frame.origin.x += frame.size.width;
    self.controlsView.frame = frame;
}

- (void) createShowTabsAnimation{
    CGRect frame = self.controlsView.frame;
    frame.origin.x -= frame.size.width;
    self.controlsView.frame = frame;
    
}

#pragma mark - Fullscreen Transition Delegate functions
-(void) subviewRequestingFullscreen {
    if(!tabsHidden){
        [self createHideTabsAnimation];
        tabsHidden = TRUE;
    }
}

-(void) subviewReleasingFullscreen {
    if(tabsHidden){
        [self createShowTabsAnimation];
        tabsHidden = FALSE;
    }
}

#pragma mark UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * currentImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [ (CameraViewController *) [self middleViewController] confirmImageWithUser: currentImage];
    [self dismissModalViewControllerAnimated:[(CameraViewController *) [self middleViewController] imagePicker]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];

}

@end
