//
//  RHSettings_Squirrels.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHSettings.h"

#define fullLatitudeDelta 50
#define fullLongitudeDelta 50
#define kMapCenterOnLoadLatitude 42.3
#define kMapCenterOnLoadLongitude -83.1

@implementation RHSettings

+ (BOOL) useRemoteServer {
    return false;
//    return false;
}

+ (NSString *) couchRemoteServer {
   return @"http://winterroot:dieis8835nd@data.winterroot.net:5984";
  // return @"http://data.winterroot.net:5984";

}

+ (NSString *) couchRemoteSyncURL {
    return @"http://winterroot:dieis8835nd@data.winterroot.net:5984/rhus_development_remote";
}

+ (NSString *) databaseName {
    return @"rhusdevelopment";
}

+ (BOOL) useCamera {
    return false;
}


//Map
+ (float) mapCenterLatitudeOnLoad{
    return kMapCenterOnLoadLatitude;
}

+ (float) mapCenterLongitudeOnLoad{
    return kMapCenterOnLoadLongitude;
}

+ (float) mapDeltaLatitudeOnLoad{
    return fullLatitudeDelta;
}

+ (float) mapDeltaLongitudeOnLoad{
    return fullLongitudeDelta;
}


@end
