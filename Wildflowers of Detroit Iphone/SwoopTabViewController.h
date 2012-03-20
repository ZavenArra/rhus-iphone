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
<FullscreenTransitionDelegate>
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
    
    NSInteger currentTab;
    
}


@property (retain, nonatomic) UIViewController * topViewController;
@property (retain, nonatomic) UIViewController * middleViewController;
@property (retain, nonatomic) UIViewController * bottomViewController;


@property (retain, nonatomic) IBOutlet UIButton * topButton;
@property (retain, nonatomic) IBOutlet UIButton * middleButton;
@property (retain, nonatomic) IBOutlet UIButton * bottomButton;
@property (retain, nonatomic) IBOutlet UIView * controlsView;
@property (retain, nonatomic) IBOutlet UIImageView * controlsBackgroundImage;


@property (retain, nonatomic) UIImage * topBackground;
@property (retain, nonatomic) UIImage * middleBackground;
@property (retain, nonatomic) UIImage * bottomBackground;

@property (nonatomic) BOOL tabsHidden;

@property (nonatomic) NSInteger currentTab;


#pragma mark - IBActions
- (IBAction)didTouchTopButton:(id)sender;
- (IBAction)didTouchMiddleButton:(id)sender;
- (IBAction)didTouchBottomButton:(id)sender;


#pragma mark - Interface Functions
- (void) updateTabBackground:(int) backgroundSelected;

@end
