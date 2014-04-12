//
//  SettingViewController.m
//  MyE
//
//  Created by space on 13-8-30.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "SettingViewController.h"
#import "MyEHouseListViewController.h"

#import "UIUtils.h"

#import "ACPButton.h"
#import "MyEHouseData.h"
#import "SmartUp.h"

@implementation SettingViewController

@synthesize gateway;

-(NSString *) zoneIdToString:(NSString *) zoneId
{
    for (int i = 0; i < self.gateway.timeZones.count; i++)
    {
        NSDictionary *tempDic = [self.gateway.timeZones objectAtIndex:i];
        
        NSString *tempId = [tempDic valueToStringForKey:@"zoneId"];
        if ([tempId isEqualToString:zoneId])
        {
            return [tempDic objectForKey:@"zoneName"];
        }
    }
    return nil;
}


-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:SETTING_FIND_GATEWAY].location != NSNotFound)
    {
        if ([[jsonString JSONValue] count] > 0)
        {
            self.gateway = [GatewayEntity getGateWay:jsonString];
            [self.tableView reloadData];
        }

    }
    else if ([u rangeOfString:SETTING_EDITT].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            
            NSString *controlStat = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"controlState"];
            NSString *aliasName = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"aliasName"];
            
            SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:currentSelectedIndex];
            smart.deviceName = aliasName;
            smart.switchStatus = controlStat;
            
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Fail"];
            [self.tableView reloadData];
        }
    }
    else if ([u rangeOfString:SETTING_DELETE_T].location != NSNotFound)
    {
        if ([@"0" isEqualToString:jsonString])
        {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            
            [self.gateway.smartDevices safeObjectAtIndex:currentDeleteIndex];
            [self.tableView reloadData];
        }
        else if ([@"2" isEqualToString:jsonString])
        {
            [self performSelector:@selector(querryT) withObject:nil afterDelay:2.0f];
        }
    }
    else if ([u rangeOfString:SETTING_FIND_THERMOSTAT].location != NSNotFound)
    {
        if ([@"0" isEqualToString:jsonString])
        {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            
            [self.gateway.smartDevices safeRemovetAtIndex:currentDeleteIndex];
            [self.tableView reloadData];
        }
        else
        {
            [self performSelector:@selector(querryT) withObject:nil afterDelay:2.0f];
        }
    }
    else if ([u rangeOfString:SETTING_SAVETIMEZONE].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            self.gateway.timeZone = [[userInfo objectForKey:REQUET_PARAMS] valueToStringForKey:@"timeZone"];
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Fail"];
            [self.tableView reloadData];
        }
    }
    else if ([u rangeOfString:SETTING_DELETE_GATEWAY].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            
            self.gateway = nil;
            
            MyEHouseListViewController *houseListVC = (MyEHouseListViewController *)[UIUtils getControllerFromNavViewController:self andClass:[MyEHouseListViewController class]];
            [houseListVC refreshAction];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Fail"];
        }
    }
    
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:SETTING_FIND_THERMOSTAT].location != NSNotFound)
    {
        [self performSelector:@selector(querryT) withObject:nil afterDelay:2.0f];
    }
    else if ([u rangeOfString:SETTING_DELETE_T].location != NSNotFound || [u rangeOfString:SETTING_DELETE_GATEWAY].location != NSNotFound)
    {
        [SVProgressHUD showErrorWithStatus:@"Delete Error"];
    }
}



-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(SETTING_FIND_GATEWAY)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) deleteAction:(UIButton *) sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Removing the Gateway will lose programmed info of all associated smart devices. Are you sure to continue?"
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO"
                              , nil];
    alertView.tag = -1;
    [alertView show];
}



-(void) expand:(GatewayDeviceCell *) cell
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.gateway.smartDevices.count; i++)
    {
        SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:i];
        
        if (smart.isExpand)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:2]];
            smart.isExpand = NO;
        }
    }
    
    SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:cell.tag];
    smart.isExpand = YES;
    
    [indexPaths addObject:[NSIndexPath indexPathForRow:cell.tag inSection:2]];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}


-(void) unexpand:(GatewayDeviceCell *) cell
{    
    SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:cell.tag];
    smart.isExpand = NO;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    [indexPaths addObject:[NSIndexPath indexPathForRow:cell.tag inSection:2]];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}



-(void) editWithString:(NSMutableDictionary *) params
{
    SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:currentSelectedIndex];

    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:smart.tid forKey:@"tId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(SETTING_EDITT)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) querryT
{
    requestCount ++;
    
    if (requestCount >= 10)
    {
        requestCount = 0;
        [SVProgressHUD dismiss];
        
        return;
    }

    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:currentDeleteIndex];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:smart.tid forKey:@"tId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(SETTING_FIND_THERMOSTAT)
                                      delegate:self
                                  withUserInfo:dic];
}


-(void) vauleChanged:(UISwitch *) s
{
    self.currentSelectedIndex = s.tag;
    
    SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:currentSelectedIndex];
    if (smart.rfStatus.intValue == -1)
    {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (s.isOn)
    {
        [dic safeSetObject:@"0" forKey:@"controlState"];
    }
    else
    {
        [dic safeSetObject:@"1" forKey:@"controlState"];
    }
    
    [dic safeSetObject:smart.deviceName forKey:@"aliasName"];
    
    [self editWithString:dic];
}



-(void) rowDidSelected:(NSDictionary *) d
{
    isNeedRefresh = NO;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:self.gateway.mid forKey:@"mid"];
    [params setObject:[d objectForKey:@"zoneId"] forKey:@"timeZone"];
    //[params setObject:[d objectForKey:@"zoneName"] forKey:@"zoneName"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(SETTING_SAVETIMEZONE)
                                      delegate:self
                                  withUserInfo:dic];
}





#pragma mark UITextFieldDelegate
#pragma mark -

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *) textField
{
    self.currentSelectedIndex = textField.tag;
    
    if ([textField.text isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the name of the smart device"];
        return;
    }
    
    SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:textField.tag];
    if (![smart.deviceName isEqualToString:textField.text])
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [dic safeSetObject:textField.text forKey:@"aliasName"];
        [dic safeSetObject:smart.switchStatus forKey:@"controlState"];
        
        [self editWithString:dic];
    }
}









-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == -1)
    {
        if (buttonIndex == 0)
        {
            self.isShowLoading = YES;
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            
            [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
            [params setObject:self.gateway.mid forKey:@"mid"];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
            
            [[NetManager sharedManager] requestWithURL:GetRequst(SETTING_DELETE_GATEWAY)
                                              delegate:self
                                          withUserInfo:dic];
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            [SVProgressHUD showWithStatus:@"" maskType:SVProgressHUDMaskTypeClear];
            self.isShowLoading = NO;
            currentDeleteIndex = alertView.tag;
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
            
            SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:alertView.tag];
            [params setObject:smart.tid forKey:@"tId"];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
            
            [[NetManager sharedManager] requestWithURL:GetRequst(SETTING_DELETE_T)
                                              delegate:self
                                          withUserInfo:dic];
        }
    }
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 2)
    {
        if (self.gateway.timeZones.count > 0)
        {
            self.currentSelectedIndex = indexPath.row;
            
            DictionaryTableViewViewController *tempVc = [[DictionaryTableViewViewController alloc] initWithDatas:[NSMutableArray arrayWithArray:self.gateway.timeZones]];
            
            tempVc.delegate = self;
            tempVc.type = -1;
            [self.navigationController pushViewController:tempVc animated:YES];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Deleting this device will also remove all settings associated with it. Are you sure to do so?"
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO"
                              , nil];
    alertView.tag = indexPath.row;
    [alertView show];
}

-(CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section
{
    if (self.gateway == nil)
    {
        return 0;
    }
    else
    {
        if (section == 0 || section == 2)
        {
            return 44;
        }
        else
        {
            return 0;
        }
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section
{
    if (self.gateway == nil)
    {
        return nil;
    }
    
    if (section == 0 || section == 2)
    {
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 320, 30)];
        label.textColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:16.0f];
        [tempView addSubview:label];
        
        if (section == 0)
        {
            label.text = @"Gateway";
        }
        else
        {
            label.text = @"Smart Devices";
        }
        
        return tempView;
    }
    else
    {
        return nil;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        SmartUp *smart = [self.gateway.smartDevices safeObjectAtIndex:indexPath.row];
        if (smart.isExpand)
        {
            if (smart.typeId.intValue == 2 || smart.typeId.intValue == 3)
            {
                return 145;
            }
            else
            {
                return 192;
            }
        }
        else
        {
            return 54;
        }
    }
    else
    {
        return 44;
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.gateway == nil)
    {
        return 0;
    }
    else
    {
        if (MainDelegate.houseData.thermostats.count == 0)
        {
            return 2;
        }
        else
        {
            return 3;
        }
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 3;
    }
    else
    {
        return self.gateway.smartDevices.count;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *identifier = @"cell2";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
        
        [button setTitle:@"Remove the Gateway" forState:UIControlStateNormal];
        [button setStyleType:ACPButtonOK];
        button.frame = CGRectMake(10, 0, 280, 44);
        [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:button];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, cell.height)];
        
        return cell;
    }
    else if(indexPath.section == 1)
    {
        static NSString *identifier = @"cell2";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"M-ID";
            cell.detailTextLabel.text = self.gateway.mid;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = @"Associated property";
            cell.detailTextLabel.text = self.gateway.houseName;
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = @"Time zone";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [self zoneIdToString:self.gateway.timeZone];
        }
        
        return cell;
    }
    else
    {
        GatewayDeviceCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"GatewayDeviceCell" owner:self options:nil] objectAtIndex:0];
        
        cell.tag  = indexPath.row;
        cell.delegate = self;
        cell.object = [self.gateway.smartDevices safeObjectAtIndex:indexPath.row];
        
        cell.aliasTf.delegate = self;
        cell.aliasTf.tag = indexPath.row;
        
        cell.swch.tag = indexPath.row;
        [cell.swch addTarget:self action:@selector(vauleChanged:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    isNeedRefresh = YES;
    NSLog(@"%f    %f",self.tableView.frame.size.height,self.tableView.frame.origin.y);
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    self.parentViewController.navigationItem.title = @"Settings";
    
    if (isNeedRefresh)
    {
        [self sendGetDatas];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    isNeedRefresh = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end