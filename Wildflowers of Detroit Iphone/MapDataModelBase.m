//
//  MapDataModelBase.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapDataModelBase.h"
#import "SharedInstanceMacro.h"


@implementation MapDataModelBase


+ (id)instance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

@end
