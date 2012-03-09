//
//  MapDataModelBase.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapDataModelBase : NSObject
{
}

+ (id) instance;
+ (NSArray *) getUserDocuments;
+ (NSArray *) getUserDocumentsWithOffset: (NSInteger) offset andLimit: (NSInteger) limit;
+ (NSDictionary *) getDocumentById: (NSString *) documentId;
+ (NSDictionary *) getDocumentAtIndex: (NSUInteger) index;
+ (NSDictionary *) getNextDocument: (NSString *) documentId;
+ (NSDictionary *) getPrevDocument: (NSString *) documentId;

+ (UIImage *) getThumbnailForId: (NSString *) documentId;
+ (UIImage *) getImageForId: (NSString *) documentId;

+ (void) addDocument: (NSDictionary *) document;
+ (void) addDocument: (NSDictionary *) document withAttachments: (NSDictionary *) attachments;


+ (NSData *) getDocumentThumbnailData: (NSString *) key;



- (id) init;

@end
