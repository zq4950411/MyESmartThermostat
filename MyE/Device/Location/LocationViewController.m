//
//  LocationViewController.m
//  MyE
//
//  Created by space on 13-8-21.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "LocationViewController.h"
#import "LocationCell.h"
#import "UIViewController+KNSemiModal.h"
#import "PlugControlViewController.h"

#import "UIUtils.h"
#import "PlugEntity.h"
#import "LocationInPutView.h"

#import "MyEHouseData.h"

@implementation LocationViewController

@synthesize locationView;
@synthesize delegate;


-(id) initWithLocalList:(NSArray *) locationList
{
    if (self = [super init])
    {
        self.datas = [NSMutableArray arrayWithArray:locationList];
    }
    return self;
}



-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FRO_LOCATION_EDIT].location != NSNotFound)
    {
        NSString *action = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"action"];
        //删除动作
        if ([@"deteleLocation" isEqualToString:action])
        {
            if ([@"OK" isEqualToString:jsonString])
            {
                [self.datas safeRemovetAtIndex:currentDeleteIndex];
                [self.tableView reloadData];
                
                [SVProgressHUD showSuccessWithStatus:@"Success"];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:[NSString errorInfo:jsonString]];
            }
        }
        else if([@"addLocation" isEqualToString:action])
        {
            if (![@"fail" isEqualToString:jsonString])
            {
                NSDictionary *dic = [userInfo objectForKey:REQUET_PARAMS];
                NSString *name = [dic objectForKey:@"name"];
                
                NSDictionary *newDic = [NSDictionary dictionaryWithObjectsAndKeys:jsonString,@"locationId",name,@"locationName", nil];
                
                [self.datas safeReplaceObjectAtIndex:currentSelectedIndex withObject:newDic];
                [self.tableView reloadData];
                
                [SVProgressHUD showSuccessWithStatus:@"Success"];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:[NSString errorInfo:jsonString]];
            }
        }
        else if([@"editLocation" isEqualToString:action])
        {
            if ([@"OK" isEqualToString:jsonString])
            {
                NSDictionary *dic = [userInfo objectForKey:REQUET_PARAMS];
                NSString *name = [dic objectForKey:@"name"];
                
                NSDictionary *dic2 = [self.datas safeObjectAtIndex:currentSelectedIndex];
                
                NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic2];
                [newDic safeSetObject:name forKey:@"locationName"];
                
                [self.datas safeReplaceObjectAtIndex:currentSelectedIndex withObject:newDic];
                [self.tableView reloadData];
                
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                
                if ([delegate respondsToSelector:@selector(refreshLocation:)])
                {
                    [delegate refreshLocation:newDic];
                }
            }
            else
            {
                [self.tableView reloadData];
                [SVProgressHUD showErrorWithStatus:[NSString errorInfo:jsonString]];
            }
        }
        
        if ([delegate respondsToSelector:@selector(refreshLocalList:)])
        {
            [delegate refreshLocalList:self.datas];
        }
//        PlugControlViewController *plugVc = (PlugControlViewController *)[UIUtils getControllerFromNavViewController:self andClass:[PlugControlViewController class]];
//        plugVc.plug.locationList = self.datas;
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FRO_LOCATION_EDIT].location != NSNotFound)
    {

    }
}


-(void) editActionWithName:(NSString *) name locationId:(NSString *) locationId
{
    NSString *action = nil;
//    NSString *locationId = [dic valueToStringForKey:@"locationId"];;
//    NSString *name = [dic valueToStringForKey:@"locationName"];
 
    if ([name isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the name of the room"];
        return;
    }
    
    if (locationId.intValue == -1)
    {
        action = @"addLocation";
    }
    else
    {
        action = @"editLocation";
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:name forKey:@"name"];
    [params safeSetObject:locationId forKey:@"LocationId"];
    [params safeSetObject:action forKey:@"action"];    
    
    NSDictionary *temp = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FRO_LOCATION_EDIT)
                                      delegate:self
                                  withUserInfo:temp];
    actionType = 2;
}

-(void) deleteActionWithIndex:(int) index
{
    NSString *action = nil;
    NSString *locationId = nil;
    
    
    NSDictionary *dic = [self.datas objectAtIndex:index];
    if ([dic isKindOfClass:[NSDictionary class]])
    {
        locationId = [dic valueToStringForKey:@"locationId"];
        action = @"deteleLocation";
    }
    else
    {
        [self.datas safeRemovetAtIndex:index];
        [self.tableView reloadData];
        
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:locationId forKey:@"LocationId"];
    [params setObject:action forKey:@"action"];
    
    NSDictionary *temp = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FRO_LOCATION_EDIT)
                                      delegate:self
                                  withUserInfo:temp];
    actionType = 1;
}











-(void) rename:(UIButton *) sender
{
    UITextField *tf = nil;
    
    for (UIView *temp in sender.superview.subviews) {
        if ([temp isKindOfClass:[UITextField class]])
        {
            tf = (UITextField *)temp;
        }
    }
    
    if (tf == nil)
    {
        return;
    }
    
    currentSelectedIndex = tf.tag;
    currentFoucsIndex = tf.tag;
    
    tf.enabled = YES;
    [tf becomeFirstResponder];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{    
    textField.enabled = NO;
    
    currentFoucsIndex = -1;
    currentSelectedIndex = textField.tag;
    
//    NSString *text = nil;
//    NSNumber *locaionId = nil;
    
    NSDictionary *dic = [self.datas safeObjectAtIndex:textField.tag];
    NSString *text = [dic objectForKey:@"locationName"];
//    if ([dic isKindOfClass:[NSDictionary class]])
//    {
//
//        locaionId = [dic objectForKey:@"locationId"];
//    }
//    else if([dic isKindOfClass:[NSString class]])
//    {
//        text = (NSString *)dic;
//        locaionId = [NSNumber numberWithInt:-1];
//    }

    //NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:textField.text,@"locationName",locaionId,@"locationId", nil];
    //[self.datas safeReplaceObjectAtIndex:textField.tag withObject:tempDic];
    
    if (![textField.text isEqualToString:text])
    {
        NSString *locationId = [dic objectForKey:@"locationId"];
        
        [self editActionWithName:textField.text locationId:locationId];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isBlank])
    {
        [textField becomeFirstResponder];
        [SVProgressHUD showErrorWithStatus:@"Please specify the name of the room"];
        return YES;
    }
    
    [textField resignFirstResponder];
    return YES;
}






-(void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
    {
        NSDictionary *dic = [self.datas safeObjectAtIndex:indexPath.row];
        if ([delegate respondsToSelector:@selector(locationDidSelect:)])
        {
            [delegate locationDidSelect:dic];
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (indexPath.section == 0 && indexPath.section == 0)
    {
        currentSelectedIndex = indexPath.row;
        NSDictionary *dic = [self.datas safeObjectAtIndex:indexPath.row];
        if ([delegate respondsToSelector:@selector(locationDidSelect:)])
        {
            [delegate locationDidSelect:dic];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"locationName",[NSNumber numberWithInt:-1],@"locationId", nil];
        [self.datas addObject:dic];
        
        currentFoucsIndex = self.datas.count - 1;
        [self.tableView reloadData];
    }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentDeleteIndex = indexPath.row;
    [self deleteActionWithIndex:indexPath.row];
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
        return 44;
    }
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identier = @"cell";
    
    if (indexPath.section == 0)
    {
        LocationCell *cell = [tv dequeueReusableCellWithIdentifier:identier];
        
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil] objectAtIndex:0];
        }
        
        if (indexPath.row == currentSelectedIndex)
        {
            cell.headImageView.hidden = YES;
        }
        else
        {
            cell.headImageView.hidden = YES;
        }
        
        
        if (indexPath.row == currentFoucsIndex)
        {
            cell.tf.enabled = YES;
            [cell.tf becomeFirstResponder];
        }
        else
        {
            cell.tf.enabled = NO;
            [cell.tf resignFirstResponder];
        }
        
        cell.object = [self.datas objectAtIndex:indexPath.row];
        
        cell.tf.delegate = self;
        cell.tf.tag = indexPath.row;
        
        [cell.headButton addTarget:self action:@selector(rename:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"New Location";
        
        return cell;
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    currentFoucsIndex = -1;

    if (self.datas == nil)
    {
        self.datas = [NSMutableArray arrayWithCapacity:0];
    }
    
//    PlugControlViewController *plugVc = (PlugControlViewController *)[UIUtils getControllerFromNavViewController:self andClass:[PlugControlViewController class]];
//    self.datas = [NSMutableArray arrayWithArray:plugVc.plug.locationList];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
