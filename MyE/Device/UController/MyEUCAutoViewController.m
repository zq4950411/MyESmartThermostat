//
//  MyEUCAutoViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-6.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCAutoViewController.h"

@interface MyEUCAutoViewController (){
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    NSIndexPath *_selectIndex;
}

@end

@implementation MyEUCAutoViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间

    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_AUTO_VIEW),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)upOrDownloadInfoWithURL:(NSString *)url andName:(NSString *)name{
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ucAuto.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UIView *view = (UIView *)[cell.contentView viewWithTag:1024];
    view.layer.cornerRadius = 4;
    UILabel *channel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *weeks = (UILabel *)[cell.contentView viewWithTag:101];
    MyEUCSchedule *schedule = self.ucAuto.lists[indexPath.row];
    channel.text = [schedule getChannels];
    weeks.text = [schedule getWeeks];
    return cell;
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectIndex = indexPath;
    MyEUCSchedule *schedule = self.ucAuto.lists[indexPath.row];
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"do you want to delete this schedule?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
    alert.rightBlock = ^{
        [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&scheduleId=%i&action=deleteSchedule",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SAVE_PLUG_SCHEDULE),MainDelegate.houseData.houseId,self.device.tid,schedule.scheduleId] andName:@"delete"];
    };
    [alert show];
}

#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([name isEqualToString:@"downloadInfo"]) {
        if (![string isEqualToString:@"fail"]) {
            MyEUCAuto *uc = [[MyEUCAuto alloc] initWithJsonString:string];
            self.ucAuto = uc;
            [self.tableView reloadData];
        }
    }
    if ([name isEqualToString:@"delete"]) {
        if ([string isEqualToString:@"OK"]) {
            [self.ucAuto.lists removeObjectAtIndex:_selectIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MyEUCScheduleViewController *vc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"add"]) {
        MyEUCSchedule *schedule = [[MyEUCSchedule alloc] init];
        vc.schedule = schedule;
        vc.isAdd = YES;
        vc.ucAuto = self.ucAuto;
    }
    if ([segue.identifier isEqualToString:@"edit"]) {
        MyEUCSchedule *schedule = self.ucAuto.lists[[self.tableView indexPathForCell:sender].row];
        vc.schedule = schedule;
        vc.isAdd = NO;
        vc.ucAuto = self.ucAuto;
    }
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
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_AUTO_VIEW),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

@end
