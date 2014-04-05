//
//  SceneDeviceViewController.m
//  MyE
//
//  Created by space on 13-8-23.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "SceneDeviceViewController.h"
#import "AddSceneDeviceViewControlerViewController.h"
#import "UIViewController+KNSemiModal.h"

#import "PopEditSceneViewController.h"

#import "DeviceCell.h"
#import "MyEHouseData.h"
#import "SceneEntity.h"
#import "ACPButton.h"
#import "DeviceEntity.h"

@implementation SceneDeviceViewController

@synthesize addDeviceList;
@synthesize deviceList;
@synthesize scene;

-(void) dimissWithDeviceId:(NSString *) deviceId
{
    [self dimiss];
    for (int i = 0; i < addDeviceList.count; i++)
    {
        DeviceEntity *d = [addDeviceList objectAtIndex:i];
        if ([d.deviceId isEqualToString:deviceId])
        {
            [addDeviceList removeObject:d];
        }
    }
    [self.tableView reloadData];
    [self sendGetDatas];
}

-(void) dimiss
{
    [self dismissSemiModalView];
}

-(id) initWithScene:(SceneEntity *) s
{
    if (self = [super init])
    {
        self.scene = s;
    }
    return self;
}




-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    [self headerFinish];
    if ([u rangeOfString:URL_FOR_SCENES_FIND_SCENE_DEVICE].location != NSNotFound)
    {
        self.addDeviceList = [DeviceEntity getDevicesByKey:@"addDeviceList" jsonString:jsonString];
        self.deviceList = [DeviceEntity getDevicesByKey:@"deviceList" jsonString:jsonString];
        [self.tableView reloadData];
    }
    else if ([u rangeOfString:URL_FOR_SCENES_DELETE_SCENE_DEVICE].location != NSNotFound)
    {
        int index = [[[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"removeIndex"] intValue];
        [self.deviceList safeRemovetAtIndex:index];
        [self.tableView reloadData];
        
        [self sendGetDatas];
    }
    else if ([u rangeOfString:URL_FOR_SCENES_SAVE_SCENE].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Fail"];
            self.title = scene.sceneName;
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    [self headerFinish];
}





-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:scene.sceneId forKey:@"sceneId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SCENES_FIND_SCENE_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}


//修改场景设备
-(void) addSceneAction:(UIButton *) sender
{
    addSceneVc = [[AddSceneDeviceViewControlerViewController alloc] initWithDatas:self.addDeviceList];
    addSceneVc.parentVC = self;
    [self presentSemiViewController:addSceneVc];
}







//修改场景名称
-(void) editSceneAction:(UIButton *) sender
{
    if (popEdithSceneName == nil)
    {
        popEdithSceneName = [[PopEditSceneViewController alloc] initWithSceneName:scene.sceneName];
    }
    
    popEdithSceneName.parentVC = self;
    [self presentSemiViewController:popEdithSceneName];
}



-(void) editSceneName:(NSString *) sceneName
{
    self.title = sceneName;
    [self dismissSemiModalView];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:scene.sceneId forKey:@"sceneId"];
    [params safeSetObject:sceneName forKey:@"sceneName"];
    [params safeSetObject:@"editScene" forKey:@"action"];
    [params safeSetObject:@"0" forKey:@"type"];
    
    [self performSelector:@selector(addSAction:) withObject:params afterDelay:.5f];
}

-(void) addSAction:(NSDictionary *) dictionary
{
    self.isShowLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SCENES_SAVE_SCENE)
                                      delegate:self
                                  withUserInfo:dic];
}

















-(void) deleteSceneDeviceWithIndex:(int) index
{
    self.isShowLoading = YES;
    
    DeviceEntity *d = [deviceList safeObjectAtIndex:index];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:scene.sceneId forKey:@"sceneId"];
    [params safeSetObject:d.sceneSubId forKey:@"sceneSubId"];
    //[params safeSetObject:[NSString stringWithFormat:@"%d",index] forKey:@"removeIndex"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SCENES_DELETE_SCENE_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}









-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self deleteSceneDeviceWithIndex:alertView.tag];
    }
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceEntity *d = [deviceList safeObjectAtIndex:indexPath.row];
    
    addSceneVc = [[AddSceneDeviceViewControlerViewController alloc] initWithDevice:d];
    addSceneVc.parentVC = self;
    [self presentSemiViewController:addSceneVc];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Removing the smart device will lose all associated programmed info. Are you sure to continue?"
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO"
                              ,nil];
    alertView.tag = indexPath.row;
    [alertView show];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.deviceList.count;
    }
    else
    {
        return 1;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 44;
    }
    else
    {
        return 44;
    }
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier1 = @"cell";
    static NSString *identifier2 = @"cell2";
    static NSString *identifier3 = @"cell3";
    
    DeviceCell *cell = nil;
    if (indexPath.section == 0)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DeviceCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        id object = [self.deviceList safeObjectAtIndex:indexPath.row];
        cell.object = object;
    }
    else if (indexPath.section == 1)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier2];
        if (cell == nil)
        {
            cell = [[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, cell.height)];
            
            ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:@"Add a new device to the scene" forState:UIControlStateNormal];
            [button setStyleType:ACPButtonOK];
            button.frame = CGRectMake(10, 10, 280, 44);
            [button addTarget:self action:@selector(addSceneAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:button];
        }
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier3];
        if (cell == nil)
        {
            cell = [[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, cell.height)];
            
            ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:@"Edit scene name" forState:UIControlStateNormal];
            [button setStyleType:ACPButtonOK];
            button.frame = CGRectMake(10, 10, 280, 44);
            [button addTarget:self action:@selector(editSceneAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:button];
        }
    }
    
    return cell;
}




- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self initFooterView:self];
    
    self.title = self.scene.sceneName;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendGetDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
