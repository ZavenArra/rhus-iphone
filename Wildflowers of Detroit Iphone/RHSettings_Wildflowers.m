//
//  RHSettings.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHSettings.h"

#define kSyncDbURL @"http://admin:Rfur55@data.winterroot.net:5984/iphonetest2"

#define fullLatitudeDelta .1
#define fullLongitudeDelta .1
#define kMapCenterOnLoadLatitude 42.3
#define kMapCenterOnLoadLongitude -83.1

@implementation RHSettings

+ (NSString *) couchRemoteSyncURL {
    return kSyncDbURL;
}

+ (NSString *) databaseName {
    return @"iphonetest2";
}


+ (BOOL) useRemoteServer{
    return false;
}

+ (NSString *) couchRemoteServer{
    return nil;
}


+ (BOOL) useCamera {
    return true;
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
