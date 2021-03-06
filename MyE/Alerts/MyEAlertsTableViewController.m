//
//  MyEAlertsTableViewController.m
//  MyE
//
//  Created by Ye Yuan on 5/24/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEAlertsTableViewController.h"
#import "SWRevealViewController.h"
#import "MyEAlert.h"
#import "MyEAccountData.h"
#import "MyEHouseData.h"
#import "MyEAlertDetailViewController.h"

#define ALERT_COUNT_PER_PAGE  10

@interface MyEAlertsTableViewController (){
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}
-(void) deleteAlertFromServerAtRow:(NSInteger)row;
- (void) downloadModelFromServer;

// type:0 init load when enter this VC at first time
// type:1 pull down to refresh
// type:3 drag up to load more
-(void) downloadModelForType:(ALERT_LOAD_TYPE)type withPageIndex:(NSInteger)index andCount:(NSInteger)count;
@end

@implementation MyEAlertsTableViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.alerts = [NSMutableArray array];
    _pageIndex = 0;
    _totalCount = 0;
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);

    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        refreshView.delegate = self;
        [self.tableView addSubview:refreshView];
        _refreshHeaderView = refreshView;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
    
//    if(!self.fromHome){
//        _sidebarButton.target = self.revealViewController;
//        _sidebarButton.action = @selector(revealToggle:);
//    }else {
//        self.navigationItem.leftBarButtonItem = nil;
//        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
//                                       initWithTitle: @"Home"
//                                       style:UIBarButtonItemStylePlain
//                                       target:self
//                                       action:@selector(goHome)];
//        self.navigationItem.backBarButtonItem = backButton;
//    }
//    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
//                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//                                      target:self
//                                      action:@selector(refreshAction)];
//    self.parentViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton, nil];

    [self downloadModelFromServer];

}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.alerts.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertCell" forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *postDateLabel = (UILabel*)[cell.contentView viewWithTag:103];
    UILabel *isNewLabel = (UILabel*)[cell.contentView viewWithTag:104];
    MyEAlert *alert = self.alerts[indexPath.row];
    titleLabel.text = alert.title;
    postDateLabel.text = alert.publish_date;
    isNewLabel.hidden = (alert.new_flag == 0);
    return cell;
}
#pragma mark - UITableView delegate methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                            message:@"Are you sure to delete alert?"
                                                           delegate:self
                                                  cancelButtonTitle:@"YES"
                                                  otherButtonTitles:@"NO"
                                  , nil];
        alertView.tag = indexPath.row;
        [alertView show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"godetail"]) {
        MyEAlertDetailViewController *vc = segue.destinationViewController;
        NSInteger index = self.tableView.indexPathForSelectedRow.row;
        vc.alert = self.alerts[index];
    }
}
#pragma mark -
#pragma mark URL Loading System methods
-(void) deleteAlertFromServerAtRow:(NSInteger)row{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    MyEAlert *alert = self.alerts[row];
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&id=%d",GetRequst(URL_FOR_ALERT_DELETE), MainDelegate.accountData.userId, alert.ID];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"DeleteAlertUploader"  userDataDictionary:@{@"indexPath":indexPath}];
    NSLog(@"DeleteAlertUploader is %@",downloader.name);
}

- (IBAction)loadMore:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"Load More"]) {
        [self loadMoreWithBool:YES];
        [self downloadModelForType:ALERT_LOAD_TYPE_DRAG_LOADMORE withPageIndex:_pageIndex andCount:ALERT_COUNT_PER_PAGE];
    }
}

#pragma mark - private methods
-(void)loadMoreWithBool:(BOOL)flag{
    self.activity.hidden = !flag;  //flag为YES，表示开始刷新
    if (flag) {
        [self.refreshBtn setTitle:@"Loading..." forState:UIControlStateNormal];
    }else
        [self.refreshBtn setTitle:@"Load More" forState:UIControlStateNormal];
}
// 进入次面板的初次下载
- (void) downloadModelFromServer
{
    [self downloadModelForType:ALERT_LOAD_TYPE_INIT withPageIndex:0 andCount:ALERT_COUNT_PER_PAGE];
}
-(void) downloadModelForType:(ALERT_LOAD_TYPE)type withPageIndex:(NSInteger)index andCount:(NSInteger)count
{
    if (type == ALERT_LOAD_TYPE_INIT) {
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.delegate = self;
        } else
            [HUD show:YES];
    }
    
    // 如果是load more, 但已经加载到本地的alert数目和服务器现有的alert数目一样, 就表示全部加载完成了, 直接返回, 不再加载
    if(type == ALERT_LOAD_TYPE_DRAG_LOADMORE){
//        self.tableView.footerLoadingText = @"Loading...";
//        [self.tableView.footerLoadingIndicator startAnimating];
//        self.tableView.footerLoadingIndicator.hidden = NO;
//        if( self.alerts.count >= _totalCount){
//            [self.tableView.footerLoadingIndicator stopAnimating ];
//            self.tableView.footerLoadingIndicator.hidden = YES;
//            
//            self.tableView.footerLoadingText = @"No more data";
//            [self.tableView performSelector:@selector(finishLoadMore) withObject:nil afterDelay:1];
//            return;
//        }
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@?page_index=%d&page_size=%d",GetRequst(URL_FOR_ALERTS_VIEW),index, count];
    [MyEDataLoader startLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"AlertsDownloader" userDataDictionary:@{@"load_type":@(type)}];
}

#pragma mark - URL Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict
{
    if([name isEqualToString:@"AlertsDownloader"]) {
        NSInteger load_type = [dict[@"load_type"] integerValue];
        if(load_type == ALERT_LOAD_TYPE_INIT)
            [HUD hide:YES];
        if (load_type == ALERT_LOAD_TYPE_PULL_REFRESH) {
            if (_isRefreshing) {
                _isRefreshing = NO;
                [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
            }
        }
        if ([string isEqualToString:@"fail"]) {
            if ([self.refreshBtn.titleLabel.text isEqualToString:@"Loading..."]) {
                [self loadMoreWithBool:NO];
            }
            [SVProgressHUD showErrorWithStatus:@"Alerts data is not available now. Please try later!"];
        }else{
            NSLog(@"%@",string);
            NSDictionary *dataDic = [string JSONValue];
            if ([dataDic isKindOfClass:[NSDictionary class]])
            {
                _totalCount = [[dataDic objectForKey:@"alertSize"] integerValue];
                NSArray *tempArray = [dataDic objectForKey:@"alertList"];
                switch (load_type) {
                    case ALERT_LOAD_TYPE_INIT:
                        [self.alerts removeAllObjects];
                        for (NSDictionary *tempAlert in tempArray){
                            MyEAlert *alert = [[MyEAlert alloc] initWithDictionary:tempAlert];
                            [self.alerts addObject:alert];
                        }
                            _pageIndex = 1;
                        break;
                    case ALERT_LOAD_TYPE_PULL_REFRESH:
                        [self loadMoreWithBool:NO];
                        if(tempArray.count > 0)
                            _pageIndex = 0;
                        [self.alerts removeAllObjects];
                        for (NSDictionary *tempAlert in tempArray){
                            MyEAlert *alert = [[MyEAlert alloc] initWithDictionary:tempAlert];
                            [self.alerts addObject:alert];
                        }
                        _pageIndex = 1;
                        if ([self.refreshBtn.titleLabel.text isEqualToString:@"Load More"]) {
                            [self.refreshBtn setTitle:@"Load More" forState:UIControlStateNormal];
                        }
                        break;
                    case ALERT_LOAD_TYPE_DRAG_LOADMORE:
                        if ([self.refreshBtn.titleLabel.text isEqualToString:@"Loading..."]) {
                            [self loadMoreWithBool:NO];
                        }
                        if ([tempArray count]) {
                        for (NSDictionary *tempAlert in tempArray){
                            MyEAlert *alert = [[MyEAlert alloc] initWithDictionary:tempAlert];
                            [self.alerts addObject:alert];
                        }
          //              if(tempArray.count == ALERT_COUNT_PER_PAGE)
                            _pageIndex ++;
                        }else
                            [self.refreshBtn setTitle:@"No more alerts" forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
                [self.tableView reloadData];
            }
        }
    }
    if([name isEqualToString:@"DeleteAlertUploader"]) {
        [HUD hide:YES];
        if ([string isEqualToString:@"fail"]) {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        } else {
            NSIndexPath *indexPath = (NSIndexPath *)dict[@"indexPath"];
            [self.alerts removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            _totalCount --;
        }
        
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                  message:@"Communication error. Please try again."
                                                 delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [alert show];
    NSLog(@"Connection of %@ failed! Error - %@ %@",name,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    if ([self.refreshBtn.titleLabel.text isEqualToString:@"Loading..."]) {
        [self loadMoreWithBool:NO];
    }
    [HUD hide:YES];
}
#pragma mark - UIAlertView delegate methods
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Confirm"] && buttonIndex == 0) {
        [self deleteAlertFromServerAtRow:alertView.tag];
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
    [self downloadModelForType:ALERT_LOAD_TYPE_PULL_REFRESH withPageIndex:0 andCount:ALERT_COUNT_PER_PAGE];
}
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return _isRefreshing;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}
@end