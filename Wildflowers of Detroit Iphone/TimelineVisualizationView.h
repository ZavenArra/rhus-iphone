//
//  TimelineVisualizationView.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimelineVisualizationViewDelegate <NSObject>

/*
 - (NSArray *) dataForVisualization
 Function must return an NSArray of CGPointMake objects, stored as NSValue
 i.e. [data addObject: [NSValue valueWithCGPoint: CGPointMake(i, level)]];
 */
- (NSArray *) dataForVisualization;
- (CGFloat) dataRange;
- (CGFloat) dataDomain;


@end

@interface TimelineVisualizationView : UIView
{
    NSArray * data;  // Array of CGPoint objects
    id <TimelineVisualizationViewDelegate> delegate;
}
@property(nonatomic, retain) NSArray * data;
@property(nonatomic, retain) id <TimelineVisualizationViewDelegate> delegate;

@end

