//
//  MapDataModel.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"

@interface MapDataModel : NSObject
{
    OrderedDictionary * userDocuments;
    NSMutableDictionary * thumbnailCache;
    NSMutableDictionary * imageCache;
}
@property(nonatomic, strong) OrderedDictionary * userDocuments;
@property(nonatomic, strong) NSMutableDictionary * thumbnailCache;
@property(nonatomic, strong) NSMutableDictionary * imageCache;

+ (MapDataModel *)instance;
+ (NSArray *) getUserDocuments;
+ (NSArray *) getUserDocumentsWithOffset: (NSInteger) offset andLimit: (NSInteger) limit;
+ (NSDictionary *) getDocumentById: (NSString *) documentId;
+ (NSDictionary *) getNextDocument: (NSString *) documentId;
+ (NSDictionary *) getPrevDocument: (NSString *) documentId;

+ (UIImage *) getThumbnailForId: (NSString *) documentId;
+ (UIImage *) getImageForId: (NSString *) documentId;



- (id) init;
@end
