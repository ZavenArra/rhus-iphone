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
    BOOL useCustomCamera;
}
@property(strong, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(strong, nonatomic)  UIImagePickerController * imagePicker;
@property(strong, nonatomic)  IBOutlet   UIView * pictureDialog;
@property(strong, nonatomic)  IBOutlet   UIView * pictureInfo;
@property(strong, nonatomic)  IBOutlet   UITextField * reporter;
@property(strong, nonatomic)  IBOutlet   UITextField * comment;
@property(strong, nonatomic)  IBOutlet   UIImageView * imageView;
@property(strong, nonatomic)  UIImage * currentImage;
@property(strong, nonatomic)  IBOutlet   UIView * shutterView;
@property(nonatomic) NSInteger activeImageOrientation;
@property(nonatomic) BOOL useCustomCamera;

//Generalized / Superclass
@property(strong, nonatomic)  NSDictionary * attributeTranslation;
@property(strong, nonatomic)  NSMutableArray * selectedAttributes;

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
- (void) showModalCamera;
- (void) setToggleButtonState:(UIButton *) button;
- (void) confirmImageWithUser: (UIImage *) currentImage;





//Generalize/Superclass
- (IBAction) didTouchPetalRadio:(id)sender;
- (IBAction) didTouchAttributeCheckbox:(id)sender;
//abstract?
- (void) clearFormFields;
@end
