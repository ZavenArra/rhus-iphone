//
//  RHLocation.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHLocation.h"
#import "SharedInstanceMacro.h"

static RHLocation * sharedRHLocation = NULL;

@implementation RHLocation
@synthesize currentLocation, locationManager;


+ (id)instance
{
	if(sharedRHLocation == NULL){
		sharedRHLocation = [[RHLocation alloc] init];
	}
	return sharedRHLocation;
	
}


- (void) turnOnLocationServices{
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
	
}

- (RHLocation * ) init {
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
	[self turnOnLocationServices];
    return self;
}


- (NSString *) _getLatitudeString{
    return [NSString stringWithFormat: @"%g", currentLocation.coordinate.latitude];
}

- (NSString *) _getLongitudeString {
    return [NSString stringWithFormat: @"%g", currentLocation.coordinate.longitude];
}


#pragma - Public Interface

+ (NSString *) getLatitudeString {
    return [self.instance _getLatitudeString];
}

+ (NSString *) getLongitudeString {
   return [self.instance _getLongitudeString];
}


#pragma mark - CLLocationManagerDelegate Methods


/*
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if(status != kCLAuthorizationStatusAuthorized){
		UIAlertView *alert = [[UIAlertView alloc]						  
							  initWithTitle:[NSString stringWithFormat:@"Location Services Declined"]
							  message:
							  [NSString stringWithFormat:@"We can understand not wanting to use location services, but this application is pretty useless without them turned on"]
							  delegate: self
							  cancelButtonTitle:@"Enable Location Services"
							  otherButtonTitles:nil
							  ];
		[alert show];
	}
}
 */

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
	self.currentLocation = newLocation;
    
}

- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error {
    
    NSString *errorType = (error.code == kCLErrorDenied) ? 
    @"Access Denied" : @"Unknown Error";
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error getting Location" 
                          message:errorType 
                          delegate:nil 
                          cancelButtonTitle:@"Okay" 
                          otherButtonTitles:nil];
    [alert show];
    
}


@end
