//
//  MapCouchbaseDataModel.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapCouchbaseDataModel.h"
#import "AppDelegate.h"
#import "RhusDocument.h"
#import "DeviceUser.h"
#import "RHSettings.h"


@implementation MapCouchbaseDataModel

@synthesize database;
@synthesize query;


//- (id) initWithBlock:( void ( ^ )() ) didStartBlock {
- (id) init {
    
    
    NSURL* serverURL = [NSURL URLWithString: @"http://data.winterroot.net:5984"];
    CouchServer *server = [[CouchServer alloc] initWithURL: serverURL];
    database = [server databaseNamed: [RHSettings databaseName]];
    database.tracksChanges = YES;
    
    //  NSLog(@"%@", @"Calling did start block");
    // didStartBlock();
    
    //Compile views
    CouchDesignDocument* design = [database designDocumentWithName: @"design"];
    NSAssert(design, @"Couldn't find design document");
    design.language = kCouchLanguageJavaScript;
    [design defineViewNamed: @"detailDocuments"
                        map: @"function(doc) { emit([doc._id, doc.created_at], [doc._id, doc.reporter, doc.comment, doc.medium, doc.created_at] );}"];
    
    [design defineViewNamed: @"deviceUserGalleryDocuments"
                        map: @"function(doc) { emit(doc.deviceuser_identifier,{'id':doc._id, 'thumb':doc.thumb, 'medium':doc.medium, 'latitude':doc.latitude, 'longitude':doc.longitude, 'reporter':doc.reporter, 'comment':doc.comment, 'created_at':doc.created_at} );}"];
    
    design.language = kCouchLanguageJavaScript;
    [design defineViewNamed: @"galleryDocuments"
                        map: @"function(doc) { emit([doc.created_at],{'id':doc._id, 'thumb':doc.thumb, 'medium':doc.medium, 'latitude':doc.latitude, 'longitude':doc.longitude, 'reporter':doc.reporter, 'comment':doc.comment, 'created_at':doc.created_at, 'deviceuser_identifier':doc.deviceuser_identifier } );}"];
    
    design.language = kCouchLanguageJavaScript;
    [design defineViewNamed: @"detailDocuments"
                        map: @"function(doc) { emit([doc._id, doc.created_at], [doc._id, doc.reporter, doc.comment, doc.medium, doc.created_at] );}"];
    [design saveChanges];
    
    //TODO: Reorganize to use a block
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] doneStartingUp];
    
    
    NSLog(@"%@", @"Started...");

    
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

/*
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
 /*   self.query = [design queryViewNamed: @"all"]; //asLiveQuery];
    query.descending = YES;
    [query start];
}
*/


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


- (NSArray *) runQuery: (CouchQuery *) query {
    RESTOperation * op = [query start];

    CouchQueryEnumerator * enumerator = [query rows];
    
    NSLog(@"op = %@", op.dump);
    if(!enumerator){
        return [NSArray array];
    }
    NSLog(@"count = %i", [enumerator count]);
  
    CouchQueryRow * row;
    NSMutableArray * data = [NSMutableArray array];
    while( (row =[enumerator nextRow]) ){
        [data addObject: [[RhusDocument alloc] initWithDictionary: (NSDictionary *) row.value]];
    }
    return data;
    
}
/*
 TODO: !!!!!!!!!  This code WILL NOT SCALE.  Saving of full vs. thumb images needs to be implemented
 according to our plan.  This is simply to get something running..
 */
    
+ (NSArray *) readAttachments: (NSArray *) r {
    
    for(int i=0; i<[r count]; i++){
        NSDictionary * d = [r objectAtIndex:i];
        //  UIImage * thumb = [UIImage imageNamed:@"thumbnail_IMG_0015.jpg"]; //TODO: remove spoof
        
        //getDocumentThumbnailData
        NSData * imageData = [self getDocumentThumbnailData:[d objectForKey:@"id"]];
        if(imageData != nil){
            UIImage * thumb = [UIImage imageWithData: imageData ];
            [d setValue:thumb forKey:@"thumb"];
        }
        // UIImage * mediumImage = [UIImage imageNamed:@"IMG_0068.jpg"]; //TODO: remove spoof
        imageData = [self getDocumentImageData:[d objectForKey:@"id"]];
        if(imageData != nil){
            UIImage * mediumImage = [UIImage imageWithData: imageData ];
            [d setValue:mediumImage forKey:@"medium"];
        }
    }
    return r;
}

+ (NSArray *) getUserGalleryDocumentsWithStartKey: (NSString *) startKey 
                                         andLimit: (NSInteger) limit 
                                         andUserIdentifer: (NSString *) userIdentifier {
    
    //Create view;
    CouchDatabase * database = [self.instance database];
    CouchDesignDocument* design = [database designDocumentWithName: @"design"];
    NSAssert(design, @"Couldn't find design document");
   // design.language = kCouchLanguageJavaScript;
/*    [design defineViewNamed: @"deviceUserGalleryDocuments"
                        map: @"function(doc) { emit([doc.deviceuser_identifier,  Date.parse(doc.created_at)],{'id':doc._id, 'thumb':doc.thumb, 'medium':doc.medium, 'latitude':doc.latitude, 'longitude':doc.longitude, 'reporter':doc.reporter, 'comment':doc.comment, 'created_at':doc.created_at} );}"];
  */ 
    NSLog(@"Running query without sorting");

    
    
    CouchQuery * query = [design queryViewNamed: @"deviceUserGalleryDocuments"]; //asLiveQuery];
    query.descending = NO;
  //  query.startKey = [NSMutableArray arrayWithObjects:userIdentifier, [NSNumber numberWithInt: 0], nil];
  //  query.endKey = [NSArray arrayWithObjects:userIdentifier, [NSNumber numberWithInt: 9999999999999999999], nil];
   // query.startKey =  @"\['YES', 0 \]";
   // query.endKey = @"\['NO', 99999999999999999999999999999 \]";
    
    query.startKey =  [NSString stringWithFormat: @"\['%@'\]", userIdentifier];
    query.endKey =  [NSString stringWithFormat: @"\['%@'\]", userIdentifier];
    
    query.startKey = userIdentifier;
    query.endKey = userIdentifier;

    //how to specify multi value key???  array key, with match all entries
    //query.keys = [NSArray arrayWithObject:[DeviceUser uniqueIdentifier]];
    NSArray * r = [(MapCouchbaseDataModel * ) self.instance runQuery:query];
    
    return [self readAttachments: r];
    

}

+ (NSArray *) getDeviceUserGalleryDocumentsWithStartKey: (NSString *) startKey andLimit: (NSInteger) limit {
    return [self getUserGalleryDocumentsWithStartKey: startKey 
                                            andLimit: limit 
                                    andUserIdentifer:  [DeviceUser uniqueIdentifier]];
    
}


         

+ (NSArray *) getGalleryDocumentsWithStartKey: (NSString *) startKey andLimit: (NSInteger) limit {
    
    //Create view;
    CouchDatabase * database = [self.instance database];
    CouchDesignDocument* design = [database designDocumentWithName: @"design"];
    NSAssert(design, @"Couldn't find design document");

  //  NSArray * r =  [ (MapCouchbaseDataModel * ) self.instance getView:@"galleryDocuments"];
 
    CouchQuery * query = [design queryViewNamed: @"galleryDocuments"]; //asLiveQuery];
    query.descending = NO;
    NSArray * r = [(MapCouchbaseDataModel * ) self.instance runQuery:query];
        
    return [self readAttachments: r];
}

+ (NSArray *) getDetailDocumentsWithStartKey: (NSString *) startKey andLimit: (NSInteger) limit  {
    CouchDatabase * database = [self.instance database];

    CouchDesignDocument* design = [database designDocumentWithName: @"design"];
    NSAssert(design, @"Couldn't find design document");

    [design saveChanges];
    
   // NSArray * r = [ (MapCouchbaseDataModel * ) self.instance getView:@"detailDocuments" ];
    
    CouchQuery * query = [design queryViewNamed: @"detailDocuments"]; //asLiveQuery];
    query.descending = NO;
    NSArray * r = [(MapCouchbaseDataModel * ) self.instance runQuery: query];
    
    for(int i=0; i<[r count]; i++){
        NSDictionary * d = [r objectAtIndex:i];
        UIImage * mediumImage = [UIImage imageNamed:@"IMG_0068.jpg"]; //TODO: remove spoof
        //getDocumentImageData
        [d setValue:mediumImage forKey:@"medium"];
    }
    return r;

}


- (NSArray *) getView: (NSString *) viewName {
    
    CouchDesignDocument* design = [database designDocumentWithName: @"design"];
    self.query = [design queryViewNamed: viewName]; //asLiveQuery];
    query.descending = YES;
    
    
    CouchQueryEnumerator * enumerator = [query rows];
    if(!enumerator){
        return [NSArray array];
    }
    CouchQueryRow * row;
    NSMutableArray * data = [NSMutableArray array];
    while( (row =[enumerator nextRow]) ){
        [data addObject: (NSDictionary *) row.value];
    }
    return data;

}


+ (NSArray *) getUserDocuments {
    return [self getGalleryDocumentsWithStartKey:nil andLimit:nil];
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

+ (void) addDocument: (NSDictionary *) document withAttachments: (NSDictionary *) attachments{
    
    // Save the document, asynchronously:
    CouchDocument* doc = [self.instance.database untitledDocument];
    CouchModel * documentModel = doc.modelObject;    

    RESTOperation* op = [doc putProperties:document];
    [op onCompletion: ^{
        NSLog(@"OnCompletion of the addDocument");
        if (op.error)
            NSAssert(false, @"ERROR");
        
//        CouchModel * documentModel = doc.modelObject;
        
        RESTBody * 	responseBody = op.responseBody;
        NSLog([op.responseBody asString]);
        
        NSDictionary * object = (NSDictionary *)responseBody.fromJSON;
        NSLog([object objectForKey:@"id"]);
        NSLog([object objectForKey:@"rev"]);
        
           
        for(NSDictionary * attachmentValues in attachments ){
            CouchDocument * doc = [self.instance.database documentWithID:[object objectForKey:@"id"]];
            CouchRevision * revision = doc.currentRevision;
            
            NSString * contentType = (NSString *) [attachmentValues objectForKey:@"contentType"];
            NSString * attachmentName = (NSString *) [attachmentValues objectForKey:@"name"];
            NSData * attachmentData = (NSData *) [attachmentValues objectForKey:@"data"];

            
            CouchAttachment * newAttachment = [revision createAttachmentWithName:attachmentName
                                               type:contentType ];
                                              
            RESTOperation * op2 = [newAttachment PUT:attachmentData contentType:contentType];
            [op2 start]; //run this synchronously
            [op2 wait];
        }
        
        
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

    
    if (!self.database){
        NSLog(@"No Database in updateSyncURL");
        return;
    }
    NSURL* newRemoteURL = nil;
    NSString *syncpoint = [RHSettings couchRemoteSyncURL];
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
