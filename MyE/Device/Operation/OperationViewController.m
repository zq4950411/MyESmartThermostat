//
//  OperationViewController.m
//  MyE
//
//  Created by space on 13-8-13.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "OperationViewController.h"
#import "EditOperationViewController.h"

#import "MyEDevicesViewController.h"

#import "MyEHouseData.h"
#import "MyEDevice.h"

#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"

#import "UIUtils.h"

#import "InstructionEntity.h"

#import "ACPButton.h"


@implementation OperationViewController


-(void) updateInstruction
{
    
}

-(InstructionEntity *) getCurrentInstruction
{
    return [self.datas safeObjectAtIndex:currentSelectedIndex];
}

-(InstructionEntity *) getNewButtonInstruction
{
    InstructionEntity *instruction = [[InstructionEntity alloc] init];
    
    instruction.instructionId = @"-1";
    instruction.name = @"Create New Button";
    instruction.sortId = [NSString stringWithFormat:@"%d",10000];
    instruction.type = [NSString stringWithFormat:@"2"];
    instruction.status = @"1";
    
    return instruction;
}

-(InstructionEntity *) getNewButtonInstruction2
{
    int max = 0;
    for (int i = 0; i < self.datas.count; i++)
    {
        InstructionEntity *instruction = [self.datas objectAtIndex:i];
        if (instruction.sortId.intValue > max)
        {
            max = instruction.sortId.intValue;
        }
    }
    InstructionEntity *instruction = [[InstructionEntity alloc] init];
    
    instruction.instructionId = @"-1";
    instruction.name = @"unspecified";
    instruction.sortId = [NSString stringWithFormat:@"%d",max];
    instruction.type = [NSString stringWithFormat:@"2"];
    instruction.status = @"0";
    
    return instruction;
}


-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    [self headerFinish];
    if ([u rangeOfString:URL_FOR_FIND_INSTRUCTION].location != NSNotFound)
    {
        self.datas = [InstructionEntity instructions:jsonString];
        [self.tableView reloadData];
    }
    else if ([u rangeOfString:URL_FOR_INSTRUCTION_VERIFY].location != NSNotFound)
    {
        if ([jsonString isKindOfClass:[NSNumber class]])
        {
            if ([jsonString intValue] == -999)
            {
                [SVProgressHUD showErrorWithStatus:@"No Connection"];
            }
            else if([jsonString intValue] == -500)
            {
                [SVProgressHUD showErrorWithStatus:@"指令名称已经存"];
            }
        }
        else
        {
            if ([jsonString isEqualToString:@"OK"])
            {
                [SVProgressHUD showErrorWithStatus:@"Success"];
                
                InstructionEntity *inst = [userInfo objectForKey:WSNET_CONTEXT];
                
                [self.datas addObject:inst];
                [self.tableView reloadData];
            }
            else if ([jsonString isEqualToString:@"-999"])
            {
                [SVProgressHUD showErrorWithStatus:@"No Connection"];
            }
            else if([jsonString isEqualToString:@"-500"])
            {
                [SVProgressHUD showErrorWithStatus:@"指令名称已经存"];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"Error"];
            }
            
        }
        [self.tableView reloadData];
    }
    else if ([u rangeOfString:URL_FOR_INSTRUCTION_CONTROL].location != NSNotFound)
    {
        if ([jsonString isEqualToString:@"OK"])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
    }
    
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_FIND_INSTRUCTION].location != NSNotFound)
    {
        
    }
    else if ([u rangeOfString:URL_FOR_INSTRUCTION_VERIFY].location != NSNotFound)
    {
        
    }
}








-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    MyEDevicesViewController *vc = (MyEDevicesViewController *)[UIUtils getControllerFromNavViewController:self andClass:[MyEDevicesViewController class]];
    MyEDevice *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.deviceId forKey:@"deviceId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_FIND_INSTRUCTION)
                                      delegate:self
                                  withUserInfo:dic];
}



-(void) addOperation
{
    InstructionEntity *instruction = [self getNewButtonInstruction2];
    
    MyEDevicesViewController *vc = (MyEDevicesViewController *)[UIUtils getControllerFromNavViewController:self andClass:[MyEDevicesViewController class]];
    MyEDevice *smartUp = [vc getCurrentSmartup];
    
    self.isShowLoading = YES;
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    [params safeSetObject:instruction.name forKey:@"name"];
    [params safeSetObject:instruction.type forKey:@"type"];
    [params safeSetObject:instruction.instructionId forKey:@"instructionId"];
    [params safeSetObject:smartUp.deviceId forKey:@"deviceId"];
    [params safeSetObject:@"add" forKey:@"action"];
    
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS,instruction,WSNET_CONTEXT,nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_INSTRUCTION_VERIFY)
                                      delegate:self
                                  withUserInfo:dic];
}

















-(void) deleteRow
{
    [self.datas safeRemovetAtIndex:currentSelectedIndex];
    [self.tableView reloadData];
}

-(void) longPress:(UILongPressGestureRecognizer *) gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        currentSelectedIndex = gesture.view.tag;
        
        InstructionEntity *ins = (InstructionEntity *)[self.datas safeObjectAtIndex:currentSelectedIndex];
        NSString *text = ins.name;
        
        if([text isEqualToString:@"ON"] || [text isEqualToString:@"OFF"] || [text isEqualToString:@"Create New Button"])
        {
            EditOperationViewController *editVc = [[EditOperationViewController alloc] initWithType:0 andName:text];
            editVc.parentVC = self;
            editVc.instruction = ins;
            [self.navigationController pushViewController:editVc animated:YES];
        }
        else
        {
            EditOperationViewController *editVc = [[EditOperationViewController alloc] initWithType:1 andName:text];
            editVc.parentVC = self;
            editVc.instruction = ins;
            [self.navigationController pushViewController:editVc animated:YES];
        }
    }
}










-(void) addScheduleAction:(UIButton *) sender
{
    if (!canAddNew)
    {
        [SVProgressHUD showErrorWithStatus:@"Please complete the recording for ON and OFF before creating new buttons"];
        return;
    }
    else if(self.datas.count == 10)
    {
        [SVProgressHUD showErrorWithStatus:@"Can't add more than 10 instructions!"];
        return;
    }
    else
    {
        InstructionEntity *temp = [self getNewButtonInstruction2];
        
        EditOperationViewController *editVc = [[EditOperationViewController alloc] initWithType:0 andName:temp.name];
        editVc.instruction = temp;
        editVc.parentVC = self;
        [self.navigationController pushViewController:editVc animated:YES];
    }
}



 -(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstructionEntity *instuction = [self.datas safeObjectAtIndex:indexPath.row];
    if ([instuction isKindOfClass:[InstructionEntity class]])
    {
        if (instuction.status.intValue == 0)
        {
            return;
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.isShowLoading = YES;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
        [params safeSetObject:instuction.instructionId forKey:@"instructionId"];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
        
        [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_INSTRUCTION_CONTROL)
                                          delegate:self
                                      withUserInfo:dic];
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 44;
    }
    else
    {
        return 0;
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, 320, 44)];
        
        label.text = @"Press and hold to edit the button";
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor lightGrayColor];
        
        return label;
    }
    else
    {
        return nil;
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

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        InstructionEntity *instruction = [self.datas safeObjectAtIndex:indexPath.row];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = instruction.name;
        cell.tag = indexPath.row;
        //[cell addShadowToCellInTableView:self.tableView atIndexPath:indexPath];
        
        if (instruction.status.intValue == 1)
        {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        else
        {
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        
        
        if (instruction.type.intValue == 0)
        {
            if (instruction.status.intValue == 0)
            {
                canAddNew = NO;
            }
            else
            {
                canAddNew = YES;
            }
        }
        else if (instruction.type.intValue == 1)
        {
            if (instruction.status.intValue == 0)
            {
                canAddNew = NO;
            }
            else
            {
                canAddNew = YES;
            }
        }
        
        
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(longPress:)];
        [cell addGestureRecognizer:longPress];
        
        return cell;
    }
    else
    {
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
        
        [button setTitle:@"Create New Button" forState:UIControlStateNormal];
        [button setStyleType:ACPButtonOK];
        button.frame = CGRectMake(10, 0, 280, 44);
        [button addTarget:self action:@selector(addScheduleAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:button];
        
        return cell;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MyEDevicesViewController *vc = (MyEDevicesViewController *)[UIUtils getControllerFromNavViewController:self andClass:[MyEDevicesViewController class]];
    MyEDevice *smartUp = [vc getCurrentSmartup];
    self.title = smartUp.deviceName;
    
    canAddNew = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initHeaderView:self];
}

-(void) viewDidAppear:(BOOL) animated
{
    [self sendGetDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
