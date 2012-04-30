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
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    SwoopTabViewController * swoopTabViewController;
    BOOL isDoneStartingUp;
    BOOL internetActive;
    Reachability * internetReachable;
}


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SwoopTabViewController * swoopTabViewController;
@property (strong, nonatomic) LoadingViewController * loadingViewController;
@property (strong, nonatomic) Reachability * internetReachable;
@property (nonatomic) BOOL internetActive;

- (void) initializeAppDelegateAndLaunch;
- (void) initializeDataModel;
- (void) initializeInBackground;
- (void) doneStartingUp;
- (void) checkNetworkStatus:(NSNotification *)notice;



@end
