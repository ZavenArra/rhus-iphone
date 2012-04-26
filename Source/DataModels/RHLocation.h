//
//  RHLocation.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RHLocation : NSObject
<CLLocationManagerDelegate>

//Location Manager
@property (nonatomic, strong) 	CLLocation * currentLocation;

//TODO: this should be private
@property (nonatomic, strong) 	CLLocationManager * locationManager;


+ (id) instance;
+ (NSString *) getLatitudeString;
+ (NSString *) getLongitudeString;




@end
