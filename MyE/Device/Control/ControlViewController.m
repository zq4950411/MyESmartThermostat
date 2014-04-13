//
//  ControlViewController.m
//  MyE
//
//  Created by space on 13-8-22.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "ControlViewController.h"
#import "SmartUpViewController.h"
#import "ControlScheduleViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "TimeChooseViewController.h"
#import "WenduViewController.h"


#import "NSString+Common.h"

#import "WeekCell.h"
#import "SequentialCell.h"

#import "SmartUp.h"
#import "MyEHouseData.h"
#import "ControlSchedule.h"

#import "Sequential.h"

#import "UIUtils.h"

#import "ACPButton.h"

@implementation ControlViewController

@synthesize seq;
@synthesize chooseVc;

-(id) initWithEditType
{
    if (self = [super init])
    {
        type = 3;
    }
    
    return self;
}

-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROL_MANUAL_VIEW].location != NSNotFound)
    {
        if ([jsonString rangeOfString:@"channels"].location != NSNotFound)
        {
            NSDictionary *dic = [jsonString JSONValue];
            NSString *string = [dic objectForKey:@"channels"];
            
            NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:string.length];
            
            for (int i = 0; i < string.length; i++)
            {
                [temp addObject:[NSString stringWithFormat:@"%c",[string characterAtIndex:i]]];
            }
            channels = temp;
            
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }

    else if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_MANUAL_SAVE].location != NSNotFound)
    {
        if([@"OK" isEqualToString:jsonString])
        {
            NSString *channelsString = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"channels"];
            NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:channelsString.length];
            
            for (int i = 0; i < channelsString.length; i++)
            {
                [temp addObject:[NSString stringWithFormat:@"%c",[channelsString characterAtIndex:i]]];
            }
            channels = temp;
            [self.tableView reloadData];
            
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
            [self.tableView reloadData];
        }
    }
    
    //进程列表
    else if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_AUTO_VIEW].location != NSNotFound)
    {
        NSArray *array = [jsonString JSONValue];
        if ([array isKindOfClass:[NSArray class]])
        {
            self.datas = [ControlSchedule getControlSchedules:jsonString];
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
            [self.tableView reloadData];
        }
    }
    
    //Sequential
    else if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_SEQUENTIAL_VIEW].location != NSNotFound)
    {
        NSDictionary *array = [jsonString JSONValue];
        if ([array isKindOfClass:[NSDictionary class]])
        {
            seq = [Sequential getSequential:jsonString];
            if (seq.sequentialOrder == nil)
            {
                seq.sequentialOrder = [NSMutableArray arrayWithCapacity:0];
            }
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
            [self.tableView reloadData];
        }
    }
    else if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_VIEW].location != NSNotFound)
    {
        NSDictionary *array = [jsonString JSONValue];
        if ([array isKindOfClass:[NSDictionary class]])
        {
            seq = [Sequential getSequential:jsonString];
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
            [self.tableView reloadData];
        }
    }
    else if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_SAVE].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            NSString *locationId = [[userInfo objectForKey:REQUET_PARAMS] valueToStringForKey:@"locationId"];
            NSString *name = [[userInfo objectForKey:REQUET_PARAMS] valueToStringForKey:@"name"];
            
            seq.locationId = locationId;
            seq.seqName = name;
            
            [self.tableView reloadData];
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }
    else if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_SAVE_PLUG_SCHEDULE].location != NSNotFound)
    {
        if([@"OK" isEqualToString:jsonString])
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
    else if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_SEQUENTIAL_Save].location != NSNotFound)
    {
        if([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_SOCKET_PlUG_CONTROL].location != NSNotFound)
    {
        
    }
}





-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == -1)
    {
        return YES;
    }
    return NO;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *) textField
{
    if (textField.tag != -1)
    {
        UIPickerView *pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 250, 320, 240)];
        
        pickView.showsSelectionIndicator = YES;
        pickView.dataSource = self;
        pickView.delegate = self;
        textField.inputView = pickView;
    }
    
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *) textField
{
    if (textField.tag == -1)
    {
        if ([textField.text isBlank])
        {
            [SVProgressHUD showErrorWithStatus:@"Please Input Name"];
            return;
        }
        if (![seq.seqName isEqualToString:textField.text])
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [params safeSetObject:seq.locationId forKey:@"locationId"];
            [params safeSetObject:textField.text forKey:@"name"];
            
            [self updateSeq:params];
        }
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}






-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 36;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d",row + 55];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    temperatureCell.tf.text = [NSString stringWithFormat:@"%dF",row + 55];
    seq.weather_temperature = [NSString stringWithFormat:@"%d",row + 55];
}










-(void) sendGetDatas
{
    if (type == 0)
    {
        self.isShowLoading = YES;
        
        SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
        SmartUp *smartUp = [vc getCurrentSmartup];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
        [params setObject:smartUp.tid forKey:@"tId"];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
        
        [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROL_MANUAL_VIEW)
                                          delegate:self
                                      withUserInfo:dic];
    }
    else if (type == 1)
    {
        self.isShowLoading = YES;
        
        SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
        SmartUp *smartUp = [vc getCurrentSmartup];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
        [params setObject:smartUp.tid forKey:@"tId"];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
        
        [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_AUTO_VIEW)
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
        
        [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SEQUENTIAL_VIEW)
                                          delegate:self
                                      withUserInfo:dic];
    }
    else if(type == 3)
    {
        self.isShowLoading = YES;
        
        SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
        SmartUp *smartUp = [vc getCurrentSmartup];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
        [params setObject:smartUp.tid forKey:@"tId"];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
        
        [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_VIEW)
                                          delegate:self
                                      withUserInfo:dic];
    }
}

-(void) valueChange:(UISwitch *) s
{
    self.isShowLoading = YES;
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableString *sb = [NSMutableString string];
    [sb appendString:@""];
    
    for (int i = 0; i < channels.count; i++)
    {
        if (i == s.tag)
        {
            [sb appendFormat:@"%d",s.isOn];
        }
        else
        {
            [sb appendFormat:@"%d",[[channels objectAtIndex:i] intValue]];
        }
    
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    [params safeSetObject:sb forKey:@"channels"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_MANUAL_SAVE)
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
    
    ControlScheduleViewController *temp = [[ControlScheduleViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}



-(IBAction) click:(UIBarButtonItem *) sender
{
    type = sender.tag;
    if (type == 0)
    {
        self.navigationItem.title = @"Mannual";
    }
    else if(type == 1)
    {
        self.navigationItem.title = @"Auto";
    }
    else if (type == 2)
    {
        self.navigationItem.title = @"Sequential";
    }
    else if(type == 3)
    {
        self.navigationItem.title = @"Edit";
    }
    
    [self.tableView reloadData];
    [self sendGetDatas];
    
}


-(void) addChannelAction:(UIButton *) sender
{
    self.chooseVc = [[ChooseChannelViewController alloc] init];
    self.chooseVc.index = -1;
    chooseVc.parentVC = self;
    [self presentPopupViewController:chooseVc animationType:MJPopupViewAnimationSlideBottomTop dismissed:^{
        
    }];
}

-(void) refreshWithChannel:(NSString *) string
{
    [self.seq.sequentialOrder addObject:[string JSONValue]];
    [self.tableView reloadData];
}

-(void) refreshWithChannel:(NSString *) string andIndex:(int) index
{
    [self.seq.sequentialOrder safeReplaceObjectAtIndex:index withObject:[string JSONValue]];
    [self.tableView reloadData];
}


-(void) saveAction:(UIButton *) sender
{
    if ([self getControlString] == nil)
    {
        return;
    }
    seq.repeatDays = [sequentialWeekCell getSelectedButtons];
    
    self.isShowLoading = YES;
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    [params safeSetObject:[self getControlString] forKey:@"control"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SEQUENTIAL_Save)
                                      delegate:self
                                  withUserInfo:dic];
}


-(NSString *) getControlString
{
//    “startTime”: 3:30,
//    “repeatDays”: [2,5,7],
//    “precondition”:3,
//    “weather_temperature”:70,
//    “sequentialOrder”:[
//    { “channel”:2,” duration”:4},
//    { “channel”:2,” duration”:4},
//                       ]}
    NSArray *selected = [sequentialWeekCell getSelectedButtons];
    if (selected.count == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the Day"];
        return nil;
    }
    NSMutableString *string = [NSMutableString string];
    
    [string appendString:@"{"];
    [string appendFormat:@"\"startTime\":\"%@\"",seq.startTime];
    [string appendString:@","];
    
    [string appendString:@"\"repeatDays\":["];
    for (int i = 0; i < selected.count;i++)
    {
        if (i > 0)
        {
            [string appendString:@","];
        }
        NSNumber *number = [selected objectAtIndex:i];
        [string appendString:[NSString stringWithFormat:@"%d",number.intValue]];
    }
    [string appendString:@"]"];
    [string appendString:@","];

    [string appendFormat:@"\"precondition\":%@",seq.precondition];
    [string appendString:@","];
    
    [string appendFormat:@"\"weather_temperature\":%@",seq.weather_temperature];
    [string appendString:@","];
    
    [string appendString:@"\"sequentialOrder\":["];
   
    for (int i = 0; i < seq.sequentialOrder.count;i++)
    {
        if (i > 0)
        {
            [string appendString:@","];
        }
        
        NSDictionary *dic = (NSDictionary *)[seq.sequentialOrder objectAtIndex:i];
        
        int channel = [[dic objectForKey:@"channel"] intValue];
        int duration = [[dic objectForKey:@"duration"] intValue];
        
        NSString *jsonString = [NSString stringWithFormat:@"{\"channel\":%d,\"duration\":%d}",channel,duration];
        [string appendString:jsonString];
    }
    
    [string appendString:@"]"];
    [string appendString:@"}"];
    
    return string;
}

//保存信息
-(void) updateSeq:(NSMutableDictionary *) params
{
    self.isShowLoading = YES;
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:smartUp.tid forKey:@"tId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SAVE)
                                      delegate:self
                                  withUserInfo:dic];
}


#pragma mark 房间选择
-(void) locationDidSelect:(NSDictionary *) dic
{
    isNeedRefresh = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *locationId = [dic valueToStringForKey:@"locationId"];
    [params safeSetObject:locationId forKey:@"locationId"];
    [params safeSetObject:seq.seqName forKey:@"name"];
    
    [self updateSeq:params];
}

-(void) refreshLocalList:(NSMutableArray *)list
{
    self.seq.locationList = [NSMutableArray arrayWithArray:list];
}






-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2 && indexPath.section == 0)
    {
        WenduViewController *timeVC = [[WenduViewController alloc] initWithNibName:@"WenduViewController" bundle:nil];
        timeVC.parentVC = self;
        [self presentPopupViewController:timeVC
                           animationType:MJPopupViewAnimationFade
                               dismissed:^{
                                   [self.tableView reloadData];
                               }];
    }
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(type == 1)
    {
        if (indexPath.section == 0)
        {
            id object = [self.datas safeObjectAtIndex:indexPath.row];
            if ([object isKindOfClass:[ControlSchedule class]])
            {
                ControlScheduleViewController *schedule = [[ControlScheduleViewController alloc] initWithSchedule:object];
                [self.navigationController pushViewController:schedule animated:YES];
            }
        }
    }
    
    if (type == 2)
    {
        if (indexPath.row == 0 && indexPath.section == 0)
        {
            TimeChooseViewController *timeVC = [[TimeChooseViewController alloc] initWithNibName:@"TimeChooseViewController" bundle:nil];
            timeVC.parentVC = self;
            [self presentPopupViewController:timeVC
                               animationType:MJPopupViewAnimationFade
                                   dismissed:^{
                                       [self.tableView reloadData];
                                   }];
        }
        else if(indexPath.section == 1)
        {
            self.chooseVc = [[ChooseChannelViewController alloc] initWithValue:[self.seq.sequentialOrder safeObjectAtIndex:indexPath.row] andIndex:indexPath.row];
            
            chooseVc.parentVC = self;
            [self presentPopupViewController:chooseVc animationType:MJPopupViewAnimationSlideBottomTop dismissed:^{
                
            }];
        }
    }
    if (type == 3)
    {
        if (indexPath.row == 1)
        {
            LocationViewController *locationVc = [[LocationViewController alloc] initWithLocalList:self.seq.locationList];
            
            locationVc.delegate = self;
            [self.navigationController pushViewController:locationVc animated:YES];
        }
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (type == 0)
    {
        return 0;
    }
    else if(type == 1)
    {
        return 0;
    }
    else if(type == 2)
    {
        if (section == 0)
        {
            return 30;
        }
        else if(section == 1)
        {
            if (seq.sequentialOrder.count > 0)
            {
                return 30;
            }
            else
            {
                return 0;
            }
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
    return 0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (type == 0)
    {
        return nil;
    }
    else if(type == 1)
    {
        return nil;
    }
    else if(type == 2)
    {
        if (section == 0)
        {
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 250, 30)];
            
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            label.numberOfLines = 4;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = @"Start condition";
            
            [tempView addSubview:label];
            
            return tempView;
        }
        else if (section == 1)
        {
            if (seq.sequentialOrder.count > 0)
            {
                UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250, 30)];
                
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont boldSystemFontOfSize:14.0f];
                label.numberOfLines = 4;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.text = @"Sequential order";
                
                [tempView addSubview:label];
                
                return tempView;
            }
            
            return nil;
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
    return nil;
}










-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (type == 0)
    {
        return 1;
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
        return 1;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (type == 0)
    {
        return channels.count;
    }
    else if(type == 1)
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
    else if(type == 2)
    {
        if (section == 0)
        {
            return 3;
        }
        else if(section == 1)
        {
            return seq.sequentialOrder.count;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 2;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == 2)
    {
        if (indexPath.row == 2 && indexPath.section == 0)
        {
            if (seq.precondition.integerValue == 5 || seq.precondition.integerValue == 6)
            {
                return 80;
            }
        }
        else if(indexPath.row == 1 && indexPath.section == 0)
        {
            return 72;
        }
        return 44;
    }
    else
    {
        return 44;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == 0)
    {
        static NSString *identifier = @"cell00";
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.textLabel.text = [NSString stringWithFormat:@"channel%d",(indexPath.row + 1)];
            
        UISwitch *swi = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 0, 40)];
    
        [swi addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventTouchUpInside];
        swi.tag = indexPath.row;
        [swi setOn:[[channels safeObjectAtIndex:indexPath.row] boolValue]];
        
        [cell.contentView addSubview:swi];
        
        return cell;
    }
    else if(type == 1)
    {
        static NSString *identifier = @"cell10";
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        if (indexPath.section == 0)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            
            ControlSchedule *schedule = [self.datas safeObjectAtIndex:indexPath.row];
            
            cell.textLabel.text = [schedule getChannelString];
            cell.detailTextLabel.text = [schedule getWeekString];
        }
        else
        {
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:@"Add New Schedule" forState:UIControlStateNormal];
            [button setStyleType:ACPButtonOK];
            button.frame = CGRectMake(10, 0, 280, 44);
            [button addTarget:self action:@selector(addScheduleAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:button];
        }
        
        return cell;
    }
    else if(type == 2)
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                static NSString *identifier = @"cell20";    
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"Time";
                cell.detailTextLabel.text = seq.startTime;
                
                return cell;
            }
            else if(indexPath.row == 1)
            {
                if (sequentialWeekCell == nil)
                {
                    sequentialWeekCell = [[[NSBundle mainBundle] loadNibNamed:@"WeekCell" owner:self options:nil] objectAtIndex:1];
                }
                sequentialWeekCell.object = seq.repeatDays;
                
                return sequentialWeekCell;
            }
            else if(indexPath.row == 2)
            {  
//                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
//                
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                cell.textLabel.text = @"Wheather";
//                cell.detailTextLabel.text = [seq.precondition conditiontoString:seq.precondition.integerValue];
                
                if (temperatureCell == nil)
                {
                    temperatureCell = [[[NSBundle mainBundle] loadNibNamed:@"Temperature" owner:self options:nil] objectAtIndex:0];
                }
                temperatureCell.dateLabel.text = [seq.precondition conditiontoString:seq.precondition.integerValue];
                
                temperatureCell.tf.delegate = self;
                
                if (seq.weather_temperature == nil)
                {
                    seq.weather_temperature = @"0";
                }
                temperatureCell.tf.text = seq.weather_temperature;
                
                return temperatureCell;
            }
        }
        else if(indexPath.section == 1)
        {
            static NSString *identifier = @"cell210";    
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            
            NSDictionary *temp = [seq.sequentialOrder objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [NSString stringWithFormat:@"#%d",indexPath.row];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Channel%@",[temp valueToStringForKey:@"channel"]];
            
            return cell;
        }
        else
        {
            static NSString *identifier = @"cell211";    
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            
            ACPButton *button1 = [ACPButton buttonWithType:UIButtonTypeCustom];
            
            [button1 setTitle:@"Add Channel" forState:UIControlStateNormal];
            button1.frame = CGRectMake(35, 0, 100, 35);
            [button1 setStyleType:ACPButtonOK];
            [cell.contentView addSubview:button1];
            [button1 addTarget:self action:@selector(addChannelAction:) forControlEvents:UIControlEventTouchUpInside];
            
            ACPButton *button2 = [ACPButton buttonWithType:UIButtonTypeCustom];
            [button2 setTitle:@"Save" forState:UIControlStateNormal];
            button2.frame = CGRectMake(150, 0, 100, 35);
            [button2 setStyleType:ACPButtonOK];
            [cell.contentView addSubview:button2];
            [button2 addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }
    else
    {
        static NSString *identifier = @"cell3";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
      
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Name";
            
            UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(135, 12, 150, 25)];
            
            tf.textAlignment = NSTextAlignmentRight;
            tf.tag = -1;
            tf.font = [UIFont systemFontOfSize:14.0f];
            tf.clearButtonMode = UITextFieldViewModeNever;
            tf.placeholder = @"Input Name";
            tf.delegate = self;
            tf.text = seq.seqName;
            
            [cell addSubview:tf];
        }
        else
        {
            cell.textLabel.text = @"Location";
            cell.detailTextLabel.text = [self locationIdToString:seq.locationId];
        }
        
        return cell;
    }
    return nil;
}


-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == 1 && indexPath.section == 0)
    {
        ControlSchedule *schedule = (ControlSchedule *)[self.datas safeObjectAtIndex:indexPath.row];
        if (![schedule isKindOfClass:[ControlSchedule class]])
        {
            return NO;
        }
        return YES;
    }
    else if(type == 2 && indexPath.section == 1)
    {
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
        
        ControlSchedule *schedule = (ControlSchedule *)[self.datas safeObjectAtIndex:alertView.tag];
        [self deleteScheduleWithString:schedule.scheduleId];
    }
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == 2)
    {
        [seq.sequentialOrder safeRemovetAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Are you sure to delete the schedule?"
                                                           delegate:self
                                                  cancelButtonTitle:@"YES"
                                                  otherButtonTitles:@"NO"
                                  , nil];
        alertView.tag = indexPath.row;
        [alertView show];
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
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SAVE_PLUG_SCHEDULE)
                                      delegate:self
                                  withUserInfo:dic];
}
















-(NSString *) locationIdToString:(NSString *) locationId
{
    for (int i = 0; i < self.seq.locationList.count; i++)
    {
        NSDictionary *tempDic = [self.seq.locationList objectAtIndex:i];
        
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
    
    isNeedRefresh = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
