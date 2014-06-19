//
//  MyEUCManualViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-6.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCManualViewController.h"

@interface MyEUCManualViewController (){
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    MBProgressHUD *HUD;
}

@end

@implementation MyEUCManualViewController

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

    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROL_MANUAL_VIEW),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
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
-(void)control:(UISwitch *)sender{
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    self.manual.channels = [self.manual changeStringAtIndex:indexPath.row byString:sender.isOn?@"1":@"0"];
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&channels=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_MANUAL_SAVE),MainDelegate.houseData.houseId,self.device.tid,[self.manual changeStringAtIndex:indexPath.row byString:sender.isOn?@"1":@"0"]] andName:@"control"];
}
-(void)upOrDownloadInfoWithURL:(NSString *)url andName:(NSString *)name{
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.manual.channels.length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UIView *view = (UIView *)[cell.contentView viewWithTag:1024];
    view.layer.cornerRadius = 4;
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = [NSString stringWithFormat:@"Channel %i",indexPath.row];
    UISwitch *controlSwitch = (UISwitch *)[cell.contentView viewWithTag:101];
    NSString *string = [self.manual.channels substringWithRange:NSMakeRange(indexPath.row, 1)];
    [controlSwitch setOn:[string isEqualToString:@"1"]?YES:NO animated:YES];
    [controlSwitch addTarget:self action:@selector(control:) forControlEvents:UIControlEventValueChanged];
    return cell;
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
            MyEUCManual *manual = [[MyEUCManual alloc] initWithJsonString:string];
            self.manual = manual;
            [self.tableView reloadData];
        }
    }
    if ([name isEqualToString:@"control"]) {
        if ([string isEqualToString:@"OK"]) {
            
        }
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
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROL_MANUAL_VIEW),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

@end
