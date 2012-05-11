//
//  ProjectsTableViewController.h
//  Rhus
//
//  Created by Deep Winter on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectsTableViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UINavigationBar * navigationBar;
    NSArray * projects;
}
@property(nonatomic, retain) UINavigationBar * navigationBar;
@property(nonatomic, retain) NSArray * projects;

-(IBAction) didTouchCancel:(id)sender;
-(IBAction) didTouchAddProject:(id)sender;

@end
