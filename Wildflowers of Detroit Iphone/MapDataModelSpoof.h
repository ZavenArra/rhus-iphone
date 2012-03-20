//
//  MapDataModel.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"
#import "MapDataModelBase.h"


@interface MapDataModelSpoof: MapDataModelBase
{
    OrderedDictionary * userDocuments;
}
@property(nonatomic, retain) OrderedDictionary * userDocuments;


+ (MapDataModelSpoof *) instance;

@end
