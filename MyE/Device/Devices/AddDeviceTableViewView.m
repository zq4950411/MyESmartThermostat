//
//  AddSmartUpTableViewView.m
//  MyE
//
//  Created by space on 13-8-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "AddDeviceTableViewView.h"
#import "DictionaryTableViewViewController.h"

#import "CommonCell.h"
#import "MyEHouseData.h"

#import "NSString+Common.h"
#import "NSDictionary+Convert.h"

#import "Utils.h"

@implementation AddDeviceTableViewView

@synthesize typeDic;
@synthesize locationDic;
@synthesize tDic;

@synthesize dataDic;

@synthesize typeCell;
@synthesize smartup;

-(void) locationDidSelect:(NSDictionary *) dic
{
    //self.plug.locationName = [dic objectForKey:@"locationName"];
    smartup.locationName = [dic valueToStringForKey:@"locationName"];
    smartup.locationId = [dic valueToStringForKey:@"locationId"];
}

-(void) refreshLocalList:(NSMutableArray *)list
{
    [self.dataDic safeSetObject:list forKey:@"locationList"];
}

-(void) rowDidSelected:(NSDictionary *) dic withType:(int) t
{
    if (t == 0)
    {
        smartup.typeId = [dic valueToStringForKey:@"typeId"];
        smartup.typeName = [dic valueToStringForKey:@"typeName"];
    }
    else if (t == 1)
    {
        smartup.tidName = [dic valueToStringForKey:@"aliasName"];
        smartup.tid = [dic valueToStringForKey:@"tid"];
    }
    else if (t == 2)
    {
        smartup.locationName = [dic valueToStringForKey:@"locationName"];
        smartup.locationId = [dic valueToStringForKey:@"locationId"];
    }
    [self.tableView reloadData];
}



-(NSString *) getNameFromDictionaryList:(NSArray *) list ById:(NSString *) stringId withIdKey:(NSString *) key andNameKey:(NSString *) nameKey
{
    for (NSDictionary *temp in list)
    {
        NSString *tempId = [temp valueToStringForKey:key];
        if ([tempId isEqualToString:stringId])
        {
            return [temp valueToStringForKey:nameKey];
        }
    }
    
    return nil;
}


-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    [self headerFinish];
    
    if ([u rangeOfString:URL_FOR_SAVE_DEVICE].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }
    else if([u rangeOfString:URL_FOR_FIND_DEVICE].location != NSNotFound)
    {
        NSDictionary *temp = [jsonString JSONValue];
        if ([temp isKindOfClass:[NSDictionary class]])
        {
            self.dataDic = [NSMutableDictionary dictionaryWithDictionary:temp];
            
            if (self.smartup.typeId != nil)
            {
                NSArray *tempArray = [dataDic objectForKey:@"typeList"];
                NSString *typeName = [self getNameFromDictionaryList:tempArray
                                                                ById:self.smartup.typeId
                                                           withIdKey:@"typeId"
                                                          andNameKey:@"typeName"
                                      ];
                
                if (typeName == nil)
                {
                    typeName = @"";
                }
                smartup.typeName = typeName;
            }
            
            if (self.smartup.tid != nil)
            {
                NSArray *tempArray = [dataDic objectForKey:@"terminalList"];
                NSString *name = [self getNameFromDictionaryList:tempArray
                                                            ById:self.smartup.tid
                                                       withIdKey:@"tid"
                                                      andNameKey:@"aliasName"
                                  ];
                
                if (name == nil)
                {
                    name = @"";
                }
                smartup.tidName = name;
            }
            
            if (self.smartup.locationName != nil)
            {
                NSArray *tempArray = [dataDic objectForKey:@"locationList"];
                NSString *locationId = [self getNameFromDictionaryList:tempArray
                                                            ById:self.smartup.locationName
                                                       withIdKey:@"locationName"
                                                      andNameKey:@"locationId"
                                  ];
                
                smartup.locationId = locationId;
            }
            
            [self.tableView reloadData];
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_SAVE_DEVICE].location != NSNotFound)
    {
        [SVProgressHUD showSuccessWithStatus:@"Error"];
    }
}

//刷新数据
-(void) reloadWithDic:(NSDictionary *) dic
{
    if (currentSelectedIndex == 0)
    {
        self.typeDic = dic;
    }
    else if(currentSelectedIndex == 1)
    {
        self.tDic = dic;
    }
    else if(currentSelectedIndex == 2)
    {
        self.locationDic = dic;
    }
    [self.tableView reloadData];
}

//保存数据
-(void) saveDevice
{
    [typeCell.tf resignFirstResponder];
    
    NSString *name = [self.typeCell.tf.text nonBlankString];
    if (name == nil || [name isEqualToString:@""] || [name isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the device name"];
        return;
    }
    
    if ([Utils getWordsLength:name] > 20)
    {
        [SVProgressHUD showErrorWithStatus:@"The device name exceeds the 20 length"];
        return;
    }
    
    NSString *tid = smartup.tid;
    if (tid == nil || [tid isEqualToString:@""] || [tid isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the Smart Remote to control this device"];
        return;
    }

    
    NSString *typeid = smartup.typeId;
    if (typeid == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the device type"];
        return;
    }
    
    NSString *locationid = smartup.locationId;
    if (locationid == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the location of the device"];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *string = nil;

    if (smartup.deviceId == nil)
    {
        [params safeSetObject:@"addDevice" forKey:@"action"];
        string = [NSString stringWithFormat:@"{\"deviceName\":\"%@\",\"tid\":\"%@\",\"typeId\":\"%@\",\"locationId\":\"%@\"}",name,tid,typeid,locationid];
    }
    else
    {
        [params safeSetObject:@"editDevice" forKey:@"action"];
        [params safeSetObject:smartup.deviceId forKey:@"deviceId"];
        string = [NSString stringWithFormat:@"{\"deviceId\":\"%@\",\"deviceName\":\"%@\",\"tid\":\"%@\",\"typeId\":\"%@\",\"locationId\":\"%@\"}",smartup.deviceId,name,tid,typeid,locationid];
    }
    
    [params setObject:string forKey:@"deviceMode"];
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    self.isShowLoading = YES;
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SAVE_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}


-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:@"addDevice" forKey:@"action"];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_FIND_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}








-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataDic)
    {
        return 3;
    }
    else
    {
        return 0;
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
        return 1;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier2 = @"cell";
    
    if (indexPath.section == 0)
    {
        if (typeCell == nil)
        {
            self.typeCell = [[[NSBundle mainBundle] loadNibNamed:@"CommonTableViewCell" owner:self options:nil] objectAtIndex:0];
            self.typeCell.tf.placeholder = @"Enter Device Name";
            self.typeCell.tf.text = smartup.deviceName;
        }
        
        return typeCell;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier2];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = smartup.typeName;
            
            if (smartup.deviceId != nil)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.textColor = [UIColor blackColor];
            }
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"Smart Remote Used";
            cell.detailTextLabel.text = smartup.tidName;
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = @"Location";
            cell.detailTextLabel.text = smartup.locationName;
        }

        return cell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"OK";
        return cell;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        if (smartup.deviceId != nil)
        {
            return;
        }
    }
    
    if (indexPath.section == 1)
    {
        currentSelectedIndex = indexPath.row;
       
        NSArray *array = nil;
        if (indexPath.row == 0)
        {
            array = [dataDic objectForKey:@"typeList"];
        }
        else if(indexPath.row == 1)
        {
            array = [dataDic objectForKey:@"terminalList"];
        }
        else
        {
            array = [dataDic objectForKey:@"locationList"];
            
            LocationViewController *locationVc = [[LocationViewController alloc] initWithLocalList:array];
            
            locationVc.delegate = self;
            [self.navigationController pushViewController:locationVc animated:YES];
            
            return;
        }
        
        DictionaryTableViewViewController *vc = [[DictionaryTableViewViewController alloc] initWithType:indexPath.row andDatas:[NSMutableArray arrayWithArray:array]];
        
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 2)
    {
        [self saveDevice];
    }
}








- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
        
    if (self.smartup == nil)
    {
        self.smartup = [[SmartUp alloc] init];
        self.title = @"New";
    }
    else
    {
        self.title = @"Edit";
    }
    
    [self sendGetDatas];
    [self initHeaderView:self];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
