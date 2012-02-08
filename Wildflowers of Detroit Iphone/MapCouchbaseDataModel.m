//
//  MapCouchbaseDataModel.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapCouchbaseDataModel.h"
#import "AppDelegate.h"


// The name of the database the app will use.
#define kDatabaseName @"default"

// The default remote database URL to sync with, if the user hasn't set a different one as a pref.
//#define kDefaultSyncDbURL @"http://couchbase.iriscouch.com/grocery-sync"
//#define kDefaultSyncDbURL @"http://50.112.114.185:8091/couchBase/default"
#define kDefaultSyncDbURL @"http://admin:Rfur55@50.112.114.185:5984/items"

// Set this to 1 to install a pre-built database from a ".couch" resource file on first run.
#define INSTALL_CANNED_DATABASE 0

// Define this to use a server at a specific URL, instead of the embedded Couchbase Mobile.
// This can be useful for debugging, since you can use the admin console (futon) to inspect
// or modify the database contents.
//#define USE_REMOTE_SERVER @"http://50.112.114.185:8091"
//#define USE_REMOTE_SERVER @"http://couchbase.iriscouch.com"


@implementation MapCouchbaseDataModel

@synthesize database;
@synthesize query;


- (id) init {
#ifdef kDefaultSyncDbURL
    // Register the default value of the pref for the remote database URL to sync with:
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appdefaults = [NSDictionary dictionaryWithObject:kDefaultSyncDbURL
                                                            forKey:@"syncpoint"];
    [defaults registerDefaults:appdefaults];
    [defaults synchronize];
#endif
    
    // Start the Couchbase Mobile server:
    // gCouchLogLevel = 1;
    [CouchbaseMobile class];  // prevents dead-stripping
    CouchEmbeddedServer* server;
#ifdef USE_REMOTE_SERVER
    server = [[CouchEmbeddedServer alloc] initWithURL: [NSURL URLWithString: USE_REMOTE_SERVER]];
#else
    server = [[CouchEmbeddedServer alloc] init];
#endif
    
#if INSTALL_CANNED_DATABASE
    NSString* dbPath = [[NSBundle mainBundle] pathForResource: kDatabaseName ofType: @"couch"];
    NSAssert(dbPath, @"Couldn't find "kDatabaseName".couch");
    [server installDefaultDatabase: dbPath];
#endif
    
    BOOL started = [server start: ^{  // ... this block runs later on when the server has started up:
        if (server.error) {
            [self showAlert: @"Couldn't start Couchbase." error: server.error fatal: YES];
            return;
        }
        
       // NSError ** outError; 
       // NSString * version = [server getVersion: outError];
      //  NSArray * databases = [server getDatabases];
        self.database = [server databaseNamed: kDatabaseName];
        NSAssert(database, @"Database Is NULL!");
        
#if !INSTALL_CANNED_DATABASE && !defined(USE_REMOTE_SERVER)
        // Create the database on the first run of the app.
        NSError* error;
        if (![self.database ensureCreated: &error]) {
            [self showAlert: @"Couldn't create local database." error: error fatal: YES];
            return;
        }
#endif
        
        database.tracksChanges = YES;
        
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] initializeAppDelegateAndLaunch];
        
    }];
    NSAssert(started, @"didnt start");
    
    return self;
    
}

-(void) test {
    // Create the new document's properties:
    NSString * text = @"Some Text";
    NSDictionary *inDocument = [NSDictionary dictionaryWithObjectsAndKeys:text, @"text",
                                [NSNumber numberWithBool:NO], @"check",
                                [RESTBody JSONObjectWithDate: [NSDate date]], @"created_at",
                                nil];
    
    // Save the document, asynchronously:
    CouchDocument* doc = [database untitledDocument];
    NSString * docId = doc.documentID;
    RESTOperation* op = [doc putProperties:inDocument];
    [op onCompletion: ^{
        if (op.error)
            NSAssert(false, @"ERROR");
           // [self showErrorAlert: @"Couldn't save the new item" forOperation: op];
        // Re-run the query:
        //[self.dataSource.query start];
        [self initializeQuery];
    }];
    [op start];
}

- (void) initializeQuery{
    NSInteger count = [self.database getDocumentCount];

    
    // Create a CouchDB 'view' containing list items sorted by date,
    // and a validation function requiring parseable dates:
    CouchDesignDocument* design = [database designDocumentWithName: @"design"];
    NSAssert(design, @"Couldn't find design document");
    design.language = kCouchLanguageJavaScript;
    
    [design defineViewNamed: @"all"
                        map: @"function(doc) { emit(doc._id, doc);}"];

    /*
    [design defineViewNamed: @"bData"
                        map: @"function(doc) {if (doc.created_at) emit(doc.created_at, doc);}"];
     */
    
    /*
     design.validation = @"function(doc) {if (doc.created_at && !(Date.parse(doc.created_at) > 0))"
    "throw({forbidden:'Invalid date'});}";
    */
    
    // Create a query sorted by descending date, i.e. newest items first:
   // self.query = [[design queryViewNamed: @"all"] asLiveQuery];
    //CouchLiveQuery* query = [[design queryViewNamed: @"byDate"] //asLiveQuery];
    self.query = [design queryViewNamed: @"all"]; //asLiveQuery];
    query.descending = YES;
    [query start];
}


- (NSArray *) _getUserDocuments {
    CouchQueryEnumerator * enumerator = [query rows];
 //   NSAssert(enumerator, @"Enumerator False");
    CouchQueryRow * row;
    NSMutableArray * data = [NSMutableArray array];
    while( (row =[enumerator nextRow]) ){
        [data addObject: (NSDictionary *) row.value];
    }
    return data;
}

+ (NSArray *) getUserDocuments {
    return [self.instance _getUserDocuments];
}

+ (NSArray *) getUserDocumentsWithOffset:(NSInteger)offset andLimit:(NSInteger)limit {
    NSLog(@"getUserDocumentsWithOffset just calling getUserDocuments");
    return [self.instance _getUserDocuments];
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


- (void)updateSyncURL {
    
    NSInteger count = [self.database getDocumentCount];

    
    if (!self.database)
        return;
    NSURL* newRemoteURL = nil;
    NSString *syncpoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"syncpoint"];
    if (syncpoint.length > 0)
        newRemoteURL = [NSURL URLWithString:syncpoint];
    
    [self forgetSync];
    
    NSArray* repls = [self.database replicateWithURL: newRemoteURL exclusively: YES];
    _pull = [repls objectAtIndex: 0];
    _push = [repls objectAtIndex: 1];
    [_pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [_push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
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
        }
    }
}

@end
