//
//  BaseTableViewController.h
//  FinalFantasy
//
//  Created by space bj on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseNetViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"


@interface BaseTableViewController : BaseNetViewController <UIScrollViewDelegate,EGORefreshTableHeaderDelegate,LoadMoreTableFooterDelegate>
{
    NSMutableArray *datas;
    UITableView *tableView;
    
    LoadMoreTableFooterView *loadMoreFooterView; 
    EGORefreshTableHeaderView * refreshHeaderView;
    
    BOOL loadingmore;
    BOOL isRefreshing;
    
    //是否允许有效
    BOOL isLoadMoreFooterViewEnable;
    
    int currentSelectedIndex;
}

@property int currentSelectedIndex;

@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) IBOutlet UITableView *tableView;

@property(nonatomic,retain) LoadMoreTableFooterView *loadMoreFooterView; 
@property(nonatomic,readwrite) BOOL loadingmore;

@property(nonatomic, retain) EGORefreshTableHeaderView * refreshHeaderView;  //下拉刷新
@property(nonatomic, readwrite) BOOL isRefreshing;

-(void) initHeaderView:(id<EGORefreshTableHeaderDelegate>) delegate;
-(void) initFooterView:(id<LoadMoreTableFooterDelegate>) delegate;

-(void) headerFinish;
-(void) footerFinish;

//下拉刷新方法
-(void) sendGetDatas;

//获取更多
-(void) getMore;

@end
