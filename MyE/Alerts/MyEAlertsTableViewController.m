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
#import "MyEAlertDetailViewController.h"

#define ALERT_COUNT_PER_PAGE  20

@interface MyEAlertsTableViewController ()
-(void)goHome;
-(void) deleteAlertFromServerAtRow:(NSInteger)row;
- (void) downloadModelFromServer;

// type:0 init load when enter this VC at first time
// type:1 pull down to refresh
// type:3 drag up to load more
-(void) downloadModelForType:(ALERT_LOAD_TYPE)type withPageIndex:(NSInteger)index andCount:(NSInteger)count;
@end

@implementation MyEAlertsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setDragDelegate:self refreshDatePermanentKey:@"AlertList"];
    
    self.alerts = [NSMutableArray array];
    _pageIndex = -1;
    _totalCount = 0;
    
    if(!self.fromHome){
        // Change button color
        _sidebarButton.tintColor = [UIColor colorWithWhite:0.3f alpha:0.82f];
        
        // Set the side bar button action. When it's tapped, it'll show up the sidebar.
        _sidebarButton.target = self.revealViewController;
        _sidebarButton.action = @selector(revealToggle:);
        
        // Set the gesture
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @"Home"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(goHome)];
        self.navigationItem.backBarButtonItem = backButton;
    }
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(refreshAction)];
    self.parentViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton, nil];
    
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
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
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"godetail"]) {
        MyEAlertDetailViewController *vc = segue.destinationViewController;
        NSInteger index = self.tableView.indexPathForSelectedRow.row;
        vc.alert = self.alerts[index];
    }
}



- (void)refreshAction
{
    [self downloadModelFromServer];
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
        self.tableView.footerLoadingText = @"Loading...";
        if( self.alerts.count >= _totalCount){
            self.tableView.footerLoadingText = @"No more available";
            [self.tableView performSelector:@selector(finishLoadMore) withObject:nil afterDelay:2];
            return;
        }
    }
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?page_index=%d&page_size=%d",GetRequst(URL_FOR_ALERTS_VIEW),index, count];
    NSLog(@"urlStr=%@", urlStr);
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"AlertsDownloader"  userDataDictionary:@{@"load_type":@(type)}];
    NSLog(@"AlertsDownloader is %@",downloader.name);
}
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict
{
    if([name isEqualToString:@"AlertsDownloader"]) {
        NSInteger load_type = [dict[@"load_type"] integerValue];
        if(load_type == ALERT_LOAD_TYPE_INIT)
            [HUD hide:YES];
        
        if ([string isEqualToString:@"fail"]) {
            [SVProgressHUD showErrorWithStatus:@"Alerts data is not available now. Please try later!"];
        } else {
            NSLog(@"%@",string);
            NSDictionary *dataDic = [string JSONValue];
            if ([dataDic isKindOfClass:[NSDictionary class]])
            {
                _totalCount = [[dataDic objectForKey:@"alertSize"] integerValue];
                NSArray *tempArray = [dataDic objectForKey:@"alertList"];
                switch (load_type) {
                    case ALERT_LOAD_TYPE_INIT:
                    case ALERT_LOAD_TYPE_PULL_REFRESH:
                        if(tempArray.count > 0)
                            _pageIndex = 0;
                        [self.alerts removeAllObjects];
                        for (NSDictionary *tempAlert in tempArray){
                            MyEAlert *alert = [[MyEAlert alloc] initWithDictionary:tempAlert];
                            [self.alerts addObject:alert];
                        }
                        [self finishRefresh];
                        break;
                    case ALERT_LOAD_TYPE_DRAG_LOADMORE:
                    default:
                        for (NSDictionary *tempAlert in tempArray){
                            MyEAlert *alert = [[MyEAlert alloc] initWithDictionary:tempAlert];
                            [self.alerts addObject:alert];
                        }
                        if(tempArray.count == ALERT_COUNT_PER_PAGE)
                            _pageIndex ++;
                        [self finishLoadMore];
                        break;
                }
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
    
    // inform the user
    NSLog(@"Connection of %@ failed! Error - %@ %@",name,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [HUD hide:YES];
}
#pragma mark - UIAlertView delegate methods
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteAlertFromServerAtRow:alertView.tag];
    }
    
}
         
#pragma mark - Private Methods

-(void)goHome
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}



#pragma mark - Control datasource

- (void)finishRefresh
{
    [self.tableView finishRefresh];
    [self.tableView reloadData];
}

- (void)finishLoadMore
{
    [self.tableView finishLoadMore];
    [self.tableView reloadData];
}

#pragma mark - Drag delegate methods

- (void)dragTableDidTriggerRefresh:(UITableView *)tableView
{
    //send refresh request(generally network request) here
    [self downloadModelForType:ALERT_LOAD_TYPE_PULL_REFRESH withPageIndex:0 andCount:ALERT_COUNT_PER_PAGE];
    
}

- (void)dragTableRefreshCanceled:(UITableView *)tableView
{
    //cancel refresh request(generally network request) here
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishRefresh) object:nil];
}

- (void)dragTableDidTriggerLoadMore:(UITableView *)tableView
{
    //send load more request(generally network request) here

    [self downloadModelForType:ALERT_LOAD_TYPE_DRAG_LOADMORE withPageIndex:_pageIndex+1 andCount:ALERT_COUNT_PER_PAGE];

}

- (void)dragTableLoadMoreCanceled:(UITableView *)tableView
{
    //cancel load more request(generally network request) here
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishLoadMore) object:nil];
}
@end