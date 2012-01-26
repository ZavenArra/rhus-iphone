//
//  TimelineVisualizationView.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimelineVisualizationView.h"

#define channelWidth 7

@implementation TimelineVisualizationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context    = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.3, 0.6, 1.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    
   // self.frame.size.height;
    
    CGContextMoveToPoint(context, 10.0, 30.0);
    
    // Draw a connected sequence of line segments
    // here we are creating an Array of points that we will combine to form
    // a path
    CGPoint addLines[] =
    {
        CGPointMake(0.0, 150.0),
        CGPointMake(70.0, 60.0),
        CGPointMake(130.0, 90.0),
        CGPointMake(190.0, 60.0),
        CGPointMake(250.0, 90.0),
        CGPointMake(310.0, 60.0),
    };
    
    // now we can simply add the lines to the context
    CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
    
    // and now draw the Path!
    CGContextStrokePath(context);
    
}

@end
