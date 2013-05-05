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

#define kTop 1
#define kMiddle 2
#define kBottom 3

@implementation SwoopTabViewController

@synthesize topButton, middleButton, bottomButton;
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
        manualAppearCallbacks = TRUE;
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
    

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}

#pragma mark - IBActions
- (IBAction)didTouchTopButton:(id)sender{
    [self updateTabBackground:kTop];
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
    
    NSArray * documents;
    documents = [RHDataModel getAllDocuments];
    NSLog(@"local db doc size = %d", [documents count]);
    id obj = [documents objectAtIndex:1];
    RHRemoteUploader *rhupload = [[RHRemoteUploader alloc] initWithHostName:@"jrmfelipe.iriscouch.com"
                                                                       port:nil
                                                                     useSSL:NO
                                                                   username:@"jrmfelipe"
                                                                   password:@"mc1999"
                                                                   database:@"testing"];
    [rhupload setDocument:obj];
    [rhupload uploadWithFinishedBlock:^(MKNetworkOperation *operation) {
            NSLog(@"didTouchUploadButton2 uploadWithFinishedBlock %@", operation);
        } errorBlock:^(NSError *error) {
            NSLog(@"didTouchUploadButton2 error block %@", error);
    }];
    
   // http://winterroot:dieis8835nd@data.winterroot.net:5984/houseofsaltmarsh
}

- (IBAction)didTouchUploadButton:(id)sender {
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
    AppDelegate *delegate = APPDELEGATE;
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
