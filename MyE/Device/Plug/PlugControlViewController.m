//
//  PlugControlViewController.m
//  MyE
//
//  Created by space on 13-8-15.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "PlugControlViewController.h"
#import "ScheduleViewController.h"

#import "CurrentChooseViewController.h"

#import "UIViewController+MJPopupViewController.h"

#import "MyEHouseData.h"

#import "SmartUpViewController.h"
#import "SmartUp.h"

#import "UIUtils.h"
#import "CommonCell.h"

#import "PlugEntity.h"
#import "ScheduleEntity.h"

#import "ACPButton.h"


@implementation PlugControlViewController


@synthesize selectedTime;
@synthesize plug;
@synthesize timer;


-(id) initWithEditType
{
    if (self = [super init])
    {
        type = 3;
    }
    
    return self;
}

-(void) reset:(UIButton *) sender
{
    self.isShowLoading = YES;
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:smartUp.tid forKey:@"tId"];
    [params setObject:@"1" forKey:@"reset"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SOCKET_Reset)
                                      delegate:self
                                  withUserInfo:dic];
}

-(NSString *) numberToWeek:(int) i
{
    switch (i)
    {
        case 1:
            return @"Mon";
        case 2:
            return @"Tue";
        case 3:
            return @"Wed";
        case 4:
            return @"Thu";
        case 5:
            return @"Fri";
        case 6:
            return @"Sat";
        case 7:
            return @"Sun";
        default:
            break;
    }
    return @"";
}



-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    [self headerFinish];
    //Mannual Timer查询
    if ([u rangeOfString:URL_FOR_SOCKET_PlUG_CONTROL].location != NSNotFound)
    {
        if (type == 0 || type == 1)
        {
            self.plug = [PlugEntity getPlug:jsonString];
            [self.tableView reloadData];
            
            if (plug.surplusMinutes.intValue == 0)
            {
                if (self.timer != nil)
                {
                    [self.timer invalidate];
                    self.timer = nil;
                    
                    isTimerStart = NO;
                }
            }
            else
            {
                if (timer == nil)
                {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(refresh) userInfo:nil repeats:YES];
                    
                    isTimerStart = YES;
                }
            }
            
            if (self.plug.surplusMinutes.intValue == 0 && self.plug.timerSet.intValue == 0)
            {
                self.selectedTime = @"5";
            }
        }
        else if(type == 3)
        {
            self.plug = [PlugEntity getPlug:jsonString];
            [self.tableView reloadData];
        }
    }
    //自动查询
    else if ([u rangeOfString:URL_FOR_FIND_SOCKET_AUTO].location != NSNotFound)
    {
        NSMutableArray *tempArray = [ScheduleEntity getSchedules:jsonString];
        if (tempArray.count > 0)
        {
            self.datas = tempArray;
        }
        [self.tableView reloadData];
    }
    //重置
    else if ([u rangeOfString:URL_FOR_SOCKET_Reset].location != NSNotFound)
    {

    }
    //开关插座
    else if ([u rangeOfString:URL_FOR_SMARTUP_PlUG_CONTROL].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            plug.switchStatus = [NSString stringWithFormat:@"%d",!plug.switchStatus.boolValue];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
            [self.tableView reloadData];
        }
    }
    //定时切换
    else if([u rangeOfString:URL_FOR_SOCKET_TIMER_CONTROL].location != NSNotFound)
    {
        NSString *action = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"action"];
        if ([@"OK" isEqualToString:jsonString])
        {
            //停止定时器
            if (action.intValue == 0)
            {
                plug.timerSet = @"0";
                plug.surplusMinutes = @"0";
                
                if (timer != nil)
                {
                    [timer invalidate];
                    self.timer = nil;
                    
                    isTimerStart = NO;
                }
            }
            else
            {
                plug.timerSet = selectedTime;
                plug.surplusMinutes = selectedTime;
                
                if (timer != nil)
                {
                    [timer invalidate];
                    self.timer = nil;
                }
                self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(refresh) userInfo:nil repeats:YES];
                isTimerStart = YES;
            }
            
            [self.tableView reloadData];
        }
    }
    //自动开关
    else if ([u rangeOfString:URL_FOR_SAVE_SOCKET_AUTO].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            NSString *autoMode = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"autoMode"];
            for (int i = 0; i < self.datas.count; i++)
            {
                ScheduleEntity *schedule = [self.datas safeObjectAtIndex:i];
                if ([schedule isKindOfClass:[ScheduleEntity class]])
                {
                    schedule.autoMode = autoMode;
                }
            }
            [self.tableView reloadData];
        }
    }
    else if([u rangeOfString:URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            [self.datas safeRemovetAtIndex:currentSelectedIndex];
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
            [self.tableView reloadData];
        }
    }
    else if([u rangeOfString:URL_FOR_SOCKET_SAVEPLUG].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            NSDictionary *dic = [userInfo objectForKey:REQUET_PARAMS];
            
            NSString *aliasName = [dic objectForKey:@"aliasName"];
            NSString *locationId = [dic objectForKey:@"locationId"];
            NSString *locationName = [dic objectForKey:@"locationName"];
            NSString *current = [dic objectForKey:@"maximalCurrent"];
            
            self.plug.locationId = locationId;
            self.plug.aliasName = aliasName;
            self.plug.locationName = locationName;
            self.plug.maximalCurrent = current;
            
            [self.tableView reloadData];
        }
    }
    else if([u rangeOfString:URL_FOR_SOCKET_Reset].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/hh"];
            NSString *dateS = [formatter stringFromDate:[NSDate date]];
            self.plug.startTime = dateS;
            [self.tableView reloadData];
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_SOCKET_PlUG_CONTROL].location != NSNotFound)
    {
        
    }
    else if ([u rangeOfString:URL_FOR_FIND_SOCKET_AUTO].location != NSNotFound)
    {
        [self.tableView reloadData];
    }
    else if ([u rangeOfString:URL_FOR_SOCKET_Reset].location != NSNotFound)
    {
        
    }
}


-(void) deleteScheduleWithString:(NSString *) string
{
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    [params safeSetObject:@"deleteSchedule" forKey:@"action"];
    [params safeSetObject:string forKey:@"scheduleId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE)
                                      delegate:self
                                  withUserInfo:dic];
}


//auto开关是否开启
-(void) autoSwitchChange:(UISwitch *) sender
{
    if (self.datas.count == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"Please add schedule!"];
        [sender setOn:NO];
        
        return;
    }
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:smartUp.tid forKey:@"tId"];
    
    if (sender.on)
    {
        [params setObject:@"0" forKey:@"autoMode"];
    }
    else
    {
        [params setObject:@"1" forKey:@"autoMode"];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SAVE_SOCKET_AUTO)
                                      delegate:self
                                  withUserInfo:dic];
}


//插座开关
-(void) switchChange:(UISwitch *) sender
{
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:smartUp.tid forKey:@"tId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SMARTUP_PlUG_CONTROL)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) refresh
{
    if (type != 0 && type != 1)
    {
        return;
    }
    self.isShowLoading = YES;
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:smartUp.tid forKey:@"tId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SOCKET_PlUG_CONTROL)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) sendGetDatas
{
    if (type == 0 || type == 1 || type == 3)
    {
        self.isShowLoading = YES;
        
        SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
        SmartUp *smartUp = [vc getCurrentSmartup];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
        [params setObject:smartUp.tid forKey:@"tId"];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
        
        [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SOCKET_PlUG_CONTROL)
                                          delegate:self
                                      withUserInfo:dic];
    }
    else if (type == 2)
    {
        self.isShowLoading = YES;
        
        SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
        SmartUp *smartUp = [vc getCurrentSmartup];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
        [params setObject:smartUp.tid forKey:@"tId"];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
        
        [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_FIND_SOCKET_AUTO)
                                          delegate:self
                                      withUserInfo:dic];
    }
}


-(void) startTimer
{
    if (selectedTime.intValue == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"Please set timer"];
        return;
    }
    self.isShowLoading = YES;
    [self.tableView reloadData];
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    [params safeSetObject:selectedTime forKey:@"timerSet"];
    
    if (plug.timerSet.intValue == 0)
    {
        [params safeSetObject:@"1" forKey:@"action"];
    }
    else
    {
        [params safeSetObject:@"0" forKey:@"action"];
    }
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SOCKET_TIMER_CONTROL)
                                      delegate:self
                                  withUserInfo:dic];
}




-(void) addScheduleAction:(UIButton *) sender
{
    if (self.datas.count == 7)
    {
        [SVProgressHUD showErrorWithStatus:@"You can only create up to 7 schedules"];
        return;
    }
    
    ScheduleViewController *schedule = [[ScheduleViewController alloc] init];
    [self.navigationController pushViewController:schedule animated:YES];
}

-(void) refreshLocation:(NSDictionary *)dic
{
    self.plug.locationName = [dic objectForKey:@"locationName"];
    self.plug.locationId = [dic objectForKey:@"locationId"];
    [self.tableView reloadData];
}

-(void) locationDidSelect:(NSDictionary *) dic
{
    //self.plug.locationName = [dic objectForKey:@"locationName"];
    [self resetLocation:[dic objectForKey:@"locationId"] andName:[dic objectForKey:@"locationName"]];
}

-(void) refreshLocalList:(NSMutableArray *)list
{
    self.plug.locationList = [NSMutableArray arrayWithArray:list];
}

-(void) resetName:(NSString *) name
{
    self.isShowLoading = YES;
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    [params safeSetObject:name forKey:@"aliasName"];
    [params safeSetObject:plug.locationId forKey:@"locationId"];
    [params safeSetObject:plug.maximalCurrent forKey:@"maximalCurrent"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SOCKET_SAVEPLUG)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) resetLocation:(NSString *) locationId andName:(NSString *) name
{
    self.isShowLoading = YES;
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    
    [params safeSetObject:plug.aliasName forKey:@"aliasName"];
    
    [params safeSetObject:name forKey:@"locationName"];
    [params safeSetObject:locationId forKey:@"locationId"];
    [params safeSetObject:plug.maximalCurrent forKey:@"maximalCurrent"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SOCKET_SAVEPLUG)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) resetCurrent:(NSString *) current
{
    self.isShowLoading = YES;
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    
    [params safeSetObject:plug.aliasName forKey:@"aliasName"];
    [params safeSetObject:plug.locationId forKey:@"locationId"];
    [params safeSetObject:current forKey:@"maximalCurrent"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SOCKET_SAVEPLUG)
                                      delegate:self
                                  withUserInfo:dic];
}




-(BOOL) isJingZhuang
{
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    //精装插座
    if ([smartUp.tid hasPrefix:@"02-00-"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}



-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == 2 && indexPath.section == 1)
    {
        ScheduleEntity *schedule = (ScheduleEntity *)[self.datas safeObjectAtIndex:indexPath.row];
        if (![schedule isKindOfClass:[ScheduleEntity class]])
        {
            return NO;
        }
        return YES;
    }
    else
    {
        return NO;
    }
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        currentSelectedIndex = alertView.tag;
        
        ScheduleEntity *schedule = (ScheduleEntity *)[self.datas safeObjectAtIndex:alertView.tag];
        [self deleteScheduleWithString:schedule.scheduleId];
    }
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Are you sure to delete the schedule??"
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO"
                              , nil];
    alertView.tag = indexPath.row;
    [alertView show];
}



-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d",(row + 1)];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedTime = [NSString stringWithFormat:@"%d",(row + 1)];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell isKindOfClass:[CommonCell class]])
    {
        CommonCell *cell1 = (CommonCell *)cell;
        cell1.tf.text = [NSString stringWithFormat:@"%d",(row + 1)];
    }
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (type == 1)
    {
        if (pickerView == nil)
        {
            pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 150.0, 320.0, 216.0)];
            pickerView.dataSource = self;
            pickerView.delegate = self;
            pickerView.showsSelectionIndicator = YES;
        }
        
        textField.inputView = pickerView;
        
        if (self.plug.timerSet.intValue == 0)
        {
            [pickerView selectRow:textField.text.intValue - 1 inComponent:0 animated:YES];
        }
        else
        {
            textField.text = self.plug.timerSet;
            [pickerView selectRow:self.plug.timerSet.intValue - 1 inComponent:0 animated:YES];
        }
    }
    
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == -1)
    {
        return YES;
    }
    return NO;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == -1)
    {
        if ([textField.text isBlank])
        {
            [SVProgressHUD showErrorWithStatus:@"Please Input Name"];
            return;
        }
        if (![plug.aliasName isEqualToString:textField.text])
        {
            [self resetName:textField.text];
        }
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}





-(void) toolbarClick:(id) sender
{
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    [self chooseType:item.tag];
}

-(void) chooseType:(int)t
{
    type = t;
    
    if (type == 0)
    {
        self.navigationItem.title = @"Mannual";
    }
    else if(type == 1)
    {
        self.navigationItem.title = @"Timer";
    }
    else if (type == 2)
    {
        self.navigationItem.title = @"Auto";
        if (self.datas == nil)
        {
            self.datas = [NSMutableArray arrayWithCapacity:0];
            //[self.datas addObject:@""];
        }
    }
    else if(type == 3)
    {
        self.navigationItem.title = @"Edit";
    }
    [self.tableView reloadData];
    [self sendGetDatas];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (type == 1)
    {
        if (indexPath.section == 1 && indexPath.row == 0)
        {            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (plug.timerSet.intValue == 0)
            {
                cell.textLabel.text = @"Start Timer";
            }
            else
            {
                cell.textLabel.text = @"Stop Timer";
            }
            
            [self startTimer];
        }
    }
    else if (type == 2)
    {
        if(indexPath.section == 1)
        {
            id object = [self.datas safeObjectAtIndex:indexPath.row];
            if ([object isKindOfClass:[ScheduleEntity class]])
            {
                ScheduleViewController *schedule = [[ScheduleViewController alloc] initWithSchedule:object];
                [self.navigationController pushViewController:schedule animated:YES];
            }
        }
    }
    else if(type == 3)
    {
        if(indexPath.section == 1 && indexPath.row == 1)
        {
            SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
            SmartUp *smartUp = [vc getCurrentSmartup];
            if (smartUp.rfStatus.intValue == -1)
            {
                return;
            }
            
            
            CurrentChooseViewController *current = [[CurrentChooseViewController alloc] initWithIndex:self.plug.maximalCurrent.intValue];
            current.parentVC = self;
            [self presentPopupViewController:current animationType:MJPopupViewAnimationFade
                                   dismissed:^{
                                       
                                   }];
        }
        else if (indexPath.section == 1 && indexPath.row == 0)
        {
            LocationViewController *locationVc = [[LocationViewController alloc] initWithLocalList:self.plug.locationList];
            
            locationVc.delegate = self;
            [self.navigationController pushViewController:locationVc animated:YES];
        }
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if(type == 1)
        {
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 250, 40)];
            
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.numberOfLines = 4;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = @"When the timer is up,the smart plug will switch off automatically";
            
            [tempView addSubview:label];
            
            return tempView;
        }
        else
        {
            return nil;
        }
    }
    else if (section == 1)
    {
        if(type == 2 && self.datas.count > 0)
        {
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 250, 30)];
            
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            label.numberOfLines = 4;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = @"Schedule";
            
            [tempView addSubview:label];
            
            return tempView;
        }
        else if(type == 3)
        {
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 250, 30)];
            
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            label.numberOfLines = 4;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = @"Setting";
            
            [tempView addSubview:label];
            
            return tempView;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        if (type == 3)
        {
            if ([self isJingZhuang])
            {
                UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 250, 30)];
                
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont boldSystemFontOfSize:14.0f];
                label.numberOfLines = 4;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.text = @"Energy meter last reset";
                
                [tempView addSubview:label];
                
                return tempView;
            }
            else
            {
                return nil;
            }
        }
        else
        {
            return nil;
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (type == 1)
        {
            return 55;
        }
        else
        {
            return 0;
        }
    }
    if (section == 1)
    {
        if (type == 2 && self.datas.count > 0)
        {
            return 40;
        }
        else if (type == 3)
        {
            return 40;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        if (type == 3)
        {
            return 40;
        }
        else
        {
            return 0;
        }
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger) section
{
    if (type == 0)
    {
        if ([self isJingZhuang] && section == 0)
        {
            return nil;
        }
        
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        UISwitch *temp1 = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        
        [temp1 addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
        [tempView addSubview:temp1];
        temp1.center = CGPointMake(160, 25);

        
        //如果插座是关闭状态
        if (plug.switchStatus.intValue == 1)
        {
            [temp1 setOn:YES];
            
            if (plug.timerSet.intValue != 0)
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 20)];
                
                label.text = [NSString stringWithFormat:@"Timer is on… %@ minutes left",plug.surplusMinutes];
                label.textColor = [UIColor redColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont boldSystemFontOfSize:16.0f];
                [tempView addSubview:label];
            }
        }
        else
        {
            [temp1 setOn:NO];
        }
        
        return tempView;
    }
    else if(type == 1)
    {
        if (plug.timerSet.intValue != 0 && section == 1)
        {
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 20)];
            
            label.text = [NSString stringWithFormat:@"Timer is on… %@ minutes left",plug.surplusMinutes];
            label.textColor = [UIColor redColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:16.0f];
            [tempView addSubview:label];
            
            return label;
        }
        return nil;
    }
    else
    {
        return nil;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (type == 0)
    {
        if ([self isJingZhuang] && section == 0)
        {
            return 0;
        }
        return 65;
    }
    else if (type == 1)
    {
        if (plug.surplusMinutes.intValue != 0 && section == 1)
        {
            return 65;
        }
        return 0;
    }
    else
    {
        return 0;
    }
}

-(NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    //mannual
    if (type == 0)
    {
        if (section == 1)
        {
            return 2;
        }
        else
        {
            return 1;
        }
    }
    else if(type == 1)
    {
        return 1;
    }
    else if(type == 2)
    {
        if (section == 1)
        {
            return self.datas.count;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        if (section == 1)
        {
            return 2;
        }
        else
        {
            return 1;
        }
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (type == 0)
    {
        if (self.plug == nil)
        {
            return 1;
        }
        else
        {            
            //精装插座
            if ([self isJingZhuang])
            {
                return 2;
            }
            else
            {
                return 1;
            }
        }
    }
    else if(type == 1)
    {
        return 2;
    }
    else if(type == 2)
    {
        return 3;
    }
    else
    {
        //精装插座
        if ([self isJingZhuang])
        {
            return 3;
        }
        else
        {
            return 2;
        }
    }
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == 0)
    {
        static NSString *identifier = @"cell";
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        if (indexPath.section == 0)
        {
            cell.textLabel.text = @"Power in use";
            if (self.plug == nil)
            {
                cell.detailTextLabel.text = @"";
            }
            else
            {
                cell.detailTextLabel.text = self.plug.realPower;
            }
            
        }
        else if(indexPath.section == 1)
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = @"Total energy consumed";
                cell.detailTextLabel.text = @"";
                
            }
            else
            {
                if (self.plug == nil)
                {
                    cell.textLabel.text = @"Since 00/00/0000";
                    cell.detailTextLabel.text = @"0W";
                }
                else
                {
                    cell.textLabel.text = [NSString stringWithFormat:@"Since %@",self.plug.startTime];
                    cell.detailTextLabel.text = self.plug.totalPower;
                }
            }
        }
        
        return cell;
    }
    else if(type == 1)
    {
        if (indexPath.section == 0)
        {
            CommonCell *commonCell = [[[NSBundle mainBundle] loadNibNamed:@"CommonCell" owner:self options:nil] objectAtIndex:0];
            
            commonCell.userLabel.text = @"Set Timer";
            
            if (self.plug.surplusMinutes.intValue == 0)
            {
                commonCell.tf.text = self.selectedTime;
            }
            else
            {
                commonCell.tf.text = self.plug.surplusMinutes;
            }

            
            commonCell.tf.delegate = self;
            
            if (self.plug.surplusMinutes.intValue == 0)
            {
                commonCell.userInteractionEnabled = YES;
                commonCell.backgroundColor = [UIColor clearColor];
            }
            else
            {
                commonCell.userInteractionEnabled = NO;
                commonCell.backgroundColor = [UIColor lightGrayColor];
            }
            
            return commonCell;
        }
        else
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            
            if (plug.surplusMinutes.intValue == 0)
            {
                cell.textLabel.text = @"Start Timer";
            }
            else
            {
                cell.textLabel.text = @"Stop Timer";
            }
            
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            
            return cell;
        }
    }
    else if (type == 2)
    {
        static NSString *identifier = @"cell2";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        if (indexPath.section == 0)
        {
            cell.textLabel.text = @"Auto mode";
            
            for (UIView *temp in cell.contentView.subviews)
            {
                [temp removeFromSuperview];
            }
            
            UISwitch *swi = [[UISwitch alloc] initWithFrame:CGRectMake(190, 10, 0, 40)];
            [swi addTarget:self action:@selector(autoSwitchChange:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:swi];
            
            id object = [self.datas safeObjectAtIndex:indexPath.row];
            if ([object isKindOfClass:[ScheduleEntity class]])
            {
                ScheduleEntity *temp = (ScheduleEntity *)object;
                //自动开关是否开启，1：开启 0：关闭
                if (temp.autoMode.intValue == 0)
                {
                    [swi setOn:YES];
                }
                else
                {
                    [swi setOn:NO];
                }
            }
        }
        else if(indexPath.section == 1)
        {
            NSMutableString *sb = [NSMutableString stringWithCapacity:0];
            
            id object = [self.datas safeObjectAtIndex:indexPath.row];
            if ([object isKindOfClass:[ScheduleEntity class]])
            {
                ScheduleEntity *temp = (ScheduleEntity *)object;
                int i = 0;
                for (NSNumber *week in temp.weekdays)
                {
                    if (i > 0)
                    {
                        [sb appendString:@","];
                    }
                    [sb appendFormat:@"%@",[self numberToWeek:week.intValue]];
                    i++;
                }
            }
            
            cell.textLabel.text = sb;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.section == 2)
        {
            ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:@"Add New Schedule" forState:UIControlStateNormal];
            [button setStyleType:ACPButtonOK];
            button.frame = CGRectMake(10, 0, 280, 44);
            [button addTarget:self action:@selector(addScheduleAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:button];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, cell.height)];
        }
        
        return cell;
    }
    else if (type == 3)
    {
        static NSString *identifier = @"cell2";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        if (indexPath.section == 0)
        {
            cell.textLabel.text = @"Name";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(135, 12, 150, 25)];
            
            tf.textAlignment = NSTextAlignmentRight;
            tf.tag = -1;
            tf.font = [UIFont systemFontOfSize:14.0f];
            tf.clearButtonMode = UITextFieldViewModeNever;
            tf.placeholder = @"Input Name";
            tf.delegate = self;
            tf.text = plug.aliasName;
            tf.returnKeyType = UIReturnKeyDone;
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:tf];
        }
        
        else if(indexPath.section == 1)
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = @"Location";
                if (self.plug.locationName == nil)
                {
                    cell.detailTextLabel.text = [self locationIdToString:self.plug.locationId];
                }
                else
                {
                    cell.detailTextLabel.text = self.plug.locationName;
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.textLabel.text = @"Maximal current";
                cell.detailTextLabel.text = plug.maximalCurrent;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        else if(indexPath.section == 2)
        {
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"yyyy/MM/hh"];
//            NSString *dateS = [formatter stringFromDate:[NSDate date]];
            cell.textLabel.text = self.plug.startTime;
            
            for (UIView *tempView in cell.contentView.subviews)
            {
                [tempView removeFromSuperview];
            }
            
            ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:@"Reset" forState:UIControlStateNormal];
            button.frame = CGRectMake(200, 5, 70, 35);
            [button setStyleType:ACPButtonOK];
            [button addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
        
        }
        
        return cell;
    }
    return nil;
}

-(NSString *) locationIdToString:(NSString *) locationId
{
    for (int i = 0; i < self.plug.locationList.count; i++)
    {
        NSDictionary *tempDic = [self.plug.locationList objectAtIndex:i];
        
        NSString *tempId = [tempDic valueToStringForKey:@"locationId"];
        if (locationId.intValue == tempId.intValue)
        {
            return [tempDic objectForKey:@"locationName"];
        }
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    if (smartUp.rfStatus.intValue == -1)
    {
        UIToolbar *toolBar = (UIToolbar *)[self.view viewWithTag:110];
        for (UIBarButtonItem *item in toolBar.items)
        {
            if (item.tag != 3)
            {
                item.enabled = NO;
            }
        }
    }
    
    [self initHeaderView:self];
    
    [self sendGetDatas];
    
    self.selectedTime = @"5";
}

-(void) viewWillAppear:(BOOL)animated
{
    if (isTimerStart)
    {
        if (self.timer != nil)
        {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
