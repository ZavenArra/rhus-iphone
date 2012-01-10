//
//  SwoopTabViewController.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwoopTabViewController : UIViewController
{
    UIButton * topButton;
    UIButton * middleButton;
    UIButton * bottomButton;
    UIImageView * controlsBackgroundImage;
    UIImage * topBackground;
    UIImage * middleBackground;
    UIImage * bottomBackground;
    
}

/*
@property (strong, nonatomic) UIViewController * topViewController;
@property (strong, nonatomic) UIViewController * middleViewController;
@property (strong, nonatomic) UIViewController * bottomViewController;
*/

@property (strong, nonatomic) IBOutlet UIButton * topButton;
@property (strong, nonatomic) IBOutlet UIButton * middleButton;
@property (strong, nonatomic) IBOutlet UIButton * bottomButton;
@property (strong, nonatomic) IBOutlet UIImageView * controlsBackgroundImage;


@property (strong, nonatomic) UIImage * topBackground;
@property (strong, nonatomic) UIImage * middleBackground;
@property (strong, nonatomic) UIImage * bottomBackground;


#pragma mark - IBActions
- (IBAction)didTouchTopButton:(id)sender;
- (IBAction)didTouchMiddleButton:(id)sender;
- (IBAction)didTouchBottomButton:(id)sender;


#pragma mark - Interface Functions
- (void) updateTabBackground:(int) backgroundSelected;

@end
