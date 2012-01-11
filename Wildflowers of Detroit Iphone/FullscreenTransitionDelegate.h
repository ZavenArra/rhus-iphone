//
//  FullscreenTransitionDelegate.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FullscreenTransitionDelegate <NSObject>

-(void)subviewRequestingFullscreen;
-(void)subviewReleasingFullscreen;


@end
