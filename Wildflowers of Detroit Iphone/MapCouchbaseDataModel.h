//
//  MapCouchbaseDataModel.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapDataModelBase.h"

#import <Couchbase/CouchbaseMobile.h>
#import <CouchCocoa/CouchCocoa.h>

@class CouchDatabase;

@interface MapCouchbaseDataModel : MapDataModelBase {
    
    CouchPersistentReplication* _pull;
    CouchPersistentReplication* _push;
    
}


@property (nonatomic, strong) CouchDatabase *database;
@property (nonatomic, strong) CouchLiveQuery* query;


+ (MapCouchbaseDataModel *)instance;

+ (void) initializeServer;


- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal;
- (NSArray *) _getUserDocuments;

- (void) initializeQuery;
- (NSArray *) _getUserDocuments;

-(void) test;

- (void)updateSyncURL;
- (void)forgetSync;
@end
