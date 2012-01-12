//
//  MapDataModel.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapDataModel.h"
#import "SharedInstanceMacro.h"

@implementation MapDataModel

@synthesize userDocuments;
@synthesize thumbnailCache, imageCache;

+ (MapDataModel *)instance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

+ (NSArray *) getUserDocuments {
    return [[self instance].userDocuments allValues];
}

+ (NSArray *) getUserDocumentsWithOffset: (NSInteger) offset andLimit: (NSInteger) limit {
    
    OrderedDictionary * subset = [[self instance].userDocuments subsetWithOffset:offset andLimit:limit]; 
    return [subset allValues];
    
}

+ (NSDictionary *) getDocumentById: (NSString *) documentId{
    return [[self instance].userDocuments objectForKey:documentId];
}

+ (NSDictionary *) getNextDocument: (NSString *) documentId{
    NSDictionary * currObject = [self getDocumentById:documentId];
    NSInteger indexOfObject = [[self instance].userDocuments indexOfObject:currObject];
    id key = [[self instance].userDocuments keyAtIndex:indexOfObject+1];
    return [[self instance].userDocuments objectForKey:key];
}

+ (NSDictionary *) getPrevDocument: (NSString *) documentId{
    NSDictionary * currObject = [self getDocumentById:documentId];
    NSInteger indexOfObject = [[self instance].userDocuments indexOfObject:currObject];
    id key = [[self instance].userDocuments keyAtIndex:indexOfObject-1];
    return [[self instance].userDocuments objectForKey:key];
}

+ (UIImage *) getThumbnailForId: (NSString *) documentId {
    UIImage * cachedImage = [[self instance].thumbnailCache objectForKey:documentId];
    if(cachedImage != nil){
        //TODO: update image cache access stack
        return cachedImage;
    } else {
        NSDictionary * document = [self getDocumentById:documentId];
        
        NSString * thumbnailName = [NSString stringWithFormat:@"thumbnail_%@", [document objectForKey:@"plantImage"] ];
        UIImage * image = [UIImage imageNamed:thumbnailName];
        [[self instance].thumbnailCache setObject:image forKey:documentId];
        //TODO: update image cache access stack
        return image;
    }
}

+ (UIImage *) getImageForId: (NSString *) documentId {    
    UIImage * cachedImage = [[self instance].imageCache objectForKey:documentId];
    if(cachedImage != nil){
        //TODO: update image cache access stack
        return cachedImage;
    } else {
        NSDictionary * document = [self getDocumentById:documentId];

        NSString * imageName = [document objectForKey:@"plantImage"];
        UIImage * image = [UIImage imageNamed:imageName];
        [[self instance].imageCache setObject:image forKey:documentId];
        //TODO: update image cache access stack
        return image;
    }
    
}



- (id) init {
    NSString * fullPath = [[NSBundle mainBundle] pathForResource:@"testdataplist" ofType:@"plist"];
    NSDictionary * plist;
    plist = [NSDictionary dictionaryWithContentsOfFile:fullPath];
    self.userDocuments = [OrderedDictionary dictionaryWithDictionary:[plist objectForKey:@"Documents"]];
    return self;
}


@end
