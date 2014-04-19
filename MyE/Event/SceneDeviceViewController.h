//
//  SceneDeviceViewController.h
//  MyE
//
//  Created by space on 13-8-23.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"

@class SceneEntity;
@class AddSceneDeviceViewControlerViewController;
@class PopEditSceneViewController;

@interface SceneDeviceViewController : BaseTableViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    __weak  SceneEntity *scene;
    
    NSMutableArray *addDeviceList;
    NSMutableArray *deviceList;
    
    AddSceneDeviceViewControlerViewController *addSceneVc;
    PopEditSceneViewController *popEdithSceneName;
}

@property (nonatomic,weak) SceneEntity *scene;

@property (nonatomic,strong) NSMutableArray *addDeviceList;
@property (nonatomic,strong) NSMutableArray *deviceList;

-(id) initWithScene:(SceneEntity *) scene;
-(void) dimiss;
-(void) dimissWithDeviceId:(NSString *) deviceId;
-(void) editSceneName:(NSString *) sceneName;

@end