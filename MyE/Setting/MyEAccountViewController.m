//
//  MyEAccountViewController.m
//  MyE
//
//  Created by 翟强 on 14-7-7.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEAccountViewController.h"
#import "MyEAccountData.h"
#import "MBProgressHUD.h"


@interface MyEAccountViewController (){
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    NSInteger _nofiStatus;
    MBProgressHUD *HUD;
}

@end

@implementation MyEAccountViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self refreshUI];
}
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
    
    [self downloadInfoFromServer];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

}
#pragma mark - IBAction methods
- (IBAction)changeNoti:(UISwitch *)sender {
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?deviceType=0&deviceAlias=%@&notification=%i",GetRequst(MORE_SAVE_NOTIFICATION),MainDelegate.alias, sender.isOn?1:0] andName:@"set"];
}
#pragma mark - private methods
-(void)refreshUI{
    self.userNameLbl.text = MainDelegate.accountData.userName;
    [self.notiSwitch setOn:_nofiStatus==1?YES:NO animated:YES];
    [self.tableView reloadData];
}
-(void)downloadInfoFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?deviceType=0&deviceAlias=%@",GetRequst(MORE_NOTIFICATION),MainDelegate.alias] andName:@"noti"];
}
-(void)upOrDownloadInfoWithURL:(NSString *)url andName:(NSString *)name{
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([name isEqualToString:@"noti"]) {
        [HUD hide:YES];
        if (string.intValue == 1) {
            _nofiStatus = 1;
        }else if (string.intValue == 0){
            _nofiStatus = 0;
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
        [self refreshUI];
    }
    if ([name isEqualToString:@"set"]) {
        if ([string isEqualToString:@"OK"]) {
            _nofiStatus = 1- _nofiStatus;
        }else{
            [self.notiSwitch setOn:_nofiStatus animated:YES];
            [SVProgressHUD showErrorWithStatus:@"fail"];
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
    [self downloadInfoFromServer];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}

@end
