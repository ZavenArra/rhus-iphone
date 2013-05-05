//
//  SwoopTabViewController.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullscreenTransitionDelegate.h"

@interface SwoopTabViewController : UIViewController
<FullscreenTransitionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIButton * topButton;
    UIButton * middleButton;
    UIButton * bottomButton;
    UIView * controlsView;
    UIImageView * controlsBackgroundImage;
    UIImage * topBackground;
    UIImage * middleBackground;
    UIImage * bottomBackground;
    
    UIViewController * topViewController;
    UIViewController * middleViewController;
    UIViewController * bottomViewController;
    
    BOOL tabsHidden;
    BOOL manualAppearCallbacks;
    BOOL firstRun;

    
    NSInteger currentTab;
    
}

@property (strong, nonatomic) IBOutlet UIButton * topButton;
@property (strong, nonatomic) IBOutlet UIButton * middleButton;
@property (strong, nonatomic) IBOutlet UIButton * bottomButton;
@property (strong, nonatomic) IBOutlet UIView * controlsView;
@property (strong, nonatomic) IBOutlet UIImageView * controlsBackgroundImage;

@property (strong, nonatomic) UIViewController * topViewController;
@property (strong, nonatomic) UIViewController * middleViewController;
@property (strong, nonatomic) UIViewController * bottomViewController;
@property (strong, nonatomic) UIImage * topBackground;
@property (strong, nonatomic) UIImage * middleBackground;
@property (strong, nonatomic) UIImage * bottomBackground;
@property (nonatomic) BOOL tabsHidden;
@property (nonatomic) BOOL manualAppearCallbacks;
//@property (nonatomic) BOOL firstRun;

@property (nonatomic) NSInteger currentTab;


#pragma mark - IBActions
- (IBAction)didTouchTopButton:(id)sender;
- (IBAction)didTouchMiddleButton:(id)sender;
- (IBAction)didTouchBottomButton:(id)sender;
- (IBAction)didTouchUploadButton:(id)sender;
- (IBAction)didTouchUploadButton2:(id)sender;


#pragma mark - Interface Functions
- (void) updateTabBackground:(int) backgroundSelected;

@end
