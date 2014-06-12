//
//  MoreViewController.m
//  MyE
//
//  Created by space on 13-8-30.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "MoreViewController.h"
#import "RepwdViewController.h"

#import "MyEAccountData.h"
#import "MyEHouseData.h"

#import "OpenUDID.h"
#import "SWRevealViewController.h"

@implementation MoreViewController

@synthesize typeCell;




- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    NSUserDefaults *uf = [NSUserDefaults standardUserDefaults];
    [uf setValue:textField.text forKey:@"IP"];
    [uf synchronize];
}




//-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
//{
//    if ([u rangeOfString:MORE_SAVE_NOTIFICATION].location != NSNotFound)
//    {
//        if ([@"OK" isEqualToString:jsonString])
//        {
//            isSwitch = !isSwitch;
//        }
//        else
//        {
//            [self.tableView reloadData];
//        }
//    }
//}
//
//-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
//{
//    if ([u rangeOfString:MORE_NOTIFICATION].location != NSNotFound)
//    {
//        
//    }
//}
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"Getting Notification setting"]) {
        if ([@"1" isEqualToString:string])
        {
            isSwitch = YES;
        }
        else if ([@"0" isEqualToString:string])
        {
            isSwitch = NO;
        }
        [self.tableView reloadData];
    }
    if ([name isEqualToString:@"Changing notification setting"]) {
        if ([@"OK" isEqualToString:string])
        {
            isSwitch = !isSwitch;
        }
        else
        {
            [self.tableView reloadData];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ communication Error", name]];
}


-(void) valueChange:(UISwitch *) swch
{
    self.isShowLoading = YES;
    
    /*
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:@"0" forKey:@"deviceType"];
    [params setObject:[OpenUDID value] forKey:@"deviceAlias"];
    
    if (swch.isOn)
    {
        [params setObject:@"1" forKey:@"notification"];
    }
    else
    {
        [params setObject:@"0" forKey:@"notification"];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(MORE_SAVE_NOTIFICATION)
                                      delegate:self
                                  withUserInfo:dic];
    */
    NSString *url = [NSString stringWithFormat:@"%@?deviceType=0&deviceAlias=%@&notification=%i",GetRequst(MORE_SAVE_NOTIFICATION),[OpenUDID value], swch.isOn?1:0];
    [MyEDataLoader startLoadingWithURLString:url postData:nil delegate:self loaderName:@"Changing notification setting" userDataDictionary:nil];
}

-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    /*
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:@"0" forKey:@"deviceType"];
    [params setObject:[OpenUDID value] forKey:@"deviceAlias"];

    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    
    [[NetManager sharedManager] requestWithURL:GetRequst(MORE_NOTIFICATION)
                                      delegate:self
                                  withUserInfo:dic];
     */
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?deviceType=0&deviceAlias=%@",GetRequst(MORE_NOTIFICATION),[OpenUDID value]] postData:nil delegate:self loaderName:@"Getting Notification setting" userDataDictionary:nil];
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"cell";
    
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Password";
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        static NSString *identifier = @"cell00";
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        cell.textLabel.text = @"Notification";
        
        UISwitch *swi = [[UISwitch alloc] initWithFrame:CGRectMake(235, 10, 0, 40)];
        
        [swi addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventTouchUpInside];
        swi.tag = indexPath.row;
        [swi setOn:isSwitch];
        
        [cell.contentView addSubview:swi];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        NSUserDefaults *uf = [NSUserDefaults standardUserDefaults];
        
        cell.textLabel.text = @"IP";
        cell.detailTextLabel.text = [uf valueForKey:@"IP"];
        
        return cell;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        RepwdViewController *vc = [[RepwdViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.navigationItem.title = @"Account";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Change button color
//    _sidebarButton.tintColor = [UIColor colorWithWhite:0.36f alpha:0.82f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    self.parentViewController.navigationItem.title = @"Account";
    
    [self sendGetDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
