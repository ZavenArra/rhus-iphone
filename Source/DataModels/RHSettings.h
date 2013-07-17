//
//  RHSettings.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHSettings : NSObject

//Database for App

+ (NSString *) databaseName;
+ (NSString *) databaseUser;
+ (NSString *) databasePassword;
+ (NSString *) databaseHost;

//Map Settings
+ (float) mapCenterLatitudeOnLoad;
+ (float) mapCenterLongitudeOnLoad;
+ (float) mapDeltaLatitudeOnLoad;
+ (float) mapDeltaLongitudeOnLoad;

+ (BOOL) useRemoteServer;
+ (NSString *) couchRemoteServer;

//Other Settings
+ (BOOL) allowNewProjectCreation;

//Development

+ (BOOL) useCamera;

@end
