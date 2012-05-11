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
    
}
@property(nonatomic, retain) UINavigationBar * navigationBar;

@end
