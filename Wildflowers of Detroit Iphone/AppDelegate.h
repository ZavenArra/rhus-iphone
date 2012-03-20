//
//  AppDelegate.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwoopTabViewController.h"
#import "LoadingViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    SwoopTabViewController * swoopTabViewController;
}


@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) SwoopTabViewController * swoopTabViewController;
@property (retain, nonatomic) LoadingViewController * loadingViewController;

- (void) initializeAppDelegateAndLaunch;

- (void) initializeInBackground;

- (void) doneStartingUp;


@end
