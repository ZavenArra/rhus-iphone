//
//  RHRemoteUploader.m
//  Rhus
//
//  Created by Rey Felipe on 5/3/13.
//
//

#import "RHRemoteUploader.h"

@implementation RHRemoteUploader

@synthesize document;

-(id)initWithHostName:(NSString*)hostName port:(NSNumber*)port useSSL:(BOOL)useSSL username:(NSString*)username password:(NSString*)password database:(NSString*)dbname {
    self = [super init];
    if (self) {
        _hostName = hostName;
        _port = port;
        _useSSL = useSSL;
        _username = username;
        _password = password;
        _dbname = dbname;
        
        //_globalErrorBlock = nil;
        _networkEngine = [[MKNetworkEngine alloc] initWithHostName:hostName];
        _networkEngine.portNumber = (port != nil)?[port intValue]:0;
        attachmentIdx = 0;
    }
    return self;
}

-(void)setDocument:(RHDocument *)doc {
    result = [NSMutableDictionary dictionary];
    document = doc;
    attachmentIdx = 0;
    // get the necessary information
    // id/rev/attachments
    //NSLog(@"documents = %@",document);
    
    //get attachment names
    NSDictionary *attachments = [document objectForKey:@"_attachments"];
    arrAttachments = [NSMutableArray array];
    if ([attachments count]>0)
    {
        // get the list image name
        NSArray *attachmentName = [attachments allKeys];
        for (NSString *name in attachmentName)
        {
            //NSString *strExt = @".jpg";
            NSRange range = [name rangeOfString:@"." options:NSBackwardsSearch];
            // remove extension is any
            NSString *cleanName = [name substringToIndex:range.location];
            [arrAttachments addObject:cleanName];
        }
    }
    
    // get the ID/Rev and initialize the PUT parameters
    NSArray *keys = [document allKeys];
    strDocID = @"";
    putParam = [NSMutableDictionary dictionary];
    for (NSString *key in keys)
    {
        
        if ([key isEqualToString:@"_id"])
        {
            strDocID = [document objectForKey:key];
            continue;
        }
        else if ([key isEqualToString:@"_attachments"])
            continue;
        else if ([key isEqualToString:@"_rev"])
        {
            strDocRev = [document objectForKey:key];
            continue;
        }
        BOOL bContinue = NO;
        for (NSString *name in arrAttachments)
        {
            if ([key isEqualToString:name])
            {
                bContinue = YES;
                break;
            }
        }
        if (bContinue)
            continue;
        [putParam setObject:[doc objectForKey:key] forKey:key];
    }
}

-(void)uploadWithFinishedBlock:(UploadFinishedBlock)finishedBlock
                    errorBlock:(UploadErrorBlock)errorBlock
{
    uploadDone = finishedBlock;
    uploadError = errorBlock;
    NSString *strPath = [NSString stringWithFormat:@"%@/%@",_dbname,strDocID];
    MKNetworkOperation *op = [_networkEngine operationWithPath:strPath
                                                        params:putParam
                                                    httpMethod:@"PUT"
                                                           ssl:_useSSL];
    
    if (self.username != nil && self.password != nil) {
        [op setUsername:self.username password:self.password basicAuth:YES];
    }
    [op setUsername:_username password:_password basicAuth:YES];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"%@", [operation responseString]);
        // NSString *strResponse = [operation responseString];
        NSError* error;
        NSDictionary* response = [NSJSONSerialization
                                  JSONObjectWithData:[operation responseData] //1
                                  
                                  options:kNilOptions
                                  error:&error];
        
        NSLog(@"response = %@",response);
        NSString *strRev = [response objectForKey:@"rev"];
        NSLog(@"rev = %@",strRev);
        strDocRev = strRev;
        
        // save the successful doc upload rev string
        [result setValue:strDocID forKey:@"_id"];
        
        if ([self hasAttachments])
        {
            [self uploadAttachments];
        }
        else
        {
            //save the lastest revision
            [result setValue:strDocRev forKey:@"_rev"];
            [result setValue:@"success" forKey:@"operation"];
            if (uploadDone) {
                uploadDone(result);
            }
        }
        
    } errorHandler:^(MKNetworkOperation *operation,NSError *error) {
        [result setValue:@"error" forKey:@"operation"];
        [self handleError:error withOperation:operation];
    }];
    [_networkEngine enqueueOperation:op];
}

//Upload attachments
- (void) uploadAttachments
{
    if (attachmentIdx+1 <= [arrAttachments count])
    {
        NSString *name = [arrAttachments objectAtIndex:attachmentIdx];
        [self attachFileToDoc:name revision:strDocRev];
        attachmentIdx++;
    }
}

- (BOOL)hasAttachments
{
    return ([arrAttachments count]>0)?YES:NO;
}

- (BOOL)hasMoreAttachments
{
    if (attachmentIdx<[arrAttachments count])
        return YES;
    return NO;
}

- (void)handleError:(NSError *)error withOperation:(MKNetworkOperation *)operation
{
    NSLog(@"ERROR = %@", error);
    NSLog(@"responseString = %@", [operation responseString]);
    NSLog(@"responseData = %@", [operation responseData]);
    
    if ([operation responseData]==nil)
    {
        if (uploadError)
        {
            uploadError(result,error);
        }
        return;
    }
    
    NSError* err;
    NSDictionary* jsonError = [NSJSONSerialization
                               JSONObjectWithData:[operation responseData] //1
                               
                               options:kNilOptions
                               error:&err];
    if (err!=nil)
    {   //Error in NSJSONSerialization
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:[operation responseString] forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"rhus.RHRemoteUploader" code:100 userInfo:errorDetail];
    }
    else
    {   //NOTE: add extra error codes here
        NSInteger errorCode = -1; // unknown
        if ([[jsonError objectForKey:@"error"] isEqualToString:@"conflict"])
            errorCode = 101; //Conflict
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:[jsonError objectForKey:@"reason"] forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"rhus.RHRemoteUploader"
                                    code:errorCode
                                userInfo:errorDetail];
    }
    if (uploadError)
    {
        uploadError(result,error);
    }
}

- (void)attachFileToDoc:(NSString *)name revision:(NSString *)strRev {
    NSLog(@"rev = %@",strRev);
    NSData *docData = [NSData dataFromBase64String:[self.document objectForKey:name]];
    NSLog(@"imgData length = %d",[docData length]);
    
    NSString *strPath = [NSString stringWithFormat:@"%@/%@/%@.jpg?rev=%@",self.dbname,strDocID,name,strRev];
    
    MKNetworkOperation *op = [_networkEngine operationWithPath:strPath
                                                        params:nil
                                                    httpMethod:@"PUT"
                                                           ssl:self.useSSL];
    [op addRawData:docData];
    if (self.username != nil && self.password != nil) {
        [op setUsername:self.username password:self.password basicAuth:YES];
    }
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"%@", [operation responseString]);
        // NSString *strResponse = [operation responseString];
        NSError* error;
        NSDictionary* response = [NSJSONSerialization
                                  JSONObjectWithData:[operation responseData] //1
                                  
                                  options:kNilOptions
                                  error:&error];
        
        //NSLog(@"jsonArray count = %d",[jsonArray count]);
        NSLog(@"response = %@",response);
        NSString *strRev = [response objectForKey:@"rev"];
        NSLog(@"rev = %@",strRev);
        strDocRev = strRev; //update the strDocRev (current)
        
        // save the successful attachment upload rev string
        [result setValue:strRev forKey:name];
        
        if ([self hasMoreAttachments])
            [self uploadAttachments];
        else
        {
            //save the lastest revision
            [result setValue:strRev forKey:@"rev"];
            [result setValue:@"success" forKey:@"operation"];
            if (uploadDone) {
                uploadDone(result);
            }
        }
            
        
    } errorHandler:^(MKNetworkOperation *operation,NSError *error) {
        [result setValue:name forKey:@"_attachment_error"]; // name of the which gave an error.
        [result setValue:strDocRev forKey:@"_rev"]; // last revision number
        [result setValue:@"error" forKey:@"operation"];
        [self handleError:error withOperation:operation];
    }];
    [self.networkEngine enqueueOperation:op];
}


@end
