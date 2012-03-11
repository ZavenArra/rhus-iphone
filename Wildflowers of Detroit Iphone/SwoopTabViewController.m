//
//  SwoopTabViewController.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SwoopTabViewController.h"
#import "CameraViewController.h" /*TODO: refactor this out, once camera controls are figured out*/

#define kTop 1
#define kMiddle 2
#define kBottom 3

@implementation SwoopTabViewController

@synthesize topButton, middleButton, bottomButton;
@synthesize controlsBackgroundImage, controlsView  ;
@synthesize topBackground, middleBackground, bottomBackground;
@synthesize topViewController, middleViewController, bottomViewController;
@synthesize tabsHidden, currentTab;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentTab = kMiddle;
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
    
    [self didTouchMiddleButton:self];

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
    [self.view insertSubview:topViewController.view atIndex:0];
    
    currentTab = kTop;
}

- (IBAction)didTouchMiddleButton:(id)sender{
    if(self.middleButton.selected == YES){
        [(CameraViewController *) self.middleViewController secondTapTabButton];
        return;
    }
    
    
    [self updateTabBackground:kMiddle];
    self.topButton.selected = NO;
    self.middleButton.selected = YES;
    self.bottomButton.selected = NO;
    
    [topViewController.view removeFromSuperview];
    [bottomViewController.view removeFromSuperview];
    [self.view insertSubview:middleViewController.view atIndex:0];
    
    currentTab = kMiddle;
}

- (IBAction)didTouchBottomButton:(id)sender{
    [self updateTabBackground:kBottom];
    self.topButton.selected = NO;
    self.middleButton.selected = NO;
    self.bottomButton.selected = YES;
    
    
    [topViewController.view removeFromSuperview];
    [middleViewController.view removeFromSuperview];
    [self.view insertSubview:bottomViewController.view atIndex:0];
    
    currentTab = kBottom;


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

@end
