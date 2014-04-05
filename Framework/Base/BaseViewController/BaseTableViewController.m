//
//  BaseTableViewController.m
//  FinalFantasy
//
//  Created by space bj on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseTableViewController.h"


#define LOADINGVIEW_HEIGHT 44
#define REFRESHINGVIEW_HEIGHT 88

@implementation BaseTableViewController

@synthesize currentSelectedIndex;

@synthesize datas;
@synthesize tableView;

@synthesize refreshHeaderView;
@synthesize loadMoreFooterView;

@synthesize isRefreshing;
@synthesize loadingmore;

-(void) dealloc
{
    [datas release];
    [tableView release];
    
    [refreshHeaderView release];
    [loadMoreFooterView release];
    
    [super dealloc];
}

#pragma -
#pragma EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (loadingmore || isLoadingData) 
    {
        return;
    }
    
    isRefreshing = YES;
    
    [self sendGetDatas];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return isRefreshing;
}


#pragma -
#pragma LoadMoreTableFooterDelegate

- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view
{
    if (isRefreshing || isLoadingData)
    {
        return;
    }
    
    loadingmore = YES;
    [self getMore];
}

- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view
{
    return loadingmore;
}

#pragma 下拉刷新数据加载完成
-(void) headerFinish
{
    isRefreshing = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

-(void) footerFinish
{
    if(loadingmore)
    {
        loadingmore = NO;
        [loadMoreFooterView loadMoreScrollViewDataSourceDidFinishedLoading:self.tableView];
    }    
}


#pragma -下拉刷新
-(void) sendGetDatas
{
    
}

#pragma -获取更多

-(void) getMore
{
    
}


#pragma －
#pragma 返回按钮回调

-(void) leftButtonItemClickBackCall
{
    [super leftButtonItemClickBackCall];
    self.loadMoreFooterView.delegate = nil;
    self.refreshHeaderView.delegate = nil;
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    if (isLoadMoreFooterViewEnable) 
    {
        [loadMoreFooterView loadMoreScrollViewDidScroll:scrollView];		
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
    if (isLoadMoreFooterViewEnable) 
    {
        [loadMoreFooterView loadMoreScrollViewDidEndDragging:scrollView];	
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if (self.tableView == nil)
//    {
//        UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//        
//        self.tableView = tempTableView;
//        [tempTableView release];
//        
//        [self.view addSubview:tempTableView]; 
//    }
}

-(void) initHeaderView:(id<EGORefreshTableHeaderDelegate>) delegate
{
    EGORefreshTableHeaderView *temp = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    temp.delegate = delegate;
    self.refreshHeaderView = temp;
    [temp release];
    
    [self.tableView addSubview:self.refreshHeaderView];
    self.isRefreshing = NO;
}

-(void) initFooterView:(id<LoadMoreTableFooterDelegate>) delegate
{    
    LoadMoreTableFooterView *tempMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    tempMoreView.delegate = delegate;
    self.loadMoreFooterView = tempMoreView;
    [tempMoreView release];
    
    isLoadMoreFooterViewEnable = YES;
    self.loadMoreFooterView.hidden = YES;
    
    [self.tableView insertSubview:self.loadMoreFooterView atIndex:0];
    self.loadingmore = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (isLoadMoreFooterViewEnable)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (isLoadMoreFooterViewEnable)
    {
        CGFloat Y = self.tableView.contentSize.height >= self.tableView.bounds.size.height ? self.tableView.contentSize.height : self.tableView.bounds.size.height;
        self.loadMoreFooterView.frame = CGRectMake(0.0f, Y, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
        if (isLoadMoreFooterViewEnable)
        {
            self.loadMoreFooterView.hidden = NO;
        }
        
        UIView *uiview = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        
        return uiview;
    }
    else
    {
        return nil;
    }
}

#pragma mark -
#pragma mark LoadMoreTableFooterDelegate Methods

//- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view 
//{
//    loadingmore = YES;
//	//[self reloadTableViewDataSource];
//	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
//    
//}
//
//- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view 
//{
//	return loadingmore;
//}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

//- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
//{
//    self.isRefreshing = YES;
//    
//    //currentPage = 1;
//    //[self performSelector:@selector(reloadData) withObject:self afterDelay:1.0f];  //make a delay to show loading process for a while
//}
//
//- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
//{
//	return YES; // should return if data source model is reloading
//}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
