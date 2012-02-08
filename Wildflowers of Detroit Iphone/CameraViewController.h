//
//  CameraViewController.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullscreenTransitionDelegate.h"

@interface CameraViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
    UIImagePickerController * imagePicker;
    UIView * pictureDialog;
    UIView * pictureInfo;
    UITextField * reporter;
    UITextField * comment;

}
@property(strong, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(strong, nonatomic)  UIImagePickerController * imagePicker;
@property(strong, nonatomic)  IBOutlet   UIView * pictureDialog;
@property(strong, nonatomic)  IBOutlet   UIView * pictureInfo;
@property(strong, nonatomic)  IBOutlet   UITextField * reporter;
@property(strong, nonatomic)  IBOutlet   UITextField * comment;


- (void) secondTapTabButton;

- (IBAction) didTouchRetakeButton:(id)sender;
- (IBAction) didTouchUploadButton:(id)sender;
- (IBAction) didTouchSendButton:(id)sender;
- (IBAction) resignFirstResponder:(id)sender;


- (void) showPictureDialog;
- (void) hidePictureDialog;
- (void) animateShowInfoBox;

@end
