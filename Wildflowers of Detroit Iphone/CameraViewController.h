//
//  CameraViewController.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullscreenTransitionDelegate.h"


#define kLandscapePhoto 1
#define kPortraitPhoto 2

@interface CameraViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
    UIImagePickerController * imagePicker;
    UIView * pictureDialog;
    UIView * pictureInfo;
    UITextField * reporter;
    UITextField * comment;
    NSInteger activeImageOrientation;
}
@property(retain, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(retain, nonatomic)  UIImagePickerController * imagePicker;
@property(retain, nonatomic)  IBOutlet   UIView * pictureDialog;
@property(retain, nonatomic)  IBOutlet   UIView * pictureInfo;
@property(retain, nonatomic)  IBOutlet   UITextField * reporter;
@property(retain, nonatomic)  IBOutlet   UITextField * comment;
@property(retain, nonatomic)  IBOutlet   UIImageView * imageView;
@property(retain, nonatomic)  UIImage * currentImage;
@property(retain, nonatomic)  IBOutlet   UIView * shutterView;
@property(nonatomic) NSInteger activeImageOrientation;

//Generalized / Superclass
@property(retain, nonatomic)  NSDictionary * attributeTranslation;
@property(retain, nonatomic)  NSMutableArray * selectedAttributes;

- (void) secondTapTabButton;

- (IBAction) didTouchRetakeButton:(id)sender;
- (IBAction) didTouchUploadButton:(id)sender;
- (IBAction) didTouchSendButton:(id)sender;
- (IBAction) resignFirstResponder:(id)sender;
- (IBAction) didTouchCancelUploadButton:(id)sender;

- (void) showPictureDialog;
- (void) hidePictureDialog;
- (void) animateShowInfoBox;
- (void) showImagePickerView;


- (void) setToggleButtonState:(UIButton *) button;



//Generalize/Superclass
- (IBAction) didTouchPetalRadio:(id)sender;
- (IBAction) didTouchAttributeCheckbox:(id)sender;
//abstract?
- (void) clearFormFields;
@end
