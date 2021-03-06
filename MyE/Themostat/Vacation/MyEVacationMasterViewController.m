//
//  MyEVacationMasterViewController.m
//  MyE
//
//  Created by Ye Yuan on 2/23/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MyEVacationMasterViewController.h"
#import "MyEVacationListData.h"
#import "MyEVacationItemData.h"
#import "MyEStaycationItemData.h"
#import "MyEVacationTableViewCell.h"
#import "MyEStaycationTableViewCell.h"
#import "MyEVacationDetailViewController.h"
#import "MyEStaycationDetailViewController.h"
#import "MyEAccountData.h"
#import "MyEHouseListViewController.h"
#import "MyEUtil.h"
#import "SBJson.h"

#import "MyETerminalData.h"
#import "MyEHouseData.h"


#define VACATION_DOWNLOADER_NMAE @"VacationsDownloader"
#define VACATION_UPLOADER_NMAE @"VacationsUploader"

@interface MyEVacationMasterViewController(PrivateMethods)

@end

@implementation MyEVacationMasterViewController
@synthesize vacationsModel = _vacationsModel;
@synthesize userId = _userId;
@synthesize houseId = _houseId;
@synthesize houseName = _houseName;
@synthesize tId = _tId;
@synthesize tName = _tName;
@synthesize isRemoteControl = _isRemoteControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = bgView;
    //设置面板背景为一个纹理图片
//    UIColor *bgcolor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgpattern.png"]];
    // 设置面板背景为一个纯色
    UIColor *bgcolor = [UIColor colorWithWhite:248.0/255.0 alpha:1.0];
    [self.tableView setBackgroundColor:bgcolor];
    
    
    
    self.vacationsModel = [[MyEVacationListData alloc] initWithJSONString:@"{\"houseId\":1028,\"userId\":1000100000000000317,\"vacations\":[]}"];    
    [self.tableView reloadData];//重新加载数据,这一步骤是重要的，用来现实更新后的数据。

    
    self.isRemoteControl = MainDelegate.terminalData.remote;
    self.navigationController.title = MainDelegate.houseData.houseName;
    MainDelegate.window.rootViewController.title=MainDelegate.houseData.houseName;
    
    
    //初始化下拉视图
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self downloadModelFromServer];
}

- (void) addRightButtonsWithNewButton:(BOOL)shouldGenerateNewButton
{
    //首先去掉父容器TabBarController的navigationItem的右边按钮
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    //可以用下面语句生成2个新button，并替换掉父容器TabBarController的navigationItem的右边按钮
    UIBarButtonItem *addButton = nil;
    if (shouldGenerateNewButton)
    {
        addButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                  target:self 
                                  action:@selector(addNewVacation:)];
    }
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                      target:self 
                                      action:@selector(refreshAction:)];
    self.parentViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton, addButton, nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowVacationDetailView"]) {
        if ([sender isKindOfClass:[UIBarButtonItem class]])//如果本segue是由点击导航条右上角的add new按钮所激发的
        {
            MyEVacationDetailViewController *detailViewController = [segue destinationViewController];
            detailViewController.delegate = self;
            detailViewController.editType = 1;//设置编辑类型是新增。
            detailViewController.vacationItem = [[MyEVacationItemData alloc] init];
        } else {//如果本segue是由点击列表的vacation条目所激发的
            MyEVacationDetailViewController *detailViewController = [segue destinationViewController];
            detailViewController.delegate = self;
            detailViewController.editType = 0;//设置编辑类型是修改。
            detailViewController.vacationItem = (MyEVacationItemData *)[self.vacationsModel objectInListAtIndex:[self.tableView indexPathForSelectedRow].row];
            
            [detailViewController setEditable: self.isRemoteControl];
        }
    }
    if ([[segue identifier] isEqualToString:@"ShowStaycationDetailView"]) {
        MyEStaycationDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.delegate = self;
        detailViewController.editType = 0;//设置编辑类型是修改。
        detailViewController.staycationItem = (MyEStaycationItemData *)[self.vacationsModel objectInListAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        [detailViewController setEditable: self.isRemoteControl];
    }
}
-(void) setIsRemoteControl:(BOOL)isRemoteControl {
    _isRemoteControl = isRemoteControl;
    [self addRightButtonsWithNewButton:self.isRemoteControl];
}

#pragma mark
#pragma mark private methods
- (void) addNewVacation:(id)sender {
    NSLog(@"Vacation add new button is taped");
    [self performSegueWithIdentifier:@"ShowVacationDetailView" sender:sender];
}

- (void) refreshAction:(id)sender {
    [self downloadModelFromServer];
}

#pragma mark -
#pragma mark URL Loading System methods
- (void) downloadModelFromServer
{
    if (!_isRefreshing) {
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.delegate = self;
        } else
            [HUD show:YES];
    }
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_VACATION_VIEW), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.terminalData.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:VACATION_DOWNLOADER_NMAE  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}


// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }else {
        [HUD hide:YES];
    }
    
    NSLog(@"Vacations JSON String from server is \n%@",string);
    if([name isEqualToString:VACATION_DOWNLOADER_NMAE]) {
       
        // 获得today model
        MyEVacationListData *vacationsModel = [[MyEVacationListData alloc] initWithJSONString:string]; 
        if (vacationsModel) {
            self.vacationsModel = vacationsModel; 
            
            NSLog(@"解析后的Vacations是： \n%@", [[self.vacationsModel JSONDictionary] JSONRepresentation]);
            
            [self.tableView reloadData];//重新加载数据,这一步骤是重要的，用来现实更新后的数据。
            
            //刷新远程控制的状态。
            self.isRemoteControl = [vacationsModel.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame;
        }else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                          message:@"Communication error. Please try again."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    } else if ([name isEqualToString:VACATION_UPLOADER_NMAE]) {

        NSString *action = [dict objectForKey:@"action"];
        if([action isEqualToString:@"delete"]) {
            //注意删除操作，成功后用程序来更新数据模型和列表view显示，而没有使用直接从服务器下载更新整个数据的办法，
            // 其实这个下载更新的办法可能来的更简单，就是网络流量稍大一点
            if ([string isEqualToString:@"OK"]) {
                // 根据用户词典里记录的信息，这里才真是从model里和table view里面删除刚才用户要删除的vacation
                UITableView *tableView = [dict objectForKey:@"tableView"];
                NSIndexPath *indexPath = [dict objectForKey:@"indexPath"];
                [self.vacationsModel removeObjectAtIndex:[indexPath row]];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                              message:string
                                                             delegate:self 
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
                [alert show];
            }
        }
        if([action isEqualToString:@"edit"] || [action isEqualToString:@"add"]) {
            if ([string isEqualToString:@"OK"]) {
                [self downloadModelFromServer];
            } else {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                              message:string
                                                             delegate:self 
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:VACATION_DOWNLOADER_NMAE])
        msg = @"Communication error. Please try again.";
    else msg = @"Communication error. Please try again.";
        
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                  message:msg
                                                 delegate:self 
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [alert show];
    [HUD hide:YES];
}

//用户词典userDataDictionary仅用于保存用户数据的，将来异步加载完成后，会把这个数据返回给用户，
//用可以可以根据此数据里面的值知道此加载器进行了刚才是用来干什么的，从而可以进行下一步动作
- (void) uploadToServerWithString:(NSString *)string action:(NSString *)action userDataDictionary:(NSDictionary *)dict
{
    ///////////////////////////////////////////////////////////////////////
    // Demo 用户登录
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [prefs objectForKey:@"username"];
    
    if (username != nil && [username caseInsensitiveCompare:@"demo"] == NSOrderedSame) // 如果是demo账户
        return;
    ///////////////////////////////////////////////////////////////////////
    

    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSLog(@"上传给服务器的vacations字符串是：\n%@", string);
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@&action=%@",GetRequst(URL_FOR_VACATION_SAVE), MainDelegate.accountData.userId,MainDelegate.houseData.houseId,MainDelegate.terminalData.tId, action];
    
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:string delegate:self loaderName:VACATION_UPLOADER_NMAE userDataDictionary:dict];
    NSLog(@"uploader is %@",uploader.name);
}

#pragma mark -
#pragma mark MyEVacationDetailViewControllerDelegate, MyEStaycationDetailViewControllerDelegate methods
- (void) didFinishEditVacation:(MyEVacationItemData *)newVacationItem  editType:(int)editType{
    if(editType == 0){
        NSLog(@"\n完成vacation 修改，之后的vacation是\n%@", [[newVacationItem JSONDictionary] JSONRepresentation]);
        [self uploadToServerWithString:[NSString stringWithFormat:@"vacation=%@", [[newVacationItem JSONDictionary] JSONRepresentation]] action:@"edit" userDataDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"edit",@"action",nil]];
    }
    else if(editType == 1){
        NSLog(@"\n完成vacation 新增，新的vacation是\n%@", [[newVacationItem JSONDictionary] JSONRepresentation]);
        [self uploadToServerWithString:[NSString stringWithFormat:@"vacation=%@", [[newVacationItem JSONDictionary] JSONRepresentation]] action:@"add" userDataDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"add",@"action",nil]];
        
    }else if(editType == 2){
        NSLog(@"\n准备删除，vacation是\n%@", [[newVacationItem JSONDictionary] JSONRepresentation]);
        NSString *string = [NSString stringWithFormat:@"vacation=%@",[[newVacationItem JSONDictionary]JSONRepresentation]];
        
        //记录下本来需要执行上传删除指令的相关变量，然后显示提示，如果用户点击YES后，再在提示的毁掉函数里面执行现在的删除指令
        _uploadString = string;
        _actionString = @"delete";
        _userDataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:_tableView, @"tableView", _indexPath, @"indexPath", @"delete",@"action",nil];
        [self uploadToServerWithString:_uploadString action:_actionString userDataDictionary:_userDataDictionary];
        
    }
}

- (void) didFinishEditStaycation:(MyEStaycationItemData *)newStaycationItem  editType:(int)editType{
    if(editType == 0){
        NSLog(@"\n完成Staycation修改，之后的staycation是\n%@", [[newStaycationItem JSONDictionary] JSONRepresentation]);
        [self uploadToServerWithString:[NSString stringWithFormat:@"vacation=%@", [[newStaycationItem JSONDictionary] JSONRepresentation]] action:@"edit" userDataDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"edit",@"action",nil]];
    }
    else  if(editType == 1){ 
        NSLog(@"\n完成Staycation新增，新的staycation是\n%@", [[newStaycationItem JSONDictionary] JSONRepresentation]);
        [self uploadToServerWithString:[NSString stringWithFormat:@"vacation=%@", [[newStaycationItem JSONDictionary] JSONRepresentation]] action:@"add" userDataDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"add",@"action",nil]];

    }else if(editType == 2){
        NSLog(@"\n准备删除，staycation是\n%@", [[newStaycationItem JSONDictionary] JSONRepresentation]);
        NSString * string = [NSString stringWithFormat:@"vacation=%@",[[newStaycationItem JSONDictionary]JSONRepresentation]];
        
        //记录下本来需要执行上传删除指令的相关变量，然后显示提示，如果用户点击YES后，再在提示的毁掉函数里面执行现在的删除指令
        _uploadString = string;
        _actionString = @"delete";
        _userDataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:_tableView, @"tableView", _indexPath, @"indexPath", @"delete",@"action",nil];
        [self uploadToServerWithString:_uploadString action:_actionString userDataDictionary:_userDataDictionary];
    }
    
}


#pragma mark -
#pragma mark UITableViewController & data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.vacationsModel countOfList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    
    
    
    
    NSObject *item = [self.vacationsModel objectInListAtIndex:indexPath.row];
    if([item isKindOfClass:[MyEVacationItemData class]]) {
        static NSString *CellIdentifier = @"VacationCell";
        
        MyEVacationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        MyEVacationItemData *vacation = ((MyEVacationItemData *)item);
        [[cell nameLabel] setText:vacation.name];
        [[cell leaveDateLabel] setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:vacation.leaveDateTime]]];
        
        return cell;
    }
    if([item isKindOfClass:[MyEStaycationItemData class]]) {
        static NSString *CellIdentifier = @"StaycationCell";
        
        MyEStaycationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        MyEStaycationItemData *staycation = ((MyEStaycationItemData *)item);
        [[cell nameLabel] setText:staycation.name];
        [[cell startDateLabel] setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:staycation.startDate]]];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"点击了删除");
        NSString *string;
        NSObject *item = [self.vacationsModel objectInListAtIndex:indexPath.row];
        if([item isKindOfClass:[MyEVacationItemData class]]) {
            MyEVacationItemData *vacation = ((MyEVacationItemData *)item);
            string = [NSString stringWithFormat:@"vacation=%@",[[vacation JSONDictionary]JSONRepresentation]];
        }
        if([item isKindOfClass:[MyEStaycationItemData class]]) {
            MyEStaycationItemData *staycation = ((MyEStaycationItemData *)item);
            string = [NSString stringWithFormat:@"vacation=%@",[[staycation JSONDictionary]JSONRepresentation]];
        }
        
        //原来直接执行下面的删除指令，向服务器发送删除请求，下载修改成需要显示提示，经用户确认后才能执行删除指令
//        [self uploadToServerWithString:string action:@"delete" userDataDictionary:[NSDictionary dictionaryWithObjectsAndKeys:tableView, @"tableView", indexPath, @"indexPath", @"delete",@"action",nil]];
        
        //记录下本来需要执行上传删除指令的相关变量，然后显示提示，如果用户点击YES后，再在提示的毁掉函数里面执行现在的删除指令
        _uploadString = string;
        _actionString = @"delete";
        _userDataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:tableView, @"tableView", indexPath, @"indexPath", @"delete",@"action",nil];
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Delete" 
                                                      message:@"Are you sure you want to delete this item?"
                                                     delegate:self 
                                            cancelButtonTitle:@"YES"
                                            otherButtonTitles:@"NO",nil];
        [alert show];

        
        
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSLog(@"点击了Insert");
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    NSLog(@"手指撮动了");
    if (self.isRemoteControl) {
        return UITableViewCellEditingStyleDelete;
    } else return UITableViewCellEditingStyleNone;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  @"Delete";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //设置单元格的背景
    [cell setBackgroundColor:[UIColor whiteColor]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 下面两个变量用于在detail面板删除条目时，返回本MyEVacationMasterView后进行删除，需要记录表格中对应的项目的位置，以便更新表格
    // 每次用户点击一个条目时、进入detail之前，就要记录下面两个变量
    _tableView = tableView;//这个其实不用记录，就是本VC中惟一的tableView
    _indexPath = indexPath;
}
#pragma mark -
-(void)alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(int)index
{
    //显示提示，如果用户点击YES后，再在提示的回调函数里面执行现在的删除指令
    if([alertView.title isEqualToString:@"Delete"] && index == 0) {
        [self uploadToServerWithString:_uploadString action:_actionString userDataDictionary:_userDataDictionary];
    }
}
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
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
