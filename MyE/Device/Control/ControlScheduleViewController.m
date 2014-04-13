//
//  ControlScheduleViewController.m
//  MyE
//
//  Created by space on 13-8-26.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "ControlScheduleViewController.h"
#import "SmartUpViewController.h"
#import "ControlViewController.h"

#import "CommonCell.h"
#import "WeekCell.h"

#import "TwoDatePicker.h"

#import "SmartUp.h"
#import "UIUtils.h"
#import "MyEHouseData.h"
#import "ScheduleEntity.h"

#import "NSString+Common.h"

#import "UIUtils.h"


@implementation ControlScheduleViewController

@synthesize weekCell;
@synthesize channelCell;

@synthesize twoDatePickerView;
@synthesize schedule;



-(id) initWithSchedule:(ControlSchedule *) s
{
    if (self = [super init])
    {
        self.schedule = s;
    }
    return self;
}


-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_SAVE_PLUG_SCHEDULE].location != NSNotFound)
    {
        if ([jsonString isKindOfClass:[NSString class]])
        {
            if ([jsonString isEqualToString:@"OK"])
            {
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"Fail"];
            }
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_UNIVERSAL_CONTROLLER_SAVE_PLUG_SCHEDULE].location != NSNotFound)
    {
        
    }
}

-(int) timeToInt:(NSString *) time
{
    NSArray *temps = [time componentsSeparatedByString:@":"];
    if (temps.count != 2)
    {
        return 0;
    }
    else
    {
        int i1 = [[temps objectAtIndex:0] intValue];
        int i2 = [[temps objectAtIndex:1] intValue];
        
        int total = 0;
        total = i1 * 2 + (i2 / 30);
        
        return total;
    }
}

-(NSString *) intToString:(int) i
{
    int hour = i / 2;
    int min = (i % 2) * 30;
    if (i == 48)
    {
        return [NSString stringWithFormat:@"%@",@"00:00"];
    }
    else
    {
        return [NSString stringWithFormat:@"%02d:%02d",hour,min];
    }
}


-(BOOL) isTimeValid:(NSMutableArray *) array stid:(NSString *) string1 andEtid:(NSString *) sting2
{
    int count = 0;
    
    for (NSDictionary *tempDic in array)
    {
        int stid = [[tempDic objectForKey:@"stid"] intValue];
        int etid = [[tempDic objectForKey:@"etid"] intValue];
        
        if ((stid == string1.intValue) && (etid == sting2.intValue))
        {
            count++;
            
            if (count > 1)
            {
                return NO;
            }
            else
            {
                continue;
            }
        }
        
        if ((string1.intValue >= stid && string1.intValue <= etid) || (sting2.intValue >= stid && sting2.intValue <= etid))
        {
            return NO;
        }
    }
    
    return YES;
}

-(void) save
{
    NSString *channelsString = [self.channelCell getSelectedButtons];
    if ([channelsString isBlank] || [channelsString isEqualToString:@"000000"])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the channel days to be applied to"];
        return;
    }
    
    NSMutableArray *selectedButtons = [weekCell getSelectedButtons];
    if (selectedButtons.count == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the week days to be applied to"];
        return;
    }
    
    NSMutableArray *rules = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < self.datas.count; i++)
    {
        
        NSString *string = [self.datas objectAtIndex:i];
        if ([string isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = (NSDictionary *)string;
            
            NSString *sid = [dic valueToStringForKey:@"stid"];
            NSString *etid = [dic valueToStringForKey:@"etid"];
            
            if (sid.intValue >= etid.intValue)
            {
                [SVProgressHUD showErrorWithStatus:@"The start time must not be later than the end time"];
                return;
            }

            if (sid == nil && [sid isBlank])
            {
                [SVProgressHUD showErrorWithStatus:@"Please specify the time"];
                return;
            }
            if (etid == nil && [etid isBlank])
            {
                [SVProgressHUD showErrorWithStatus:@"Please specify the time"];
                return;
            }
            
            [rules addObject:dic];
        }
        else
        {
            NSArray *array = [string componentsSeparatedByString:@"-"];
            if (array.count != 2)
            {
                [SVProgressHUD showErrorWithStatus:@"Please specify the time"];
                return;
            }
            else
            {
                NSString *sid = [array objectAtIndex:0];
                NSString *etid = [array objectAtIndex:1];
                
                if ([sid compare:etid] == NSOrderedDescending || [sid compare:etid] == NSOrderedSame)
                {
                    [SVProgressHUD showErrorWithStatus:@"The start time must not be later than the end time"];
                    return;
                }
                
                NSNumber *i1 = [NSNumber numberWithInt:[self timeToInt:sid]];
                NSNumber *i2 = [NSNumber numberWithInt:[self timeToInt:etid]];
                
                
                [rules addObject:[NSDictionary dictionaryWithObjectsAndKeys:i1,@"stid",i2,@"etid", nil]];
            }
        }
    }
    
    for (NSDictionary *dic in rules)
    {
        NSString *string1 = [dic objectForKey:@"stid"];
        NSString *string2 = [dic objectForKey:@"etid"];
        
        if (![self isTimeValid:rules stid:string1 andEtid:string2])
        {
            [SVProgressHUD showErrorWithStatus:@"Periods overlapped. Please make adjustment accordingly."];
            return;
        }
    }
    
    
    self.isShowLoading = YES;
    
    //    “schedules”:{
    //        periods":[
    //        {"stid":14, "etid":16 },
    //        {"stid":21, "etid":28 },
    //        {"stid":31, "etid":38 },
    //		],
    //        “weekDays”:[1,2],
    //    }
    NSMutableString *sb = [NSMutableString string];
    
    [sb appendString:@"{"];
    [sb appendFormat:@"\"channels\":\"%@\"",channelsString];
    [sb appendString:@","];
    [sb appendString:@"\"periods\":["];
    
    for (int i = 0; i < self.datas.count; i++)
    {
        if (i > 0)
        {
            [sb appendString:@","];
        }
        
        int stid = 0;
        int etid = 0;
        
        NSString *string = [self.datas objectAtIndex:i];
        if ([string isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = (NSDictionary *)string;
            
            stid = [[dic valueToStringForKey:@"stid"] intValue];
            etid = [[dic valueToStringForKey:@"etid"] intValue];
        }
        else
        {
            NSArray *array = [string componentsSeparatedByString:@"-"];
            if (array.count != 2)
            {
                continue;
            }
            
            stid = [self timeToInt:[array objectAtIndex:0]];
            etid = [self timeToInt:[array objectAtIndex:1]];
        }
        
        [sb appendString:@"{"];
        [sb appendFormat:@"\"stid\":%d,\"etid\":%d}",stid,etid];
    }
    [sb appendString:@"],\"weekly_day\":["];
    
    
    for (int i = 0; i < selectedButtons.count; i++)
    {
        NSNumber *number = [selectedButtons objectAtIndex:i];
        if (i > 0)
        {
            [sb appendString:@","];
        }
        [sb appendFormat:@"%d",number.intValue];
    }
    [sb appendString:@"]}"];
//    [sb appendFormat:@"\"scheduleId\":%d}",-1];
    
    NSLog(@"%@",sb);
    
    SmartUpViewController *vc = (SmartUpViewController *)[UIUtils getControllerFromNavViewController:self andClass:[SmartUpViewController class]];
    SmartUp *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    [params safeSetObject:sb forKey:@"schedules"];
    
    if (self.schedule == nil)
    {
        [params safeSetObject:@"-1" forKey:@"scheduleId"];
        [params safeSetObject:@"addSchedule" forKey:@"action"];
    }
    else
    {
        [params safeSetObject:schedule.scheduleId forKey:@"scheduleId"];
        [params safeSetObject:@"editSchedule" forKey:@"action"];
    }
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SAVE_PLUG_SCHEDULE)
                                      delegate:self
                                  withUserInfo:dic];
}














//-(void) datePickValue:(NSString *)string andTag:(int) tag
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:1];
//    
//    CommonCell *cell = (CommonCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//    
//    cell.userLabel.text = string;
//    
//    [self.datas replaceObjectAtIndex:tag withObject:string];
//    
//}

-(void) datePickValueStid:(NSString *) stid etid:(NSString *) etid andTag:(int)tag
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:1];
    
    CommonCell *cell = (CommonCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.userLabel.text = [NSString stringWithFormat:@"%@-%@",stid,etid];
    
    NSNumber *n1 = [NSNumber numberWithInt:[self timeToInt:stid]];
    NSNumber *n2 = [NSNumber numberWithInt:[self timeToInt:etid]];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:n1,@"stid",n2,@"etid", nil];
    [self.datas replaceObjectAtIndex:tag withObject:dic];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (twoDatePickerView == nil)
    {
        twoDatePickerView = [[[NSBundle mainBundle] loadNibNamed:@"TwoDatePicker" owner:self options:nil] objectAtIndex:0];
    }
    
    NSDictionary *dic = [self.datas safeObjectAtIndex:textField.tag];
    if ([dic isKindOfClass:[NSDictionary class]])
    {
        NSString *stid = [self intToString:[[dic objectForKey:@"stid"] intValue]];
        NSString *etid = [self intToString:[[dic objectForKey:@"etid"] intValue]];
        
        [twoDatePickerView setDate1String:stid andDate2String:etid];
    }
    else
    {
        NSArray *array = [(NSString *)dic componentsSeparatedByString:@"-"];
        
        NSString *sid = [array objectAtIndex:0];
        NSString *etid = [array objectAtIndex:1];
        
        [twoDatePickerView setDate1String:sid andDate2String:etid];
    }
    
    twoDatePickerView.delegate = self;
    twoDatePickerView.tag = textField.tag;
    
    textField.inputView = twoDatePickerView;
    isAddAction = NO;
    
    currentAddIndex = textField.tag;
    
    return YES;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 2)
    {
        if (self.datas.count == 8)
        {
            [SVProgressHUD showErrorWithStatus:@"You can only create up to 8 periods"];
            return;
        }
        
        if (self.datas == nil)
        {
            self.datas = [NSMutableArray arrayWithCapacity:0];
        }
        
        [self.datas addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"stid",@"48",@"etid", nil]];
        
        currentAddIndex = self.datas.count - 1;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.datas.count -1) inSection:1];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        
        isAddAction = YES;
    }
    else if (indexPath.section == 3)
    {
        [self save];
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1)
    {
        if (section == 1 && self.datas.count == 0)
        {
            return nil;
        }
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 250, 30)];
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:14.0f];
        label.numberOfLines = 4;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        if (section == 0)
        {
            label.text = @"Apply this schedule to ";
        }
        else if(section == 1)
        {
            label.text = @"Periods when the channel is switched On ";
        }
        
        [tempView addSubview:label];
        
        return tempView;
    }
    else
    {
        return nil;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1)
    {
        if (section == 1 && self.datas.count == 0)
        {
            return 0;
        }
        return 40;
    }
    else
    {
        return 0;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            return 74;
        }
        else
        {
            return 111;
        }
    }
    else
    {
        return 44;
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return self.datas.count;
    }
    else
    {
        return 1;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            if (self.channelCell == nil)
            {
                self.channelCell = [[[NSBundle mainBundle] loadNibNamed:@"SequentialCell" owner:self options:nil] objectAtIndex:0];
                self.channelCell.object = self.schedule.channels;
            }
            return channelCell;
        }
        else
        {
            if (weekCell == nil)
            {
                self.weekCell = [[[NSBundle mainBundle] loadNibNamed:@"WeekCell" owner:self options:nil] objectAtIndex:0];
                
                self.weekCell.object = self.schedule.weekly_day;
            }
            
            if (self.weekCell.selectedArray == nil)
            {
                NSMutableArray *selecteArray = [NSMutableArray arrayWithCapacity:0];
                
                ControlViewController *control = (ControlViewController *)[UIUtils getControllerFromNavViewController:self andClass:[ControlViewController class]];
               
                for (int i = 0; i < control.datas.count; i++)
                {
                    ControlSchedule *s = [control.datas safeObjectAtIndex:i];
                    if ([s isKindOfClass:[ControlSchedule class]])
                    {
                        if (![s isEqual:self.schedule])
                        {
                            [selecteArray addObjectsFromArray:s.weekly_day];
                        }
                    }
                }
                
                self.weekCell.selectedArray = selecteArray;
            }
            
            return weekCell;
        }
    }
    else if (indexPath.section == 1)
    {
        CommonCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CommonTableViewCell" owner:self options:nil] objectAtIndex:0];
        
        cell.tf.tag = indexPath.row;
        cell.tf.delegate = self;
        
        
        NSDictionary *dic = [self.datas safeObjectAtIndex:indexPath.row];
        if ([dic isKindOfClass:[NSDictionary class]])
        {
            NSString *stid = [self intToString:[[dic objectForKey:@"stid"] intValue]];
            NSString *etid = [self intToString:[[dic objectForKey:@"etid"] intValue]];
            
            if ([etid isEqualToString:@"00:00"])
            {
                etid = @"24:00";
            }
            
            if (stid != nil && etid != nil)
            {
                cell.userLabel.text = [NSString stringWithFormat:@"%@-%@",stid,etid];
            }
        }
        else
        {
            cell.userLabel.text = (NSString *)dic;
        }
        
        if (currentAddIndex == indexPath.row)
        {
            [cell.tf becomeFirstResponder];
        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        if (indexPath.section == 2)
        {
            cell.textLabel.text = @"Add New Period";
        }
        else
        {
            cell.textLabel.text = @"Save And Return";
        }
        return cell;
    }
}



-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [self.datas safeRemovetAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}












- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (self.schedule == nil)
    {
        currentAddIndex = 0;
    }
    else
    {
        self.datas = [NSMutableArray arrayWithArray:self.schedule.periodids];
        currentAddIndex = -1;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
