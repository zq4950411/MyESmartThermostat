//
//  MyETerminalsViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyETerminalsViewController.h"

@interface MyETerminalsViewController (){
    NSIndexPath *_selectIndex;
    MyESettingsTerminal *_deleteTerminal;
    NSInteger _times;
}

@end

@implementation MyETerminalsViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.info.terminals.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MyESettingsTerminal *terminal = self.info.terminals[indexPath.row];
    UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:100];
    UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:101];
    lbl.text = terminal.name;
    image.image = [terminal changeSignalToImage];
    return cell;
}

#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Do you want to delete this terminal?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
    alert.rightBlock = ^{
        _selectIndex = indexPath;
        MyESettingsTerminal *terminal = self.info.terminals[indexPath.row];
        _deleteTerminal = terminal;
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(SETTING_DELETE_T),MainDelegate.houseData.houseId,terminal.tid] postData:nil delegate:self loaderName:@"delete" userDataDictionary:nil];
    };
}

#pragma mark - private methods
-(void)queryDelete{
    _times++;
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SETTINGS_DELETE_THERMOSTAT_QUERY_STATUS),MainDelegate.houseData.houseId,_deleteTerminal.tid] postData:nil delegate:self loaderName:@"delete" userDataDictionary:nil];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyESettingsTerminal *terminal = self.info.terminals[[self.tableView indexPathForCell:sender].row];
    UIViewController *vc = segue.destinationViewController;
    [vc setValue:terminal forKey:@"terminal"];
}

#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([string isEqualToString:@"fail"]) {
        [SVProgressHUD showErrorWithStatus:@"fail"];
        return;
    }
    if (string.intValue == 1 ) {
        [SVProgressHUD showErrorWithStatus:@"fail"];
    }else if (string.intValue == 2){
        if (_times < 10) {
            [self queryDelete];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }else if(string.intValue == 0){
        [self.info.terminals removeObjectAtIndex:_selectIndex.row];
        [self.tableView deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
@end
