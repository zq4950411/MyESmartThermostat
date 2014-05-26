//
//  MyEEventListViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventListViewController.h"
#import "MyEEventAddOrEditViewController.h"
@interface MyEEventListViewController (){
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    NSIndexPath *_selectIndex;
}

@end

@implementation MyEEventListViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    /*---------------------UI 更新------------------------*/
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        refreshView.delegate = self;
        [self.tableView addSubview:refreshView];
        _refreshHeaderView = refreshView;
    }
     [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
    
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.36f alpha:0.82f];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    /*---------------------更新数据----------------------------*/
    [self downloadInfoFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)applyScene:(UIButton *)sender{
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    _selectIndex = indexPath;
    NSLog(@"selecet row is %i",indexPath.row);
    MyEEventInfo *info = self.events.scenes[indexPath.row];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:99];
    act.hidden = NO;
    sender.hidden = YES;
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&sceneName=%@&type=%i&sortFlag=%i&action=applyScene",GetRequst(URL_FOR_SCENES_SAVE_SCENE),MainDelegate.houseData.houseId,info.sceneId,info.sceneName,info.type,0] postData:nil delegate:self loaderName:@"apply" userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}
#pragma mark - IBAction methods
- (IBAction)addNewScene:(UIBarButtonItem *)sender {
    MyEEventAddOrEditViewController *vc = [[UIStoryboard storyboardWithName:@"Event" bundle:nil] instantiateViewControllerWithIdentifier:@"event"];
    vc.eventInfo = [[MyEEventInfo alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - URL Delegate methods
-(void)downloadInfoFromServer{
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i",GetRequst(URL_FOR_SCENES_LIST),MainDelegate.houseData.houseId] postData:nil delegate:self loaderName:@"sceneList" userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.events.scenes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *string = nil;
    MyEEventInfo *event = self.events.scenes[indexPath.row];
    string = event.type == 0?@"conditionCell":@"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:string forIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:100];
    [btn addTarget:self action:@selector(applyScene:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:101];
    name.text = event.sceneName;
    UIImageView *imgTime = (UIImageView *)[cell.contentView viewWithTag:102];
    imgTime.hidden = event.timeTriggerFlag == 1?NO:YES;
    UIImageView *imgWeather = (UIImageView *)[cell.contentView viewWithTag:103];
    imgWeather.hidden = event.conditionTriggerFlag == 1?NO:YES;
    UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:99];
    if (!act.hidden) {
        act.hidden = YES;
    }
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyEEventAddOrEditViewController *vc = [[UIStoryboard storyboardWithName:@"Event" bundle:nil] instantiateViewControllerWithIdentifier:@"eventDetail"];
    vc.eventInfo = self.events.scenes[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - MYEDataLoader delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is  %@",string);
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([name isEqualToString:@"sceneList"]) {
        if (![string isEqualToString:@"fail"]) {
            MyEEvents *events = [[MyEEvents alloc] initWithJsonString:string];
            self.events = events;
            [self.tableView reloadData];
        }
    }
    if ([name isEqualToString:@"apply"]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectIndex];
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:100];
        UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:99];
        btn.hidden = NO;
        act.hidden = YES;
        if (string.intValue == -999) {
            [SVProgressHUD showErrorWithStatus:@"NO Connection"];
        }else if (![string isEqualToString:@"fail"]){
            
        }else
            [SVProgressHUD showErrorWithStatus:@"Error"];
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
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return _isRefreshing;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}
@end
