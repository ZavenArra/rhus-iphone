//
//  AppDelegate.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "GalleryViewController.h"
#import "CameraViewController.h"
#import "MapViewController.h"
#import "MapDataModel.h"
#import "RHLocation.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize swoopTabViewController;
@synthesize loadingViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    self.loadingViewController = [[LoadingViewController alloc] init];
    [loadingViewController.loadingImageView setImage: [UIImage imageNamed:@"Loading"]];
    //[self.window addSubview:loadingViewController.loadingView];

    [loadingViewController.view addSubview:loadingViewController.rotateView];
    [self.window addSubview:loadingViewController.view];
    [self.window makeKeyAndVisible];
    
      // [self.window addSubview:loadingViewController.rotateView];
    [self initializeAppDelegateAndLaunch];
    
    return TRUE;    
}

- (void) initializeAppDelegateAndLaunch {
    
    
    
    self.swoopTabViewController = [[SwoopTabViewController alloc] init];
    
    
    MapViewController * galleryViewController = [[MapViewController alloc]init];
    galleryViewController.fullscreenTransitionDelegate = self.swoopTabViewController;
    galleryViewController.userDataOnly = YES;
    galleryViewController.launchInGalleryMode = YES;
    self.swoopTabViewController.topViewController = galleryViewController;
    
    
    CameraViewController * cameraViewController = [[CameraViewController alloc]init];
    cameraViewController.fullscreenTransitionDelegate = self.swoopTabViewController;
    self.swoopTabViewController.middleViewController = cameraViewController; 
    
    MapViewController * mapViewController = [[MapViewController alloc]init];
    mapViewController.fullscreenTransitionDelegate = self.swoopTabViewController;
    
    self.swoopTabViewController.bottomViewController = mapViewController;
    
  
   /* 
    [self.loadingViewController.view insertSubview:loadingViewController.rotateView belowSubview:loadingViewController.loadingView ];
    [self.window insertSubview:swoopTabViewController.view belowSubview:loadingViewController.rotateView];
    
    // [self.window insertSubview:loadingViewController.rotateView belowSubview:loadingViewController.loadingView]//;
*/
    [self.window makeKeyAndVisible];

    
//    [self performSelectorInBackground:@selector(initializeInBackground) withObject:nil];
//    return;
    
    [self initializeInBackground];
    

  
        
}

//Start couchBase in the background.  Calls to the datamodel will be asynchronous, allowing the database to
//start serving whenever it's ready.
- (void) initializeInBackground{
    
   // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    
    [[MapDataModel instance] updateSyncURL];
    
    //    [[MapDataModel instance] test];
    
    [MapDataModel instance];
    
    [RHLocation instance];

    
    

  //  [self.loadingViewController.loadingView removeFromSuperview];
    [self.window makeKeyAndVisible];

    
  //  [pool release];

}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
