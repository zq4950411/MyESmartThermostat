//
//  MyETimeZoneViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-11.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyETimeZoneViewController.h"

@interface MyETimeZoneViewController (){
    NSArray *_data;
}

@end

@implementation MyETimeZoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    _data = @[@"EST",@"CST",@"MST",@"PST",@"AKST",@"HST"];
    if (!_jumpFromSettingPanel) {  //如果不是从设置面板过来的话要将右上角的barbutton取消掉
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&mid=%@&timeZone=%i",GetRequst(SETTING_SAVETIMEZONE),MainDelegate.houseData.houseId,self.info.mid,self.timeZone] postData:nil delegate:self loaderName:@"timeZoneSet" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _data[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == self.timeZone - 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
#pragma mark - UITable view delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.timeZone = indexPath.row + 1;
    if (!_jumpFromSettingPanel) {
        MyEMediatorRegisterViewController *vc = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];
        vc.timeZone = self.timeZone;
    }
    [self.tableView reloadData];
}
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"timeZoneSet"]) {
        if ([string isEqualToString:@"OK"]) {
            MyESettingsViewController *vc = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];
            vc.info.timeZone = self.timeZone;
            [self.navigationController popViewControllerAnimated:YES];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [SVProgressHUD showErrorWithStatus:@"fail"];
}
@end
