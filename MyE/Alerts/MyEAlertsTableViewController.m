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

@interface MyEAlertsTableViewController ()
-(void) deleteAlertFromServerAtRow:(NSInteger)row;
- (void) downloadModelFromServer;
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
    self.alerts = [NSMutableArray array];
    
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

    
    
    //初始化下拉视图
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
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
- (void) downloadModelFromServer
{
    if (!_isRefreshing) {
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.delegate = self;
        } else
            [HUD show:YES];
    }

    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@",GetRequst(URL_FOR_ALERTS_VIEW), MainDelegate.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"AlertsDownloader"  userDataDictionary:nil];
    NSLog(@"AlertsDownloader is %@",downloader.name);
}
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict
{
    
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }else {
        [HUD hide:YES];
    }


    if([name isEqualToString:@"AlertsDownloader"]) {
        if ([string isEqualToString:@"fail"]) {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        } else {
//            string = @"{\"alertList\":[{\"id\":1,\"new_flag\":1,\"title\":\"title 1133\",\"content\":\"xxxxxxxxxxxxxxxxxxxxxx\",\"publish_date\":\"4:45pm 4/49/2014\"},{\"id\":2,\"new_flag\":1,\"title\":\"title abc\",\"content\":\"yyyyyyyyyyyyyyyyuu\\ndfd bobok\\n \" ,\"publish_date\":\"4:45pm 4/49/2014\"},{\"id\":3,\"new_flag\":0,\"title\":\"ok test\",\"content\":\"xxxxxxxxxxx\\nxxxxxxx tews tab\\txxxx\\nttest hellow new \" ,\"publish_date\":\"4:45pm 4/49/2014\"}]}";
            NSDictionary *dataDic = [string JSONValue];
            if ([dataDic isKindOfClass:[NSDictionary class]])
            {
                NSArray *tempArray = [dataDic objectForKey:@"alertList"];
                for (NSDictionary *tempAlert in tempArray){
                    MyEAlert *alert = [[MyEAlert alloc] initWithDictionary:tempAlert];
                    [self.alerts addObject:alert];
                }
                [self.tableView reloadData ];
            }
        }
        
    }
    if([name isEqualToString:@"DeleteAlertUploader"]) {
        if ([string isEqualToString:@"fail"]) {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        } else {
            NSIndexPath *indexPath = (NSIndexPath *)dict[@"indexPath"];
            [self.alerts removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    [self downloadModelFromServer];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}
@end
