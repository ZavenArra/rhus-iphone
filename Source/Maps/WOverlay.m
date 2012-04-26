//
//  WOverlay.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WOverlay.h"

@implementation WOverlay

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self != nil) {
        
        
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coord1;
    coord1.latitude = 42.362;
    coord1.longitude = -82.935;
    
    return coord1;
}

- (MKMapRect)boundingMapRect
{
    
    MKMapPoint upperLeft = MKMapPointForCoordinate([self coordinate]);
    
    MKMapRect bounds = MKMapRectMake(upperLeft.x, upperLeft.y, 2000, 2000);
    return bounds;
}


@end
