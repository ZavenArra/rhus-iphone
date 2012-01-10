//
//  GalleryViewController.h
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryViewController : UIViewController
{
    UIScrollView * galleryScrollView;
    UIScrollView * detailScrollView;

}
@property(strong, nonatomic) IBOutlet UIScrollView * galleryScrollView;
@property(strong, nonatomic) IBOutlet UIScrollView * detailScrollView;


- (IBAction)didTouchThumbnail:(id)sender;
@end
