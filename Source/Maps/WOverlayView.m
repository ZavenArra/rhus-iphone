//
//  WOverlayView.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WOverlayView.h"

@implementation WOverlayView
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)ctx {

    UIImage *image          = [UIImage imageNamed:@"IMG_0015.jpg"];
    
    CGImageRef imageReference = image.CGImage;
    
    MKMapRect theMapRect    = [self.overlay boundingMapRect];
    CGRect theRect           = [self rectForMapRect:theMapRect];
    CGRect clipRect     = [self rectForMapRect:mapRect];
    
    CGContextAddRect(ctx, clipRect);
    CGContextClip(ctx);
    
    CGContextDrawImage(ctx, theRect, imageReference);
    
    
    /*
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, .5);
    CGContextFillRect(ctx, CGRectMake(100.0, 100.0, 100.0, 100.0));
     */
}
@end
