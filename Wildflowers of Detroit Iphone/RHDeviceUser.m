//
//  DeviceOperator.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHDeviceUser.h"

@implementation RHDeviceUser


+ (NSString *) uniqueIdentifier {
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [NSString stringWithFormat:@"Iphone%@", [device uniqueIdentifier]];
    return uniqueIdentifier;
}
@end
