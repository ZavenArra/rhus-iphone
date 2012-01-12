//
//  GalleryViewController.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullscreenTransitionDelegate.h"

@interface GalleryViewController : UIViewController
{
    id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
    UIScrollView * galleryScrollView;
    UIView * detailView;
    UIScrollView * detailScrollView;
    
    UIImageView * zoomView;

}

@property(strong, nonatomic) id <FullscreenTransitionDelegate> fullscreenTransitionDelegate;
@property(strong, nonatomic) IBOutlet UIScrollView * galleryScrollView;
@property(strong, nonatomic) IBOutlet UIScrollView * detailScrollView;
@property(strong, nonatomic) IBOutlet UIView * detailView;

@property(strong, nonatomic) IBOutlet     UIImageView * zoomView;




- (IBAction)didTouchThumbnail:(id)sender;
@end
