//
//  MyESubSwitchListViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESubSwitchListViewController.h"

@interface MyESubSwitchListViewController (){
    MBProgressHUD *HUD;
    NSIndexPath *_selectIndex;
}

@end

@implementation MyESubSwitchListViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"SubSwitchs";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.info.subSwitchList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MyESettingSubSwitch *subSwitch = self.info.subSwitchList[indexPath.row];
    cell.textLabel.text = subSwitch.name;
    cell.imageView.image = [subSwitch getImage];
    cell.detailTextLabel.text = subSwitch.mainTid.length>0?@"Paired":@"Not Paired";
    return cell;
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Are you sure to remove this switch?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
    alert.rightBlock = ^{
        if (HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }else
            [HUD show:YES];
        _selectIndex = indexPath;
        MyESettingSubSwitch *subSwitch = self.info.subSwitchList[indexPath.row];
        MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?gid=%@&houseId=%i",GetRequst(URL_FOR_SUBSWITCH_DELETE),subSwitch.gid,MainDelegate.houseData.houseId] postData:nil delegate:self loaderName:@"delete" userDataDictionary:nil];
        NSLog(@"%@",loader.name);
    };
    [alert show];
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"receive string is %@",string);
    NSInteger i = string.intValue;
    if (i == 1) {
        [self.info.subSwitchList removeObjectAtIndex:_selectIndex.row];
        [self.tableView deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else
        [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id viewController = segue.destinationViewController;
    MyESettingSubSwitch *subSwitch = self.info.subSwitchList[[self.tableView indexPathForCell:sender].row];
    [viewController setValue:subSwitch forKey:@"subSwitch"];
}

@end
