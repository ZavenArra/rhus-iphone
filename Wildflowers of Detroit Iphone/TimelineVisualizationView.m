//
//  TimelineVisualizationView.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimelineVisualizationView.h"

#define channelWidth 7
#define alpha .5
#define visualizationColorR .949
#define visualizationColorG .404
#define visualizationColorB .137
#define smoothingWindowHalfWidth 1

@implementation TimelineVisualizationView

@synthesize data;
@synthesize delegate;

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
    
    NSLog(@"Not Drawing Visualization");
    
    // Drawing code
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
	//CGRect cgBounds = [self bounds];
    CGContextSetRGBStrokeColor(context, visualizationColorR, visualizationColorG, visualizationColorB, alpha);
    //CGContextStrokeRect(context, cgBounds);
    CGContextSetLineWidth(context, 2.0);    
	CGContextSetRGBFillColor(context, visualizationColorR, visualizationColorG, visualizationColorB, alpha);
   // CGContextFillRect(context, cgBounds);
	
    
    NSArray * rawData = [delegate dataForVisualization];
    //And rescale data for display in x,y bounds
    
  //  CGPoint startPoint = [ (NSValue*) [rawData objectAtIndex:0] CGPointValue];
   // CGPoint endPoint = [ (NSValue*) [rawData objectAtIndex:[rawData count]-1 ] CGPointValue];
    float xDiff = [self.delegate dataRange];
    float yDiff = [self.delegate dataDomain];
    
    NSMutableArray * processedData = [NSMutableArray array];
    for( NSValue * value in rawData){
        CGPoint point = [value CGPointValue];
        point.x = point.x * self.frame.size.width / xDiff + self.frame.origin.x;
        //point.y = point.y * self.frame.size.height / ((yDiff-channelWidth)/2) + self.frame.origin.y;
        point.y = point.y * (self.frame.size.height/2 - channelWidth/2) / yDiff;// + self.frame.origin.y;

        [processedData addObject:[NSValue valueWithCGPoint:point]];
    }
    
    self.data = processedData;

    CGPoint start;
    start.x = 0;
    start.y = self.frame.size.height /2;// + channelWidth/2;
    CGContextMoveToPoint(
                         context,
                         start.x,
                         start.y
                         );
    
    
    
    CGPoint current = [(NSValue *) [self.data objectAtIndex:0] CGPointValue];
    CGContextAddLineToPoint(
                            context,
                            current.x,
                            //self.frame.origin.y + 
                            start.y +
                            channelWidth/2 +
                            current.y
                            );

    CGPoint controlPoint1;
    CGPoint controlPoint2;
    
    
    
    for(int i=smoothingWindowHalfWidth; i < [self.data count] - smoothingWindowHalfWidth; i++){
        CGPoint next = [(NSValue *) [self.data objectAtIndex:i] CGPointValue]; //potential next point
        CGPoint nextNext = [(NSValue *) [self.data objectAtIndex:i+1] CGPointValue];  //potential next point
        
        
        //Apply windowing / smoothing
        /* */
        float yAvg=0;
        float xAvg=0;
        for(int j = 1; j <= smoothingWindowHalfWidth; j++){
            yAvg += [(NSValue *) [self.data objectAtIndex:i-j] CGPointValue].y;
            xAvg += [(NSValue *) [self.data objectAtIndex:i-j] CGPointValue].x;
            
        }
        yAvg += next.y;
        xAvg += next.x;
        
        for(int j = 1; j <= smoothingWindowHalfWidth; j++){
            yAvg += [(NSValue *) [self.data objectAtIndex:i+j] CGPointValue].y;
            xAvg += [(NSValue *) [self.data objectAtIndex:i+j] CGPointValue].x;
            
        }
        yAvg = yAvg / (smoothingWindowHalfWidth*2 + 1);
        next.y = yAvg;
        xAvg = xAvg / (smoothingWindowHalfWidth*2 + 1);
        next.x = xAvg;
        
        yAvg=0;
        xAvg=0;
        /*  */
        
        /*
         Skip NextNext smoothing for now
        for(int j = 1; j <= smoothingWindowHalfWidth; j++){
            yAvg += points[i - j + 1].y;
            xAvg += points[i - j + 1].x;
            
        }
        yAvg += nextNext.y;
        xAvg += nextNext.x;
        
        for(int j = 1; j <= smoothingWindowHalfWidth; j++){
            yAvg += points[i + j + 1].y;
            xAvg += points[i + j + 1].x;
            
        }
        yAvg = yAvg / (smoothingWindowHalfWidth*2 + 1);
        nextNext.y = yAvg;
        xAvg = xAvg / (smoothingWindowHalfWidth*2 + 1);
        nextNext.x = xAvg;
        */
        
        bool minMax = false;
        
        //minima condition
        if(next.y < current.y && nextNext.y >= next.y){
            minMax = true;
        } 
        //maxima condition
        else if(next.y > current.y && nextNext.y <= next.y){
            minMax = true;
        }
        else if(current.y == next.y){
            minMax = true;
        }
        
        
        if(minMax){
            //slope should be zero at this local min/max
            //in both directions
            //only these points are drawn
            //i.e., next really is the next point to draw to
            controlPoint1 = current;
            controlPoint1.x = current.x + (next.x - current.x)/2;
            controlPoint2 = next;
            controlPoint2.x = next.x - (next.x - current.x)/2;
            //continue;
            CGContextAddCurveToPoint(
                                     context,
                                     controlPoint1.x,
                                     //self.frame.origin.y  + 
                                     start.y +
                                     channelWidth/2 +
                                     controlPoint1.y,
                                     controlPoint2.x,
                                     //self.frame.origin.y  + 
                                     start.y +
                                     channelWidth/2 +
                                     controlPoint2.y,
                                     next.x,
                                     //self.frame.origin.y  + 
                                     start.y +
                                     channelWidth/2 +
                                     next.y);
            current = next;
        }
        
    }
    CGPoint end;
    end.x = current.x;
    end.y = self.frame.size.height / 2;
    CGContextAddLineToPoint (
                             context,
                             end.x,
                             end.y
                            );
    
    
    CGContextFillPath(context);


    
    //
    //  And draw Mirror Image
    //
    
    current = [(NSValue *) [self.data objectAtIndex:0] CGPointValue];
    CGPoint drawCurrent = current;
    CGPoint drawNext;
    
    
    CGContextMoveToPoint(
                         context,
                         current.x,
                         self.frame.size.height/2
                         );
    
    drawCurrent.y =(self.frame.size.height/2 - channelWidth/2) - current.y;
    
    CGContextAddLineToPoint(
                            context,
                            drawCurrent.x,
                            //self.frame.origin.y + 
                            drawCurrent.y
                            );
    
    for(int i=smoothingWindowHalfWidth; i < [self.data count] - smoothingWindowHalfWidth; i++){
        CGPoint next = [(NSValue *) [self.data objectAtIndex:i] CGPointValue]; //potential next point
        CGPoint nextNext = [(NSValue *) [self.data objectAtIndex:i+1] CGPointValue];  //potential next point
        
        bool minMax = false;
        
        
        //Apply windowing / smoothing
        /* */
        float yAvg=0;
        float xAvg=0;
        for(int j = 1; j <= smoothingWindowHalfWidth; j++){
            yAvg += [(NSValue *) [self.data objectAtIndex:i-j] CGPointValue].y;
            xAvg += [(NSValue *) [self.data objectAtIndex:i-j] CGPointValue].x;
            
        }
        yAvg += next.y;
        xAvg += next.x;
        
        for(int j = 1; j <= smoothingWindowHalfWidth; j++){
            yAvg += [(NSValue *) [self.data objectAtIndex:i+j] CGPointValue].y;
            xAvg += [(NSValue *) [self.data objectAtIndex:i+j] CGPointValue].x;
            
        }
        yAvg = yAvg / (smoothingWindowHalfWidth*2 + 1);
        next.y = yAvg;
        xAvg = xAvg / (smoothingWindowHalfWidth*2 + 1);
        next.x = xAvg;
        
        yAvg=0;
        xAvg=0;
        
        
        //Apply windowing / smoothing
        /*
         int windowSize = 4;
         float yAvg=0;
         for(int j = 0; j < windowSize; j++){
         yAvg += points[i + j - windowSize / 2].y;
         }
         yAvg = yAvg / windowSize;
         next.y = yAvg;
         */
        
        
        //minima condition
        if(next.y < current.y && nextNext.y >= next.y){
            minMax = true;
        } 
        
        //maxima condition
        else if(next.y > current.y && nextNext.y <= next.y){
            minMax = true;
        }
        
        else if(current.y == next.y){
            minMax = true;
        }
        
        if(minMax){
            //slope should be zero at this local min/max
            //in both directions
            //only these points are drawn
            //i.e., next really is the next point to draw to
            
            drawNext = next;
            drawNext.y = (self.frame.size.height/2 - channelWidth/2)  - next.y;
            
            controlPoint1 = drawCurrent;
            controlPoint1.x = drawCurrent.x + (drawNext.x - drawCurrent.x)/2;
            controlPoint2 = drawNext;
            controlPoint2.x = drawNext.x - (drawNext.x - drawCurrent.x)/2;
            //continue;
            CGContextAddCurveToPoint(
                                     context,
                                     controlPoint1.x,
                                     //self.frame.origin.y  + 
                                     controlPoint1.y,
                                     controlPoint2.x,
                                     //self.frame.origin.y  + 
                                     controlPoint2.y,
                                     drawNext.x,
                                     //self.frame.origin.y  + 
                                     drawNext.y
                                     );
            current = next;
            drawCurrent = drawNext;
        }
        
    }
    end.x = current.x;
    end.y = self.frame.size.height/2;
    CGContextAddLineToPoint (
                             context,
                             end.x,
                             end.y
                             );
    
    
    CGContextFillPath(context);

    
    /*
   // self.frame.size.height;
    
    CGContextMoveToPoint(context, 10.0, 30.0);
    
    // Draw a connected sequence of line segments
    // here we are creating an Array of points that we will combine to form
    // a path
    CGPoint addLines[] =
    {
        CGPointMake(0.0, 0),
        CGPointMake(70.0, 20.0),
        CGPointMake(130.0, 30.0),
        CGPointMake(190.0, 10.0),
        CGPointMake(250.0, 70.0),
        CGPointMake(310.0, 10.0),
    };
    
    // now we can simply add the lines to the context
    CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
    
    // and now draw the Path!
    CGContextStrokePath(context);
    */
}

@end
