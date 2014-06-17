//
//  MyESettingsViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESettingsViewController.h"
#import "MyETimeZoneViewController.h"
#import "MyEMediatorRegisterViewController.h"
#import "MyELaunchIntroViewController.h"

@interface MyESettingsViewController (){
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    BOOL _hasGateWay;  //YES表示网关绑定，NO表示网关解绑
    NSInteger _nofiStatus;
    MBProgressHUD *HUD;
}

@end

@implementation MyESettingsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadInfoFromServer];
    }else{
        [self refreshUI];
        [self.tableView reloadData];
    }
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
    [self.deleteMBtn setStyleType:ACPButtonOK];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
- (IBAction)changeNoti:(UISwitch *)sender {
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?deviceType=0&deviceAlias=%@&notification=%i",GetRequst(MORE_SAVE_NOTIFICATION),[OpenUDID value], sender.isOn?1:0] andName:@"set"];
}
- (IBAction)deleteOrBindM:(ACPButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Remove the Gateway"]) {
        [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&mid=%@",GetRequst(SETTING_DELETE_GATEWAY),MainDelegate.houseData.houseId,self.info.mid] andName:@"deleteM"];
    }else{
        MyEMediatorRegisterViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"registerGateway"];
        vc.jumpFromNav = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - private methods
-(void)refreshUI{
    self.userNameLbl.text = MainDelegate.accountData.userName;
    [self.notiSwitch setOn:YES animated:YES];
    self.terminalCountLbl.text = [NSString stringWithFormat:@"%i",self.info.terminals.count];
    self.midLbl.text = self.info.mid;
    self.houseLbl.text = self.info.houseName;
    self.timeZoneLbl.text = [self.info timeZoneArray][self.info.timeZone - 1];
}
-(void)downloadInfoFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?deviceType=0&deviceAlias=%@",GetRequst(MORE_NOTIFICATION),[OpenUDID value]] andName:@"noti"];
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i",GetRequst(SETTING_FIND_GATEWAY),MainDelegate.houseData.houseId] andName:@"downloadInfo"];
}
-(void)upOrDownloadInfoWithURL:(NSString *)url andName:(NSString *)name{
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 3) {
        if (_hasGateWay) {
            [self.deleteMBtn setTitle:@"Remove the Gateway" forState:UIControlStateNormal];
            return 4;
        }else{
            [self.deleteMBtn setTitle:@"Bind the Gateway" forState:UIControlStateNormal];
            return 1;
        }
    };
    if (section == 4) {
        return 2;
    }
    return 1;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3 && indexPath.row == 3) {
        MyETimeZoneViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"timeZone"];
        vc.timeZone = self.info.timeZone;
        vc.info = self.info;
        vc.jumpFromSettingPanel = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 4 && indexPath.row == 0) {
        MyELaunchIntroViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"launchinfo"];
        vc.jumpFromSettingPanel = YES;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Navigation delegate methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"terminals"]) {
        UIViewController *vc = segue.destinationViewController;
        [vc setValue:self.info forKey:@"info"];
    }
}
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([name isEqualToString:@"downloadInfo"]) {
        [HUD hide:YES];
        if (![string isEqualToString:@"fail"]) {
            MyESettingsInfo *info = [[MyESettingsInfo alloc] initWithJsonString:string];
            self.info = info;
            if ([self.info.mid isEqualToString:@""]) {
                _hasGateWay = NO;
            }else
                _hasGateWay = YES;
            [self refreshUI];
            [self.tableView reloadData];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }
    if ([name isEqualToString:@"noti"]) {
        if (string.intValue == 1) {
            _nofiStatus = 1;
            [self.notiSwitch setOn:YES animated:YES];
        }else if (string.intValue == 0){
            _nofiStatus = 0;
            [self.notiSwitch setOn:NO animated:YES];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }
    if ([name isEqualToString:@"set"]) {
        if ([string isEqualToString:@"OK"]) {
            _nofiStatus = 1- _nofiStatus;
        }else{
            [self.notiSwitch setOn:_nofiStatus animated:YES];
            [SVProgressHUD showErrorWithStatus:@"fail"];
        }
    }
    if ([name isEqualToString:@"deleteM"]) {
        if ([string isEqualToString:@"OK"]) {
            _hasGateWay = NO;
            [self refreshUI];
            [self.tableView reloadData];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
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
    [self downloadInfoFromServer];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}
@end