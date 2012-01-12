//
//  Wildflowers_of_Detroit_IphoneTests.m
//  Wildflowers of Detroit IphoneTests
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Wildflowers_of_Detroit_IphoneTests.h"
#import "MapDataModel.h"

@implementation Wildflowers_of_Detroit_IphoneTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDataModelSingleton
{
    MapDataModel * dataModel = [MapDataModel instance];
    GHAssertTrue(dataModel != nil, @"Data model instance is nil");
}

- (void)testDataModelGetUserDocuments
{
    NSArray * userDocuments = [MapDataModel getUserDocuments];
    GHAssertTrue(userDocuments != nil, @"User documents array is nil");
    GHAssertTrue([userDocuments count] != 0, @"User documents array is empty");

}

- (void)testDataModelGetUserDocumentsLimited
{
    NSArray * userDocuments = [MapDataModel getUserDocumentsWithOffset:10 andLimit:10];
    GHAssertTrue(userDocuments != nil, @"User documents array is nil");
    GHAssertTrue([userDocuments count] == 10, @"User documents array does not contain correct number of documents");
    
}

- (void)testDataModelGetDocumentById
{
    NSDictionary * document = [MapDataModel getDocumentById:@"445"];
    GHAssertTrue(document != nil, @"Document is nil");
    
}

- (void)testDataModelGetNextDocument
{
    NSDictionary * document = [MapDataModel getNextDocument:@"472"];
    GHAssertTrue(document != nil, @"Next Document is nil");
    
}

- (void)testDataModelGetPrevDocument
{
    NSDictionary * document = [MapDataModel getPrevDocument:@"472"];
    GHAssertTrue(document != nil, @"Prev Document is nil");
    
}

- (void)testDataModelGetImageForId
{
    UIImage * image = [MapDataModel getImageForId:@"472"];
    GHAssertTrue(image != nil, @"Image is nil");
}

- (void)testDataModelGetThumbnailForId
{
    UIImage * thumbnail = [MapDataModel getThumbnailForId:@"472"];
    GHAssertTrue(thumbnail != nil, @"Thumbnail is nil");
}
@end
