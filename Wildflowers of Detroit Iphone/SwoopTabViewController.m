//
//  SwoopTabViewController.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SwoopTabViewController.h"

#define kTop 1
#define kMiddle 2
#define kBottom 3

@implementation SwoopTabViewController

@synthesize topButton, middleButton, bottomButton;
@synthesize controlsBackgroundImage;
@synthesize topBackground, middleBackground, bottomBackground;

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
    return FALSE;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBActions
- (IBAction)didTouchTopButton:(id)sender{
    [self updateTabBackground:kTop];
    self.topButton.selected = YES;
    self.middleButton.selected = NO;
    self.bottomButton.selected = NO;

}

- (IBAction)didTouchMiddleButton:(id)sender{
    [self updateTabBackground:kMiddle];
    self.topButton.selected = NO;
    self.middleButton.selected = YES;
    self.bottomButton.selected = NO;
}

- (IBAction)didTouchBottomButton:(id)sender{
    [self updateTabBackground:kBottom];
    self.topButton.selected = NO;
    self.middleButton.selected = NO;
    self.bottomButton.selected = YES;
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

@end
