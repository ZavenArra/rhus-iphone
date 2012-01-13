//
//  ImageScrollView.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageScrollViewDelegate <NSObject>
@optional
- (void)layoutScrollViewImages;
- (UIView *)cellForItemAtIndex:(int)index;
- (float) scrollObjectWidth;
- (float) scrollObjectHeight;
- (NSDictionary *)scrollDataObjectForIndex:(int)index;
- (NSInteger) numberOfObjectsInScroll;

@end

@interface ImageScrollView : UIScrollView

@end
