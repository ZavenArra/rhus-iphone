//
//  MapDataModel.h
//  Rhus Iphone
//
//  Created by Deep Winter on 2/1/12.
//


#import <Foundation/Foundation.h>
#import "RHDataModel.h"

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>

typedef void ( ^CompletedBlock )();

@interface RHDataModel : NSObject {
    
    CouchPersistentReplication* _pull;
    CouchPersistentReplication* _push;
    CompletedBlock syncCompletedBlock;
    BOOL syncStarted;
    NSTimer * syncTimeoutTimer;
    NSString * project;
}

@property (nonatomic, strong) CouchDatabase *database;
@property (nonatomic, strong) CouchLiveQuery* query;
@property (nonatomic, strong) NSTimer * syncTimeoutTimer;
@property (nonatomic, strong) NSString * project;

- (id) initWithBlock: ( void ( ^ )() ) didStartBlock ;


- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal;
- (NSArray *) _getUserDocuments;

- (void) initializeQuery;
- (NSArray *) _getUserDocuments;

-(void) test;

- (void)updateSyncURL;
- (void)updateSyncURLWithCompletedBlock: ( CompletedBlock ) setCompletedBlock;
- (void)forgetSync;
- (NSArray *) getView: (NSString *) viewName;

+ (void) initializeServer;


+ (RHDataModel *) instance;
+ (NSArray *) getUserDocuments;
+ (NSArray *) getUserDocumentsWithOffset: (NSInteger) offset andLimit: (NSInteger) limit;
+ (NSDictionary *) getDocumentById: (NSString *) documentId;
+ (NSDictionary *) getDocumentAtIndex: (NSUInteger) index;
+ (NSDictionary *) getNextDocument: (NSString *) documentId;
+ (NSDictionary *) getPrevDocument: (NSString *) documentId;
+ (NSDictionary *) getDetailDocument: (NSString *) documentId;
+ (NSArray *) getDocuments;
+ (NSArray *) getAllDocuments;
+ (NSArray *) getAllDocumentsNotUploaded;
+ (NSArray *) getDocumentsInProject: (NSString *) project;
+ (NSArray *) getDocumentsInProject: (NSString *) project since: (NSString*) date;
+ (NSArray *) getProjects;
+ (void) addProject:(NSString *) projectName;


+ (UIImage *) getDocumentThumbnail: (NSString *) documentId;
+ (UIImage *) getDocumentImage: (NSString *) documentId;

+ (BOOL) updateDocument:(NSDictionary*)document;

+ (NSString *) addDocument: (NSDictionary *) document;
+ (NSString *) addDocument: (NSDictionary *) document withAttachments: (NSDictionary *) attachments;
+ (void) addAttachment:(NSString *) name toDocument: (NSString *) documentId withData: (NSData *) data andContentType: (NSString *) contentType;


+ (NSArray *) getDetailDocumentsWithStartKey: (NSString *) startKey andLimit: (NSInteger) limit;
+ (NSArray *) getGalleryDocumentsWithStartKey: (NSString *) startKey andLimit: (NSInteger) limit;
+ (NSArray *) getDeviceUserGalleryDocumentsWithStartKey: (NSString *) startKey andLimit: (NSInteger) limit;



- (id) init;
@end
