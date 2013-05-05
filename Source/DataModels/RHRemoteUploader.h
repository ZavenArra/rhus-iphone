//
//  RHRemoteUploader.h
//  Rhus
//
//  Created by Rey Felipe on 5/3/13.
//
//

#import <Foundation/Foundation.h>
#import "MKNetworkEngine.h"
#import "RHDocument.h"

typedef void (^UploadFinishedBlock)(MKNetworkOperation* completedOperation);
typedef void (^UploadErrorBlock)(NSError* error);

@interface RHRemoteUploader : NSObject {
@private
    NSString* _hostName;
    NSNumber* _port;
    BOOL _useSSL;
    NSString* _username;
    NSString* _password;
    NSString* _dbname;
    MKNetworkEngine* _networkEngine;
    //DatabaseErrorBlock _globalErrorBlock;
    
    NSString *strDocID;
    NSString *strDocRev;
    NSMutableArray *arrAttachments;
    NSMutableDictionary *putParam;
    NSUInteger attachmentIdx;
    UploadFinishedBlock uploadDone;
    UploadErrorBlock uploadError;
}

@property (nonatomic, readonly) NSString* hostName;
@property (nonatomic, readonly) NSNumber* port;
@property (nonatomic, readonly) BOOL useSSL;
@property (nonatomic, readonly) NSString* username;
@property (nonatomic, readonly) NSString* password;
@property (nonatomic, readonly) NSString* dbname;
@property (nonatomic, readonly) MKNetworkEngine* networkEngine;
//@property (nonatomic, readonly) DatabaseErrorBlock globalErrorBlock;

@property (nonatomic, strong) RHDocument *document;


-(id)initWithHostName:(NSString*)hostName
                 port:(NSNumber*)port
               useSSL:(BOOL)useSSL
             username:(NSString*)username
             password:(NSString*)password
             database:(NSString*)dbname;

-(void)setDocument:(RHDocument *)doc;
-(void)uploadWithFinishedBlock:(UploadFinishedBlock)finishedBlock
                    errorBlock:(UploadErrorBlock)errorBlock;

@end
