//
//  MapDataModel.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//Uncomment this line to use data spoofing
//#define UseMapDataModelSpoof

#ifdef UseMapDataModelSpoof

#import "MapDataModelSpoof.h"
@interface MapDataModel : MapDataModelSpoof

#else

#import "MapCouchbaseDataModel.h"
@interface MapDataModel : MapCouchbaseDataModel

#endif

@end
