//
//  MapDataModel.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHDataModel.h"
#import "RHSettings.h"
#import "RHDocument.h"
#import "RHDeviceUser.h"
#import "SharedInstanceMacro.h"

@implementation RHDataModel

+ (id)instance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}


@synthesize database;
@synthesize query;
@synthesize syncTimeoutTimer;
@synthesize project;


-  (id) initWithBlock:( void ( ^ )() ) didStartBlock {
    // Start the Couchbase Mobile server:
    [CouchbaseMobile class];  // prevents dead-stripping
    CouchEmbeddedServer* server;
    
    if(![RHSettings useRemoteServer]){
        server = [[CouchEmbeddedServer alloc] init];
    } else {
        server = [[CouchEmbeddedServer alloc] initWithURL: [NSURL URLWithString: [RHSettings couchRemoteServer]]];
        /*
         Set Admin Credential Somehow??
         server.couchbase.adminCredential = [NSURLCredential credentialWithUser:@"winterroot" password:@"dieis8835nd" persistence:NSURLCredentialPersistenceForSession];
         */
    }
    
#if INSTALL_CANNED_DATABASE
    NSString* dbPath = [[NSBundle mainBundle] pathForResource: [RHSettings databaseName] ofType: @"couch"];
    NSAssert(dbPath, @"Couldn't find "kDatabaseName".couch");
    [server installDefaultDatabase: dbPath];
#endif
    
    BOOL started = [server start: ^{  // ... this block runs later on when the server has started up:
        if (server.error) {
            [self showAlert: @"Couldn't start Couchbase." error: server.error fatal: YES];
            return;
        }
        
        self.database = [server databaseNamed: [RHSettings databaseName]];
        NSAssert(database, @"Database Is NULL!");
        
        
        if(![RHSettings useRemoteServer]){
            // Create the database on the first run of the app.
            NSError* error;
            if (![self.database ensureCreated: &error]) {
                [self showAlert: @"Couldn't create local database." error: error fatal: YES];
                return;
            }
            
        }
        
        database.tracksChanges = YES;

        //Compile views
        CouchDesignDocument* design = [database designDocumentWithName: @"rhusMobile"];
        NSAssert(design, @"Couldn't find design document");
        design.language = kCouchLanguageJavaScript;
        /*
         [design defineViewNamed: @"detailDocuments"
         map: @"function(doc) { emit([doc.created_at], [doc._id, doc.reporter, doc.comment, doc.medium, doc.created_at] );}"];
         */
                
        
        [design defineViewNamed: @"deviceUserGalleryDocuments"
                            map: @"function(doc) { emit([doc.deviceuser_identifier, doc.project, doc.created_at],{'id':doc._id, 'thumb':doc.thumb, 'latitude':doc.latitude, 'longitude':doc.longitude, 'reporter':doc.reporter, 'comment':doc.comment, 'created_at':doc.created_at} );}"];
        
        
        /*
        [design defineViewNamed: @"deviceUserGalleryDocuments"
                            map: @"function(doc) { emit([doc.deviceuser_identifier, doc.created_at],{'id':doc._id, 'latitude':doc.latitude, 'longitude':doc.longitude, 'reporter':doc.reporter, 'comment':doc.comment, 'created_at':doc.created_at} );}"];
        */
        
        /*  
        [design defineViewNamed: @"galleryDocuments"
                            map: @"function(doc) { emit(doc.created_at,{'id':doc._id, 'thumb':doc.thumb, 'medium':doc.medium, 'latitude':doc.latitude, 'longitude':doc.longitude, 'reporter':doc.reporter, 'comment':doc.comment, 'created_at':doc.created_at, 'deviceuser_identifier':doc.deviceuser_identifier } );}"];
        */
        [design defineViewNamed: @"rhusDocuments"
                            map: @"function(doc) { emit( [doc.project, doc.created_at],{'id':doc._id,'latitude':doc.latitude, 'longitude':doc.longitude, 'reporter':doc.reporter, 'comment':doc.comment, 'created_at':doc.created_at, 'deviceuser_identifier':doc.deviceuser_identifier } );}"];
        
        [design defineViewNamed: @"documentDetail"
                            map: @"function(doc) { emit( doc._id, {'id' :doc._id, 'reporter' : doc.reporter, 'comment' : doc.comment, 'thumb' : doc.thumb, 'medium' : doc.medium, 'created_at' : doc.created_at} );}"];
        
        [design defineViewNamed: @"projects"
                            map: @"function(doc) { if(doc.project) { emit(doc.project, null);}  }"
                         reduce: @"function(key, values) { return true;}"];
        
        [design saveChanges];
        /*
        design = [database designDocumentWithName: @"rhusMobile"];
        NSMutableDictionary * properties = [design.properties mutableCopy];
        [properties setObject: [NSDictionary dictionaryWithObjectsAndKeys: @"function(doc, req) { if(doc.id.indexOf(\"_design\") === 0) { return false; } else { return true; }}",@"excludeDesignDocs", nil]  forKey:@"filters"];
        RESTOperation * op = [design putProperties:properties];
        [op start];
        [op wait]; //synchronous
        */
         
        didStartBlock();
    }];
    NSLog(@"%@", @"Started...");
    NSAssert(started, @"didnt start");
    
    return self;
    
}


+ (NSData *) getDocumentThumbnailData: (NSString *) key {
    CouchDocument* doc = [[self.instance database] documentWithID: key];
    CouchModel * model = [[CouchModel alloc] initWithDocument:doc];
    CouchAttachment * thumbnail = [model attachmentNamed:@"thumb.jpg"];
    if(thumbnail != nil){
        return thumbnail.body;
    } else {
        return nil;
    }
}

+ (NSData *) getDocumentImageData: (NSString *) key {
    CouchDocument* doc = [[self.instance database] documentWithID: key];
    CouchModel * model = [[CouchModel alloc] initWithDocument:doc];
    CouchAttachment * thumbnail = [model attachmentNamed:@"medium.jpg"];
    if(thumbnail != nil){
        return thumbnail.body;
    } else {
        return nil;
    }
}


- (NSArray *) runQuery: (CouchQuery *) couchQuery {
//   RESTOperation * op = [couchQuery start];
//   [op wait]; //synchronous
//   NSLog(@"op = %@", op.dump);

    
    CouchQueryEnumerator * enumerator = [couchQuery rows];
    
    if(!enumerator){
        return [NSArray array];
    }
    NSLog(@"count = %i", [enumerator count]);
    
    CouchQueryRow * row;
    NSMutableArray * data = [NSMutableArray array];
    while( (row =[enumerator nextRow]) ){
        
        
        //Fix Image Attachments
        //TODO: This code can be removed once we are reasonably certain everything has been transformed
        //BOOL docNeedsSave = false;
     //   CouchDocument * doc = row.document;
      //  NSMutableDictionary * newProperties = [doc.properties mutableCopy ];
        
        
        /*
         if( ([row.value objectForKey:@"thumb"] == NULL) || ([row.value objectForKey:@"thumb"] == @"") ){
         NSString * docId = [row.value objectForKey:@"id"];
         NSData * imageData = [MapCouchbaseDataModel getDocumentThumbnailData:docId];
         if(imageData != nil){
         NSData * thumb = imageData;
         [newProperties setValue:[RESTBody base64WithData:thumb] forKey:@"thumb"];
         docNeedsSave = true;
         } else if([doc.properties objectForKey:@"thumb-android0.1"]){
         [newProperties setValue:[doc.properties objectForKey:@"thumb-android0.1"] forKey:@"thumb"];
         }
         }    
         
         
         if([row.value objectForKey:@"medium"] == NULL || [row.value objectForKey:@"medium"] == @""){
         NSData * imageData = [MapCouchbaseDataModel getDocumentImageData:[row.value objectForKey:@"id"]];
         if(imageData != nil){
         NSData * mediumImage = imageData;
         [newProperties setValue:[RESTBody base64WithData:mediumImage] forKey:@"medium"];
         docNeedsSave = true;
         } else if([doc.properties objectForKey:@"medium-android0.1"]){
         [newProperties setValue:[doc.properties objectForKey:@"medium-android0.1"] forKey:@"medium"];
         }
         }
         
         
         if(docNeedsSave){
         CouchRevision* latest = doc.currentRevision;
         //  NSLog(@"%@", [newProperties debugDescription]);
         NSLog(@"Fixing Document");
         NSLog(@"%@", [row.value objectForKey:@"id"] );
         RESTOperation* op = [latest putProperties:newProperties];
         [op start];
         [op wait]; //make it synchronous
         }
         */
        
        
        NSMutableDictionary * properties = [(NSDictionary *) row.value mutableCopy];
        //Translate the Base64 data into a UIImage
        if([properties objectForKey:@"thumb"] != NULL && [properties objectForKey:@"thumb"] != @"" ){
            NSString * base64 = [properties objectForKey:@"thumb"];
            //  NSLog(@"%@", [row.value objectForKey:@"id"] );
            NSData * thumb = [RESTBody dataWithBase64:base64];
            if(thumb != NULL && [thumb length]){
                [properties setObject:[UIImage imageWithData:thumb]
                                  forKey:@"thumb"];
            } else {
                [properties removeObjectForKey:@"thumb"];
            }
        } else {
            [properties removeObjectForKey:@"thumb"];
        }
        
        
        if([properties objectForKey:@"medium"] != NULL && [properties objectForKey:@"medium"] != @"" ){
            NSString * base64 = [properties objectForKey:@"medium"];
            //  NSLog(@"%@", [row.value objectForKey:@"id"] );
            NSData * medium = [RESTBody dataWithBase64:base64];
            if(medium != NULL && [medium length]){
                [properties setObject:[UIImage imageWithData:medium]
                                  forKey:@"medium"];
            } else {
                [properties removeObjectForKey:@"medium"];
                
            }
        } else {
            [properties removeObjectForKey:@"medium"];
        }
        
        
        //give em the data
        [data addObject: [[RHDocument alloc] initWithDictionary: [NSDictionary dictionaryWithDictionary: properties]]];
    }
    return data;
    
}


+ (NSArray *) getUserGalleryDocumentsWithStartKey: (NSString *) startKey 
                                         andLimit: (NSInteger) limit 
                                 andUserIdentifer: (NSString *) userIdentifier {
    
    //Create view;
    CouchDatabase * database = [self.instance database];
    CouchDesignDocument* design = [database designDocumentWithName: @"rhusMobile"];
    NSAssert(design, @"Couldn't find design document");
    
    CouchQuery * query = [design queryViewNamed: @"deviceUserGalleryDocuments"]; //asLiveQuery];
    
    query.descending = YES;
    query.endKey = [NSArray arrayWithObjects:userIdentifier, [[RHDataModel instance] project], nil];
    query.startKey = [NSArray arrayWithObjects:userIdentifier, [[RHDataModel instance] project], [NSDictionary dictionary], nil];
    
    NSArray * r = [(RHDataModel * ) self.instance runQuery:query];
    
    return r;
    
    
}

+ (NSArray *) getDeviceUserGalleryDocumentsWithStartKey: (NSString *) startKey andLimit: (NSInteger) limit {
    return [self getUserGalleryDocumentsWithStartKey: startKey 
                                            andLimit: limit 
                                    andUserIdentifer:  [RHDeviceUser uniqueIdentifier]];
}



+ (NSArray *) getAllDocuments {
    //TODO: Implement
}

+ (NSArray *) getDocumentsInProject: (NSString *) project {
    
    CouchDatabase * database = [self.instance database];
    CouchDesignDocument* design = [database designDocumentWithName: @"rhusMobile"];
    NSAssert(design, @"Couldn't find design document");
    
    CouchQuery * query = [design queryViewNamed: @"rhusDocuments"]; //asLiveQuery];
    query.descending = YES;
    query.endKey = [NSArray arrayWithObjects:project, nil];
    query.startKey = [NSArray arrayWithObjects:project, [NSDictionary dictionary], nil];    
    NSArray * r = [self.instance runQuery:query];
    NSLog(@"Count: %i", [r count]);
    
    return r;
}


+ (NSArray *) getDocumentsInProject: (NSString *) project since: (NSString*) date {
    //TODO: Implement
}


+ (NSArray *) getDetailDocumentsWithStartKey: (NSString *) startKey andLimit: (NSInteger) limit  {
    CouchDatabase * database = [self.instance database];
    
    CouchDesignDocument* design = [database designDocumentWithName: @"rhusMobile"];

    CouchQuery * query = [design queryViewNamed: @"detailDocuments"]; //asLiveQuery];
    query.descending = NO;
    NSArray * r = [(RHDataModel * ) self.instance runQuery: query];
    
    return r;
    
}

+ (NSDictionary *) getDetailDocument: (NSString *) documentId {
    CouchDesignDocument* design = [  [[self instance] database] designDocumentWithName: @"rhusMobile"];
    CouchQuery * query = [design queryViewNamed: @"documentDetail"]; //asLiveQuery];
    query.startKey = documentId;
    query.endKey = documentId;
    NSArray * r = [(RHDataModel * ) self.instance runQuery: query];
    if([r count] == 1){
        return [r objectAtIndex:0];
    } else {
        return nil;
    }
}


+ (NSArray *) getUserDocuments {
    return [self getGalleryDocumentsWithStartKey:nil andLimit:nil];
}

+ (NSArray *) getUserDocumentsWithOffset:(NSInteger)offset andLimit:(NSInteger)limit {
    NSLog(@"getUserDocumentsWithOffset just calling getUserDocuments");
    return [self.instance _getUserDocuments];
}


+ (void) addProject:(NSString *) projectName {    
    NSDictionary * document = [NSDictionary dictionaryWithObjectsAndKeys:projectName, @"project", nil];
    [RHDataModel addDocument:document];
}

- (NSArray *) _getProjects {
    CouchDesignDocument* design = [database designDocumentWithName: @"rhusMobile"];
    CouchQuery * couchQuery = [design queryViewNamed: @"projects"]; //asLiveQuery];
    couchQuery.groupLevel = 1;
    CouchQueryEnumerator * enumerator = [couchQuery rows];
    NSMutableArray * r = [NSMutableArray array];
    CouchQueryRow * row;
    while( (row =[enumerator nextRow]) ){
        [r addObject:row.key];
    }
    return r;
}

+ (NSArray *) getProjects {
    return [self.instance _getProjects];
}

+ (void) addDocument: (NSDictionary *) document {
    //Add any additional properties
    
    // Save the document, asynchronously:
    CouchDocument* doc = [self.instance.database untitledDocument];
    RESTOperation* op = [doc putProperties:document];
    [op onCompletion: ^{
        if (op.error)
            NSAssert(false, @"ERROR");
        // AppDelegate needs to observer MapData for connection errors.
        // [self showErrorAlert: @"Couldn't save the new item" forOperation: op];
        // Re-run the query:
		//[self.dataSource.query start];
        [self.instance.query start];
	}];
    [op start];
    [op wait]; //kickin it synchronous for right now.
    
}



// Display an error alert, without blocking.
// If 'fatal' is true, the app will quit when it's pressed.
- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal {
    if (error) {
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedDescription];
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: (fatal ? @"Fatal Error" : @"Error")
                                                    message: message
                                                   delegate: (fatal ? self : nil)
                                          cancelButtonTitle: (fatal ? @"Quit" : @"Sorry")
                                          otherButtonTitles: nil];
    [alert show];
}


-(void)syncTimeout {
    if(!syncStarted){
        NSLog(@"Sync Timeout");

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"No Sync"
                                                        message: @"Timed out while trying to sync, either there is nothing to sync or you aren't connected to the internet.  Make sure you are connected to the internet and try again!"
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [self forgetSync];
        if(syncCompletedBlock){
            syncCompletedBlock();
        }
        syncCompletedBlock = nil;
    }
}

- (void)updateSyncURL {
    [self updateSyncURLWithCompletedBlock: nil];
}


- (void)updateSyncURLWithCompletedBlock: ( CompletedBlock ) setCompletedBlock  {
    //Should check for reachability of data.winterroot.net
    //http://stackoverflow.com/questions/1083701/how-to-check-for-an-active-internet-connection-on-iphone-sdk
    //Test for network
    
    
    NSInteger count = [self.database getDocumentCount];
        
    if (!self.database){
        NSLog(@"No Database in updateSyncURL");
        return;
    }
    NSURL* newRemoteURL = nil;
    NSString *syncpoint = [RHSettings couchRemoteSyncURL];
    if (syncpoint.length > 0)
        newRemoteURL = [NSURL URLWithString:syncpoint];
    
    [self forgetSync];
    
    NSLog(@"Setting up replication %@", [newRemoteURL debugDescription]);
    NSArray* repls = [self.database replicateWithURL: newRemoteURL exclusively: YES];
    _pull = [repls objectAtIndex: 0];
    _push = [repls objectAtIndex: 1];
    //_pull.continuous = NO;  //we might want these not to be continuous for user initialized replications
    //_push.continuous = NO;
    // _pull.filter = @"design/excludeDesignDocs";
    // _push.filter = @"rhusMobile/excludeDesignDocs";
    
    [_pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [_push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    
    
    
    syncCompletedBlock = setCompletedBlock;
    
    //set a timeout to detect when there are in fact no changes
    //This is only relevant when sync is NOT continuous
   
    /*NSInvocation * invocation = [[NSInvocation alloc] init];
    [invocation setTarget:self];
    [invocation setSelector:@selector(syncTimeout)];
    syncStarted = FALSE;
    self.syncTimeoutTimer = [NSTimer timerWithTimeInterval:5.0 invocation:invocation repeats:NO];
     */
    
    syncStarted = FALSE;
    /*
    This causes erroneous sync failure message when there is nothing to sync using continuous.
    self.syncTimeoutTimer =  [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(syncTimeout) userInfo:nil repeats:NO];
     */
    
}



- (void) forgetSync {
    [_pull removeObserver: self forKeyPath: @"completed"];
    _pull = nil;
    
    [_push removeObserver: self forKeyPath: @"completed"];
    _push = nil;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == _pull || object == _push) {
        syncStarted = TRUE;
        
        unsigned completed = _pull.completed + _push.completed;
        unsigned total = _pull.total + _push.total;
        NSLog(@"SYNC progress: %u / %u", completed, total);
        if (total > 0 && completed < total) {
            // [self showSyncStatus];
            // [progress setProgress:(completed / (float)total)];
            database.server.activityPollInterval = 0.5;   // poll often while progress is showing
        } else {
            // [self showSyncButton];
            database.server.activityPollInterval = 2.0;   // poll less often at other times
            if(syncCompletedBlock != nil){
                syncCompletedBlock();
                syncCompletedBlock = nil;
            }
        }
    }
}


@end
