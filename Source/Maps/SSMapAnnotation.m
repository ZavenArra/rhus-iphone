//
// SSMapAnnotation.m
// Public Domain
//
// Created by Sam Soffes on 3/22/10.
// Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSMapAnnotation.h"

@implementation SSMapAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

#pragma mark -
#pragma mark Class Methods

+ (SSMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)aCoordinate {
    return [self mapAnnotationWithCoordinate:aCoordinate title:nil subtitle:nil];
}


+ (SSMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle {
    return [self mapAnnotationWithCoordinate:aCoordinate title:aTitle subtitle:nil];
}


+ (SSMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle subtitle:(NSString *)aSubtitle {
    SSMapAnnotation *annotation = [[self alloc] init];
    annotation.coordinate = aCoordinate;
    annotation.title = aTitle;
    annotation.subtitle = aSubtitle;
    return annotation;
}





#pragma mark -
#pragma mark Initializers

- (SSMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate {
    return [self initWithCoordinate:aCoordinate title:nil subtitle:nil];
}


- (SSMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle {
    return [self initWithCoordinate:aCoordinate title:aTitle subtitle:nil];
}


- (SSMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle subtitle:(NSString *)aSubtitle {
    if ((self = [super init])) {
        self.coordinate = aCoordinate;
        self.title = aTitle;
        self.subtitle = aSubtitle;
    }
    return self;
}
@end
