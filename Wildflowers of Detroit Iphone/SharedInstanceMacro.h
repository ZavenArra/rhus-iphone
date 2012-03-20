//
//  SharedInstanceMacro.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Wildflowers_of_Detroit_Iphone_SharedInstanceMacro_h
#define Wildflowers_of_Detroit_Iphone_SharedInstanceMacro_h

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__retain static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

#endif
