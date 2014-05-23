//
//  MyEEventListViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventListViewController.h"
@interface MyEEventListViewController (){
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)addNewScene:(UIBarButtonItem *)sender {
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
    [btn addTarget:self action:@selector(downloadInfoFromServer) forControlEvents:UIControlEventTouchUpInside];
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:101];
    name.text = event.sceneName;
    UIImageView *imgTime = (UIImageView *)[cell.contentView viewWithTag:102];
    imgTime.hidden = event.timeTriggerFlag == 1?NO:YES;
    UIImageView *imgWeather = (UIImageView *)[cell.contentView viewWithTag:103];
    imgWeather.hidden = event.conditionTriggerFlag == 1?NO:YES;
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark - MYEDataLoader delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([name isEqualToString:@"sceneList"]) {
        if ([string isEqualToString:@"fail"]) {
            MyEEvents *events = [[MyEEvents alloc] initWithJsonString:string];
            self.events = events;
            [self.tableView reloadData];
        }
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
    
}
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return _isRefreshing;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}
@end
