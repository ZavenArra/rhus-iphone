//
//  WOverlay.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WOverlay : NSObject <MKOverlay>{

}
- (MKMapRect)boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
