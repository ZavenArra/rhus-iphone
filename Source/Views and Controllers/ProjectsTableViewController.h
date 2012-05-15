//
//  ProjectsTableViewController.h
//  Rhus
//
//  Created by Deep Winter on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProjectsTableViewControllerDelegate <NSObject>
    
- (void) didChangeProject;

@end

@interface ProjectsTableViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UINavigationBar * navigationBar;
    IBOutlet UIView * addProjectDialog;
    IBOutlet UITableView * tableView;
    IBOutlet UITextField * projectNameField;
    NSArray * projects;
    id <ProjectsTableViewControllerDelegate> delegate;
}
@property(nonatomic, retain) UINavigationBar * navigationBar;
@property(nonatomic, retain) NSArray * projects;
@property(nonatomic, retain) UIView * addProjectDialog;
@property(nonatomic, retain) UITableView * tableView;
@property(nonatomic, retain) UITextField * projectNameField;
@property(nonatomic, retain) id<ProjectsTableViewControllerDelegate> delegate;

-(IBAction) didTouchDone:(id)sender;
-(IBAction) didTouchAddProject:(id)sender;
-(IBAction) didTouchConfirmProject:(id)sender;
-(IBAction) didTouchCancelAddProject:(id)sender;


@end
