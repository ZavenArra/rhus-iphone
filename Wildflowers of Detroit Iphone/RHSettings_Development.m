//
//  RHSettings_Squirrels.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHSettings.h"



@implementation RHSettings

+ (BOOL) useRemoteServer {
    return true;
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
    return @"rhus_development_remote";
}



@end
