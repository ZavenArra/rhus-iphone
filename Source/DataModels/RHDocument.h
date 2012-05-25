//
//  Document.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHDocument : NSMutableDictionary {
    
    NSMutableDictionary * dictionary;
}

- (NSString *) getComment;
- (NSString *) getReporter;
- (NSString *) getLocationString;
- (NSString *) getDateString;
- (float) getLatitude;
- (float) getLongitude;
- (UIImage *) getThumbnail;
- (UIImage *) getImage;


@end
