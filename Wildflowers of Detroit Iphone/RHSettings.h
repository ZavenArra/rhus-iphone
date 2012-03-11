//
//  RHSettings.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHSettings : NSObject

//Sync Server
+ (NSString *) couchRemoteSyncURL;

//Database for App
+ (NSString *) databaseName;
+ (BOOL) useRemoteServer;
+ (NSString *) couchRemoteServer;

@end

//Base implementation
/*
@implementation RHSettings
+ (BOOL) useRemoteServer{
    return false;
}

+ (NSString *) couchRemoteServer{
    return nil;
}

@end
 */