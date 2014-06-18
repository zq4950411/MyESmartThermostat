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
    MBProgressHUD *HUD;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}

@end

@implementation MyETerminalsViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
}

#pragma mark - private methods
-(void)downloadInfoFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i",GetRequst(SETTING_FIND_GATEWAY),MainDelegate.houseData.houseId] postData:nil delegate:self loaderName:@"downloadInfo" userDataDictionary:nil];
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
        if (HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }else
            [HUD show:YES];
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(SETTING_DELETE_T),MainDelegate.houseData.houseId,terminal.tid] postData:nil delegate:self loaderName:@"delete" userDataDictionary:nil];
    };
    [alert show];
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
    [HUD hide:YES];
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([string isEqualToString:@"fail"]) {
        [SVProgressHUD showErrorWithStatus:@"fail"];
        return;
    }
    if ([name isEqualToString:@"delete"]) {
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
    if ([name isEqualToString:@"downloadInfo"]) {
        [HUD hide:YES];
        if (![string isEqualToString:@"fail"]) {
            MyESettingsInfo *info = [[MyESettingsInfo alloc] initWithJsonString:string];
            self.info.terminals = info.terminals;
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _isRefreshing = YES;
    [self downloadInfoFromServer];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}
@end
