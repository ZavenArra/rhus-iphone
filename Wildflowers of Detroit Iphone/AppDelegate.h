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


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SwoopTabViewController * swoopTabViewController;
@property (strong, nonatomic) LoadingViewController * loadingViewController;

- (void) initializeAppDelegateAndLaunch;
- (void) initializeDataModel;

- (void) initializeInBackground;


@end
