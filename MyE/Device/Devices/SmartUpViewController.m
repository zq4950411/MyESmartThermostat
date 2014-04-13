//
//  SmartUpViewController.m
//  MyE
//
//  Created by space on 13-8-6.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "SmartUpViewController.h"
#import "AddSmartUpTableViewView.h"
#import "OperationViewController.h"
#import "PlugControlViewController.h"
#import "ControlViewController.h"
#import "MyESwitchManualControlViewController.h"
#import "MyESwitchAutoViewController.h"
#import "MyESwitchElecInfoViewController.h"


#import "MyEHouseData.h"

#import "SmartUp.h"
#import "SmartupCell.h"


@implementation SmartUpViewController


-(SmartUp *) getCurrentSmartup
{
    return [self.datas safeObjectAtIndex:currentSelectedIndex];
}
-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    [self headerFinish];
    NSLog(@"%@",jsonString);
    if ([u rangeOfString:URL_FOR_SMARTUP_LIST].location != NSNotFound)
    {
        self.datas = [SmartUp devices:jsonString];
        [self.tableView reloadData];
    }
    else if ([u rangeOfString:URL_FOR_SAVE_SORT].location != NSNotFound)
    {
        if([jsonString isEqualToString:@"OK"])
        {
            [SVProgressHUD showSuccessWithStatus:@"Successs"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Error"];
        }
        [self.tableView setEditing:NO];
    }
    else if ([u rangeOfString:URL_FOR_SWITCH_CONTROL].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            SmartUp *smartUp = [self.datas safeObjectAtIndex:currentTapIndex];
            SmartupCell *cell = (SmartupCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
            UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:currentTapIndex];
            if (smartUp.switchStatus.intValue == 0)
            {
                smartUp.switchStatus = @"1";
                image.image = [UIImage imageNamed:@"switch1-on"];
            }
            else
            {
                smartUp.switchStatus = @"0";
                image.image = [UIImage imageNamed:@"switch1-off"];
            }
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
    }

    else if ([u rangeOfString:URL_FOR_SMARTUP_PlUG_CONTROL].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            SmartUp *smartUp = [self.datas safeObjectAtIndex:currentTapIndex];
            
            if (smartUp.switchStatus.intValue == 0)
            {
                smartUp.switchStatus = @"1";
            }
            else
            {
                smartUp.switchStatus = @"0";
            }
            
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
    }
    else if ([u rangeOfString:URL_FOR_SAVE_DEVICE].location != NSNotFound)
    {
        if([jsonString isEqualToString:@"OK"])
        {
            [self.datas safeRemovetAtIndex:currentSelectedIndex];
            [self.tableView reloadData];
            [SVProgressHUD showSuccessWithStatus:@"Successs"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Error"];
        }
        [self.tableView setEditing:NO];
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_SMARTUP_LIST].location != NSNotFound)
    {

    }
    else if ([u rangeOfString:URL_FOR_SAVE_SORT].location != NSNotFound)
    {
        [self.tableView setEditing:NO];
    }
    else if ([u rangeOfString:URL_FOR_SMARTUP_PlUG_CONTROL].location != NSNotFound)
    {
        
    }
    else if ([u rangeOfString:URL_FOR_SAVE_DEVICE].location != NSNotFound)
    {
        
    }
}
-(void) plug:(UITapGestureRecognizer *) tap
{
    currentTapIndex = tap.view.tag;
    _selectedIndexPath = [self.tableView indexPathForCell:(SmartupCell *)tap.view.superview];
    SmartUp *smart = (SmartUp *)[self.datas objectAtIndex:tap.view.tag];
    if (smart.rfStatus.intValue == -1)
    {
        return;
    }
    
    self.isShowLoading = YES;
//    if (smart.typeId.intValue == 8) {
//        MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%@&tId=%@&switchStatus=%i&action=1",GetRequst(URL_FOR_SWITCH_CONTROL),[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId],smart.tid,[smart.switchStatus isEqualToString:@"1"]?0:1] postData:nil delegate:self loaderName:@"controlSwitch" userDataDictionary:nil];
//        NSLog(@"controlSwitch loader is %@",loader.name);
//        return;
//    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smart.tid forKey:@"tId"];
    if (smart.typeId.intValue == 8) {
        [params safeSetObject:@"1" forKey:@"action"];
        [params safeSetObject:[smart.switchStatus isEqualToString:@"1"]?@"0":@"1" forKey:@"switchStatus"];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
        
        [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SWITCH_CONTROL)
                                          delegate:self
                                      withUserInfo:dic];

    }else{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SMARTUP_PlUG_CONTROL)
                                      delegate:self
                                  withUserInfo:dic];
    }
}

-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SMARTUP_LIST)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) moveWithDeviceId:(NSString *) deviceId andSortedId:(NSString *) sort
{
    self.isShowLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:deviceId forKey:@"deviceId"];
    [params safeSetObject:sort forKey:@"sortId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SAVE_SORT)
                                      delegate:self
                                  withUserInfo:dic];
}


-(void) deleteWithDeviceId:(NSString *) deviceId andHouseId:(int) houseId
{
    self.isShowLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:deviceId forKey:@"deviceId"];
    [params safeSetObject:@"deleteDevice" forKey:@"action"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SAVE_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}




-(void) edit:(UIButton *) sender
{
     //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    currentTapIndex = indexPath.row;
//    currentSelectedIndex = sender.tag;
    SmartUp *smart = [self.datas objectAtIndex:indexPath.row];
    if (smart.typeId.intValue == 6)
    {
        PlugControlViewController *plug = [[PlugControlViewController alloc] initWithEditType];
        [self.navigationController pushViewController:plug animated:YES];
    }
    else if(smart.typeId.intValue == 7)
    {
        ControlViewController *controlVc = [[ControlViewController alloc] initWithEditType];
        [self.navigationController pushViewController:controlVc animated:YES];
    }
    else if(smart.typeId.intValue == 8)
    {
        NSLog(@"Add code to edit Switch");
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Switch" bundle:nil];
        MyESwitchEditViewController *vc = [story instantiateViewControllerWithIdentifier:@"switchEdit"];
        vc.device = smart;
//        ControlViewController *controlVc = [[ControlViewController alloc] initWithEditType];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        AddSmartUpTableViewView *vc = [[AddSmartUpTableViewView alloc] init];
        vc.smartup = smart;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    SmartupCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SmartupCell" owner:self options:nil] objectAtIndex:0];
        cell.showsReorderControl = YES;
    }
        
    SmartUp *smart = [self.datas objectAtIndex:indexPath.row];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:998];
    [btn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
//    UIButton *penButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [penButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
//    [penButton setImage:[UIImage imageNamed:@"editBtn.png"] forState:UIControlStateNormal];
//    penButton.frame = CGRectMake(0, 0, 60, 60);
//    penButton.tag = indexPath.row;
//    cell.accessoryView = penButton;

    if ([smart.typeId isEqualToString:@"6"])
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(plug:)];
        
        cell.imageView2.tag = indexPath.row;
        cell.imageView2.userInteractionEnabled = YES;
        [cell.imageView2 addGestureRecognizer:tap];
    }
    if ([smart.typeId isEqualToString:@"8"]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(plug:)];
        cell.imageView2.tag = indexPath.row;
        cell.imageView2.userInteractionEnabled = YES;
        [cell.imageView2 addGestureRecognizer:tap];
    }
    cell.object = [self.datas objectAtIndex:indexPath.row];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SmartUp *smart = [self.datas objectAtIndex:indexPath.row];
    if (smart.rfStatus.intValue == -1)
    {
        return;
    }
    
    //UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Smart-Up" style:UIBarButtonItemStyleBordered target:nil action:nil];
    //[self.parentViewController.navigationItem setBackBarButtonItem:backItem];
    
    currentSelectedIndex = indexPath.row;
    
    if (smart.typeId.intValue == 6)
    {
        PlugControlViewController *plug = [[PlugControlViewController alloc] init];
        [self.navigationController pushViewController:plug animated:YES];
    }
    else if(smart.typeId.intValue == 7)
    {
        ControlViewController *controlVc = [[ControlViewController alloc] init];
        [self.navigationController pushViewController:controlVc animated:YES];
    }
    else if(smart.typeId.intValue == 8)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Switch" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"DeviceSwitchTabbar"];
        
        UINavigationController *nc = [[tabBarController childViewControllers] objectAtIndex:0];
        MyESwitchManualControlViewController *switchManualVC = [[nc childViewControllers] objectAtIndex:0];
        switchManualVC.device = smart;
        
        UINavigationController *nc1 = [[tabBarController childViewControllers] objectAtIndex:1];
        MyESwitchAutoViewController *switchAutoVC = [[nc1 childViewControllers] objectAtIndex:0];
        switchAutoVC.device = smart;
        
        UINavigationController *nc2 = [[tabBarController childViewControllers] objectAtIndex:2];
        MyESwitchElecInfoViewController *elecInfoVC = [[nc2 childViewControllers] objectAtIndex:0];
        elecInfoVC.device = smart;
        [self presentViewController:tabBarController animated:YES completion:nil];
//        [self.navigationController pushViewController:tabBarController animated:YES];
    }
    else
    {
        if (smart.tid.length == 0)
        {
            [SVProgressHUD showErrorWithStatus:@"Please specify the SmartRemoteUsed"];
            return;
        }
        OperationViewController *operationVc = [[OperationViewController alloc] init];
        [self.navigationController pushViewController:operationVc animated:YES];
    }
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}


-(BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Deleting this device will also remove all settings associated with it. Are you sure to do so?"
                                                           delegate:self
                                                  cancelButtonTitle:@"YES"
                                                  otherButtonTitles:@"NO"
                                  , nil];
        alertView.tag = indexPath.row;
        [alertView show];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        SmartUp *smartUP = (SmartUp *)[self.datas safeObjectAtIndex:alertView.tag];
        currentSelectedIndex = alertView.tag;
        
        [self deleteWithDeviceId:smartUP.deviceId andHouseId:MainDelegate.houseData.houseId];
    }
}

// 可选，对那些被移动栏格作特定操作
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.row == toIndexPath.row)
    {
        return;
    }
    SmartUp *smart = [self.datas objectAtIndex:fromIndexPath.row];
    [self moveWithDeviceId:smart.deviceId andSortedId:[NSString stringWithFormat:@"%d",toIndexPath.row]];
}


-(void) viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tap:)];
    [self.tableView addGestureRecognizer:tap];
    [self initHeaderView:self];

}

-(void) tap:(UILongPressGestureRecognizer *) tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [self.tableView setEditing:!self.tableView.editing animated:YES];
    }
}


-(void) addAction:(id) sender
{
    AddSmartUpTableViewView *add = [[AddSmartUpTableViewView alloc] init];
    [self.navigationController pushViewController:add animated:YES];
}

-(void) refreshAction:(id) sender
{
    [self sendGetDatas];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.title = @"Devices";
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addAction:)];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(refreshAction:)];
    self.parentViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton,addButtonItem, nil];
    
    [self sendGetDatas];
}




@end
