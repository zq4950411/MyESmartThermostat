//
//  SceneViewController.m
//  MyE
//
//  Created by space on 13-8-12.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "SceneViewController.h"
#import "PopAddNewSceneViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "SceneDeviceViewController.h"

#import "MyEHouseData.h"
#import "SceneEntity.h"
#import "SceneCell.h"
#import "ACPButton.h"
#import "SWRevealViewController.h"


@implementation SceneViewController


-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    [self headerFinish];
    if ([u rangeOfString:URL_FOR_SCENES_VIEW].location != NSNotFound)
    {
        if ([jsonString JSONValue] != nil)
        {
            self.datas = [SceneEntity scenes:jsonString];
            [self.tableView reloadData];
        }
    }
    
    else if ([u rangeOfString:URL_FOR_SCENES_SAVE_SCENE].location != NSNotFound)
    {
        NSString *action = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"action"];
        if ([@"deleteScene" isEqualToString:action])
        {
            if ([jsonString isEqualToString:@"OK"])
            {
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                
                [self.datas safeRemovetAtIndex:currentDeleteIndex];
                [self.tableView reloadData];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"Error"];
            }
        }
        else if ([@"addScene" isEqualToString:action])
        {
            if ([jsonString isEqualToString:@"OK"])
            {
                [SVProgressHUD showSuccessWithStatus:@"Success"];
            }
            else if ([jsonString rangeOfString:@"sceneId"].location != NSNotFound)
            {
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                
                SceneEntity *scene = [[SceneEntity alloc] init];
                
                scene.sceneId = [[jsonString JSONValue] objectForKey:@"sceneId"];
                scene.sceneName = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"sceneName"];
                scene.type = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"type"];
                
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                [tempArray addObject:scene];
                [tempArray addObjectsFromArray:self.datas];
                self.datas = tempArray;
                [self.tableView reloadData];
                
                if (scene.type.intValue == 2)
                {
                    
                }
                else
                {
                    SceneDeviceViewController *device = [[SceneDeviceViewController alloc] initWithScene:scene];
                    device.scene = scene;
                    
                    [self.navigationController pushViewController:device animated:YES];
                }
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"Error"];
            }
        }
        else if ([@"applyScene" isEqualToString:action])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            
            SceneEntity *scene = [self.datas safeObjectAtIndex:applyIndex];
            
            scene.type = @"1";
            [self.tableView reloadData];
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    [self headerFinish];
    if ([u rangeOfString:URL_FOR_SOCKET_PlUG_CONTROL].location != NSNotFound)
    {
        
    }
    else if ([u rangeOfString:URL_FOR_SCENES_SAVE_SCENE].location != NSNotFound)
    {
        
    }
}









-(void) apply:(UIButton *) sender
{
    self.isShowLoading = YES;
    applyIndex = sender.tag;
    
    SceneEntity *scene = (SceneEntity *)[self.datas safeObjectAtIndex:applyIndex];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:scene.sceneId forKey:@"sceneId"];
    [params safeSetObject:@"applyScene" forKey:@"action"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SCENES_SAVE_SCENE)
                                      delegate:self
                                  withUserInfo:dic];
}







-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SCENES_VIEW)
                                      delegate:self
                                  withUserInfo:dic];
}


-(void) deleteAction
{
    self.isShowLoading = YES;
    
    SceneEntity *scene = (SceneEntity *)[self.datas safeObjectAtIndex:currentDeleteIndex];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:scene.sceneId forKey:@"sceneId"];
    [params safeSetObject:@"deleteScene" forKey:@"action"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SCENES_SAVE_SCENE)
                                      delegate:self
                                  withUserInfo:dic];
}


-(void) addSceneAction:(UIButton *) sender
{
    if (popController == nil)
    {
        popController = [[PopAddNewSceneViewController alloc] init];
    }
    
    popController.parentVC = self;
    [self presentSemiViewController:popController];
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


-(void) addSceneWithName:(NSString *) name andMode:(NSString *) mode
{
    [self dismissSemiModalView];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:name forKey:@"sceneName"];
    [params safeSetObject:mode forKey:@"type"];
    [params safeSetObject:@"addScene" forKey:@"action"];    

    [self performSelector:@selector(addSAction:) withObject:params afterDelay:.5f];
}





-(void) dimissView
{
    [self dismissSemiModalView];
}











-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self deleteAction];
    }
}









-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        SceneEntity *scene = (SceneEntity *)[self.datas safeObjectAtIndex:indexPath.row];
        SceneDeviceViewController *device = [[SceneDeviceViewController alloc] initWithScene:scene];
        device.scene = scene;
        
        [self.navigationController pushViewController:device animated:YES];
    }
}



-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.datas.count;
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
        return 70;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *identifier = @"Cell";
        SceneCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
      
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SceneCell" owner:self options:nil] objectAtIndex:0];
        }
        
        cell.object = [self.datas safeObjectAtIndex:indexPath.row];
        
        cell.headButton.tag = indexPath.row;
        [cell.headButton addTarget:self action:@selector(apply:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else
    {
        static NSString *identifier = @"Cell2";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell10"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            
            ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:@"Add new scene" forState:UIControlStateNormal];
            [button setStyleType:ACPButtonOK];
            button.frame = CGRectMake(20, 10, 280, 44);
            [button addTarget:self action:@selector(addSceneAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:button];
        }
        
        return cell;
    }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentDeleteIndex = indexPath.row;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Are you sure to delete this scene?"
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO"
                              , nil];
    alertView.tag = indexPath.row;
    [alertView show];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self initHeaderView:self];
    
    //NSLog(NSStringFromCGRect(self.view.frame));
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.36f alpha:0.82f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.title = @"Events";
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    
    [self sendGetDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
