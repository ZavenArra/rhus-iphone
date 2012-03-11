//
//  RHSettings_Squirrels.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHSettings.h"

#define kSyncDbURL @"http://admin:Rfur55@data.winterroot.net:5984/squirrels_of_the_earth"


@implementation RHSettings

+ (NSString *) couchRemoteSyncURL {
    return kSyncDbURL;
}

+ (NSString *) databaseName {
    return @"squirrels";
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

@end
