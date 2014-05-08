//
//  EditOperationViewController.m
//  MyE
//
//  Created by space on 13-8-13.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "EditOperationViewController.h"
#import "OperationViewController.h"
#import "MyEDevicesViewController.h"
#import "NSMutableDictionary+Safe.h"

#import "UIUtils.h"

#import "InstructionEntity.h"
#import "MyEDevice.h"
#import "MyEHouseData.h"

#import "CommonCell.h"

@implementation EditOperationViewController

@synthesize operationName;
@synthesize type;
@synthesize commentCell;
@synthesize instruction;



-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{    
    if ([u rangeOfString:URL_FOR_INSTRUCTION_VERIFY].location != NSNotFound)
    {
        if ([@"-999" isEqualToString:jsonString])
        {
            [SVProgressHUD showErrorWithStatus:@"No Connection"];
        }
        else if([@"-500" isEqualToString:jsonString])
        {
            [SVProgressHUD showErrorWithStatus:@"指令名称已经存"];
        }
        else if([@"fail" isEqualToString:jsonString])
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
        else
        {
            NSString *action = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"action"];
            if ([action isEqualToString:@"delete"])
            {
                if ([@"OK" isEqualToString:jsonString])
                {
                    [SVProgressHUD showSuccessWithStatus:@"Delete success"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:jsonString];
                }
            }
            else if ([action isEqualToString:@"record"])
            {
                //OperationViewController *vc = (OperationViewController *)self.parentVC;
                //[SVProgressHUD showSuccessWithStatus:@"Record success"];
                //[self.navigationController popViewControllerAnimated:YES];
               
                
                [SVProgressHUD showWithStatus:@"Recording" maskType:SVProgressHUDMaskTypeClear];
                [self findRecordResult];
            }
            else if ([action isEqualToString:@"verify"])
            {
                //OperationViewController *vc = (OperationViewController *)self.parentVC;
                [SVProgressHUD showSuccessWithStatus:@"Verify success"];
                //[self.navigationController popViewControllerAnimated:YES];
            }
            else if ([action isEqualToString:@"edit"])
            {
                //OperationViewController *vc = (OperationViewController *)self.parentVC;
                [SVProgressHUD showSuccessWithStatus:@"Edit success"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if ([action isEqualToString:@"add"])
            {
                instruction.instructionId = jsonString;
                //OperationViewController *vc = (OperationViewController *)self.parentVC;
                [SVProgressHUD showSuccessWithStatus:@"Add success"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    else if ([u rangeOfString:URL_FOR_INSTRUCTION_FIND_RECORD].location != NSNotFound)
    {
        if ([jsonString intValue] == 1)
        {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            
            isRecoredSuccess = YES;
            [self.tableView reloadData];
            //[self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if (requestCount >= 6)
            {
                [self sendTimeOut];
                return;
            }
            [self performSelector:@selector(findRecordResult) withObject:nil afterDelay:3.0f];
        }
    }
    else if ([u rangeOfString:URL_FOR_INSTRUCTION_TIME_OUT].location != NSNotFound)
    {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Fail"];
    }
    
}



-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_INSTRUCTION_FIND_RECORD].location != NSNotFound)
    {
        [SVProgressHUD showErrorWithStatus:Default_Net_Error_Info];
    }
    else if ([u rangeOfString:URL_FOR_INSTRUCTION_TIME_OUT].location != NSNotFound)
    {
        [SVProgressHUD showErrorWithStatus:Default_Net_Error_Info];
    }
}



-(void) sendTimeOut
{
    MyEDevicesViewController *vc = (MyEDevicesViewController *)[UIUtils getControllerFromNavViewController:self andClass:[MyEDevicesViewController class]];
    MyEDevice *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS,nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_INSTRUCTION_TIME_OUT)
                                      delegate:self
                                  withUserInfo:dic];
}

//查询指令状态
-(void) findRecordResult
{
    self.isShowLoading = NO;
    requestCount ++;
    
    MyEDevicesViewController *vc = (MyEDevicesViewController *)[UIUtils getControllerFromNavViewController:self andClass:[MyEDevicesViewController class]];
    MyEDevice *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    [params safeSetObject:instruction.instructionId forKey:@"instructionId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS,nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_INSTRUCTION_FIND_RECORD)
                                      delegate:self
                                  withUserInfo:dic];
}


-(void) operation:(NSString *) action
{
    NSString *name = commentCell.tf.text;
    if (name == nil || [name isEqualToString:@""] || [name isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the instruction name"];
        return;
    }
    
    if ([Utils getWordsLength:name] > 10)
    {
        [SVProgressHUD showErrorWithStatus:@"The instruction name exceeds the 10 length"];
        return;
    }
    
    MyEDevicesViewController *vc = (MyEDevicesViewController *)[UIUtils getControllerFromNavViewController:self andClass:[MyEDevicesViewController class]];
    MyEDevice *smartUp = [vc getCurrentSmartup];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:smartUp.tid forKey:@"tId"];
    
    [commentCell.tf resignFirstResponder];
    [params safeSetObject:commentCell.tf.text forKey:@"name"];
    
    [params safeSetObject:instruction.type forKey:@"type"];
    [params safeSetObject:instruction.instructionId forKey:@"instructionId"];
    [params safeSetObject:smartUp.deviceId forKey:@"deviceId"];
    [params safeSetObject:action forKey:@"action"];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS,action,WSNET_CONTEXT,nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_INSTRUCTION_VERIFY)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) delete
{
    self.isShowLoading = YES;
    [self operation:@"delete"];
}

-(void) record
{
    requestCount = 0;
    
    self.isShowLoading = YES;
    [self operation:@"record"];
}

-(void) verify
{
    self.isShowLoading = YES;
    [self operation:@"verify"];
}


-(void) edit
{
    self.isShowLoading = YES;
    if (instruction.instructionId.intValue == -1)
    {
        [self operation:@"add"];
    }
    else
    {
        [self operation:@"edit"];
    }
}








- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the name of the button"];
        return;
    }
        
    if (![instruction.name isEqualToString:commentCell.tf.text])
    {
        self.instruction.name = textField.text;
        [self edit];
    }
}



-(id) initWithType:(int) t andName:(NSString *)name
{
    if (self = [super init])
    {
        self.operationName = name;
        self.type = t;
    }
    return self;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        [self record];
    }
    else if (indexPath.section == 2)
    {
        if (isRecoredSuccess || instruction.status.intValue == 1)
        {
            [self verify];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Please Study Record instruction first!"];
        }
    }
    else if (indexPath.section == 3)
    {
        [self delete];
    }
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (type == 0 || instruction.instructionId.integerValue == -1)
    {
        return 3;
    }
    else
    {
        return 4;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier2 = @"cell2";
    
    if (indexPath.section == 0)
    {
        if (commentCell == nil)
        {
            commentCell = [[[NSBundle mainBundle] loadNibNamed:@"CommonTableViewCell" owner:self options:nil] objectAtIndex:0];
            commentCell.tf.placeholder = @"Please input name";
        }
        

        if ([instruction.type intValue] == 2)
        {
            commentCell.tf.userInteractionEnabled = YES;
            commentCell.tf.textColor = [UIColor blackColor];
        }
        else
        {
            commentCell.tf.userInteractionEnabled = NO;
            commentCell.tf.textColor = [UIColor lightGrayColor];
        }
        
        commentCell.tf.delegate = self;
        commentCell.tf.text = [[NSString alloc] initWithString:operationName];
        
        if (isFirstLaunch && instruction.instructionId.intValue == -1)
        {
            [commentCell.tf becomeFirstResponder];
        }
        
        return commentCell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = [self.datas objectAtIndex:indexPath.section];
        cell.tag = indexPath.row;
        
        if (indexPath.section == 1)
        {
            cell.textLabel.text = @"Record";
        }
        
        if (indexPath.section == 2)
        {
            if (isRecoredSuccess || instruction.status.intValue == 1)
            {
                cell.textLabel.textColor = [UIColor blackColor];
            }
            else
            {
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            cell.textLabel.text = @"Verify";
        }
        
        if (indexPath.section == 3 && type != 0 && instruction.instructionId.integerValue != -1)
        {
            cell.textLabel.text = @"Delete";
        }
        
        return cell;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    isFirstLaunch = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
