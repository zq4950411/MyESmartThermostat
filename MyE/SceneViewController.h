//
//  SceneViewController.h
//  MyE
//
//  Created by space on 13-8-12.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"

@class PopAddNewSceneViewController;
@interface SceneViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    int currentDeleteIndex;
    int applyIndex;
    
    PopAddNewSceneViewController *popController;
}

-(void) addSceneWithName:(NSString *) name andMode:(NSString *) mode;
-(void) dimissView;

@end
