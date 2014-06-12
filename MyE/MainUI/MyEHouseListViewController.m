//
//  MyEHouseListViewController.m
//  MyE
//
//  Created by Ye Yuan on 1/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEHouseListViewController.h"
#import "MyEDashboardViewController.h"
#import "MyEHouseListConnectedCell.h"
#import "MyEHouseListDisconnectedCell.h"
#import "MyEAccountData.h"
#import "MyEHouseData.h"
#import "MyETerminalData.h"
#import "MyEDashboardData.h"
#import "MyEUtil.h"
#import "SBJson.h"

#import "RegistGatewayViewController.h"
#import "ASDepthModalViewController.h"
#import "HouseBlankView.h"
#import "SWRevealViewController.h"
#import "MyEMainMenuViewController.h"
#import "MyEMediatorRegisterViewController.h"

@interface MyEHouseListViewController()

// selectedTabIndex变量原来是为SelectedTabBar protocol所定义的，定义在这里，但为了保证在ThermostatListViewController里面程序转移到新的tab后也能记住所进入的tab，就把此变量定义到类声明的地方，以便其他地方也可以访问。
@property (nonatomic) NSInteger selectedHouseId;

@end

@implementation MyEHouseListViewController
@synthesize accountData = _accountData;
@synthesize selectedTabIndex = _selectedTabIndex;
@synthesize selectedHouseId = _selectedHouseId;

@synthesize registerButton = _registerButton;

#pragma mark - View lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 隐藏backButton
    self.navigationItem.hidesBackButton = YES;
    
    //设置表格的背景
//    UIColor *bgcolor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgpattern.png"]];
//    [self.tableView setBackgroundColor:bgcolor];
    
    _hasLoadedDefaultHouseId = NO;
    
    [self.registerButton setStyleType:ACPButtonOK];
    [self.registerButton addTarget:self action:@selector(registeGateway:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.accountData.houseList.count == 0)
    {
        HouseBlankView *houseBlankView = [[[NSBundle mainBundle] loadNibNamed:@"HouseBlankView" owner:self options:nil] objectAtIndex:0];
        [ASDepthModalViewController presentView:houseBlankView backgroundColor:nil options:ASDepthModalOptionBlur completionHandler:nil];
    }
    else
    {
        BOOL b = NO;
        for (MyEHouseData *house in self.accountData.houseList)
        {
            b = [house isValid];
            if (b)
            {
                break;
            }
        }
        
        if (!b)
        {
            [self performSelector:@selector(goToRegister) withObject:nil afterDelay:0.5f];
        }
    }
    //初始化下拉视图
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadModelFromServer];
    }
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                      target:self 
                                      action:@selector(refreshAction)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [self.tableView reloadData];//重新加载数据,这一步骤是重要的，用来现实更新后的数据。
    
    NSArray *gestures = self.navigationController.navigationBar.gestureRecognizers;
    for (UIGestureRecognizer *gesture in gestures)
    {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
        {
            [self.navigationController.navigationBar removeGestureRecognizer:gesture];
        }
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!_hasLoadedDefaultHouseId) {// 如果是第一次出现这个house list 面板，就要从系统偏好里面取得是否由默认的houseId
        [self loadSettings];// 获取当前存储在系统偏好里的用户默认的houseId
        _hasLoadedDefaultHouseId = YES;
    }
}
#pragma mark - IBAction methods
- (IBAction)rememberChoice:(UIButton *)sender {
    sender.selected = !sender.selected;
}
- (IBAction)registerGateway:(ACPButton *)sender {
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:@"mediator"];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - private methods
-(void)loadSettings
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _defaultHouseId = [prefs integerForKey:@"defaulthouseid"];
    /*
     当用户在houselist view选择记住一个默认houseId后，就可以每次自动选择该house进入Dashboard面板，
     但当全部house的Thermostat都断开时，系统也进入Dashboard，然后系统从服务器下载新数据时发现房屋没有连接，
     就会回退到HouseList，但估计是由于刚刚从HouseList view转入Dashboar view，在事件执行调度顺序上的错误，
     系统没有回退到HouseList View，而是导航条已经回退了，但下面的内容面板还停留在Dashboard，
     此时再点击其他面板都异常退出。此时解决办法就是，在houselist面板上，如果所有house都断开时，
     不允许用默认的houseId进入Dashboard面板。
     
     
    if ( _defaultHouseId > 0 ) {
        [self performSegueWithIdentifier:@"ShowMainTabViewByDefaultHouseId" sender:self];
        
    }
     */
    MyEHouseData *defaultHouseData = [self.accountData houseDataByHouseId:_defaultHouseId];
    if (defaultHouseData.connection == 0 && defaultHouseData.mId != nil && ![defaultHouseData.mId isEqualToString:@""])
    {
        if ( defaultHouseData.terminals.count > 0 && [defaultHouseData.mId length] > 0 )
        {
            MyEHouseData *houseData;
            MyETerminalData *thermostatData;
            houseData = [self.accountData houseDataByHouseId:_defaultHouseId];
            MainDelegate.houseData = houseData;
            
            thermostatData = [houseData firstConnectedThermostat];
            MainDelegate.terminalData = thermostatData;
            
            //在NSDefaults里面记录这次要进入的房屋
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *tid = [prefs objectForKey:KEY_FOR_TID_LAST_VIEWED];
            for (MyETerminalData *temp in MainDelegate.houseData.terminals)
            {
                if ([tid isEqualToString:temp.tId])
                {
                    MainDelegate.terminalData = temp;
                    break;
                }
            }
            if (MainDelegate.terminalData == nil)
            {
                MainDelegate.terminalData = [MainDelegate.houseData firstConnectedThermostat];
            }
            
            //在NSDefaults里面记录这次要进入的房屋
            [prefs setInteger:houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
            [prefs setValue:thermostatData.tId forKey:KEY_FOR_TID_LAST_VIEWED];
            [prefs synchronize];
            
            if (self.selectedHouseId != houseData.houseId) {
                self.selectedTabIndex = 0;
                self.selectedHouseId = houseData.houseId;
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SWRevealViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuVC"];
            
            [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            MainDelegate.window.rootViewController = vc;
            
        }
    }
}

-(void)saveSettings:(NSInteger)defaultHouseId
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.rememberHouseIdBtn.selected) {
        [prefs setInteger:defaultHouseId  forKey:@"defaulthouseid"];
    }else {
        [prefs setInteger:-1  forKey:@"defaulthouseid"];
    }
    [prefs synchronize];
}
-(void) registeGateway:(UIButton *) sender
{
    RegistGatewayViewController *reg = [[RegistGatewayViewController alloc] init];
    [self.navigationController pushViewController:reg animated:YES];
}
-(void) goToRegister
{
    RegistGatewayViewController *reg = [[RegistGatewayViewController alloc] init];
    [self.navigationController pushViewController:reg animated:YES];
}
- (void)refreshAction
{
    [self downloadModelFromServer];
}

- (void) dimissAlert:(UIAlertView *)alert
{
    if(alert)
    {
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
    }
}

// the unit of delay is second
- (void)showAutoDisappearAlertWithTile:(NSString *)title message:(NSString *)message delay:(NSInteger)delay{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alert show];
    [self performSelector:@selector(dimissAlert:) withObject:alert afterDelay:delay];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
//    return [self.accountData countOfHouseList];// 现在不显示没有硬件，或硬件没有连接的房子了
    NSInteger count = [self.accountData countOfValidHouseList];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    MyEHouseData *houseDataAtIndex = [self.accountData validHouseInListAtIndex:indexPath.row];
    
    if(houseDataAtIndex.mId.length != 0 && houseDataAtIndex.connection == 0)
    {// 如果房间有M并且至少有一个温控器正常连接
        if (houseDataAtIndex.terminals.count == 0)
        {
            MyEHouseListConnectedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseListConnectedCellRemoteNo"];
            if (cell == nil)
            {
                cell = [[MyEHouseListConnectedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseListConnectedCellRemoteNo"];
            }
            [[cell textLabel] setText:houseDataAtIndex.houseName];
            
            return cell;
        }
        else
        {
            MyEHouseListConnectedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseListConnectedCellRemoteYes"];
            if (cell == nil)
            {
                cell = [[MyEHouseListConnectedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseListConnectedCellRemoteYes"];
            }
            [[cell textLabel] setText:houseDataAtIndex.houseName];
            
            return cell;
        }
    }
    // 现在不显示没有硬件，或硬件没有连接的房子了
    else
    {
        MyEHouseListDisconnectedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseListDisconnectedCell"];
        if (cell == nil) {
            cell = [[MyEHouseListDisconnectedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseListDisconnectedCell"];
        }
        [[cell textLabel] setText:houseDataAtIndex.houseName];

//        [[cell detailTextLabel] setText:@"No Connection"];// 不需要程序设置，storyboard上已经有这个文字了
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // Mac's native DigitalColor Meter reads exactly {R:143, G:143, B:143}.
        cell.textLabel.alpha = 0.439216f; // (1 - alpha) * 255 = 143
        cell.detailTextLabel.alpha = 0.439216f; // (1 - alpha) * 255 = 143
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
//    if(houseDataAtIndex.thermostat >= 2)// 如果没有购买温控器，就不显示
//        NSLog(@"Error for Developer: thermostat值大于1，表明温控器不存在或程序发生错误");
    
    return nil;
}

/* @see http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableViewCell_Class/Reference/Reference.html
 * excerpt from the UITableViewCell class reference below:
 * Note: If you want to change the background color of a cell (by setting the background color of a cell via the backgroundColor property declared by UIView) you must do it in the tableView:willDisplayCell:forRowAtIndexPath: method of the delegate and not in tableView:cellForRowAtIndexPath: of the data source. Changes to the background colors of cells in a group-style table view has an effect in iOS 3.0 that is different than previous versions of the operating system. It now affects the area inside the rounded rectangle instead of the area outside of it.
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置单元格的背景
    //从NSDefaults里面取得上次进入过的房屋
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger houseIdLastViewed = [prefs integerForKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
    
    MyEHouseData *houseDataAtIndex = [self.accountData validHouseInListAtIndex:indexPath.row];
    
    if (houseDataAtIndex.houseId == houseIdLastViewed)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.8 alpha:0.9]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */

    MyETerminalData *thermostatData;
    MyEHouseData *houseData = [self.accountData validHouseInListAtIndex:indexPath.row];
    
//    if(houseData.mId.length != 0 && houseData.connection == 0)
//    {// 如果房间有M并且至少有一个温控器正常连接
//        if (houseData.thermostats.count == 0)
//        { //HouseListConnectedCellRemoteNo
//            
//        }
//        else //HouseListConnectedCellRemoteYes
//        {
//            
//        }
//    }
//    // 现在不显示没有硬件，或硬件没有连接的房子了
//    else // HouseListDisconnectedCell
//    {
//    }

    [self saveSettings:houseData.houseId];
    MainDelegate.houseData = houseData;
    
    thermostatData = [houseData firstConnectedThermostat];
    MainDelegate.terminalData = thermostatData;
    
    //在NSDefaults里面记录这次要进入的房屋
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *tid = [prefs objectForKey:KEY_FOR_TID_LAST_VIEWED];
    for (MyETerminalData *temp in MainDelegate.houseData.terminals)
    {
        if ([tid isEqualToString:temp.tId])
        {
            MainDelegate.terminalData = temp;
            break;
        }
    }
    if (MainDelegate.terminalData == nil)
    {
        MainDelegate.terminalData = [MainDelegate.houseData firstConnectedThermostat];
    }
    
    //在NSDefaults里面记录这次要进入的房屋
    [prefs setInteger:houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
    [prefs setValue:thermostatData.tId forKey:KEY_FOR_TID_LAST_VIEWED];
    [prefs synchronize];
    
    if (self.selectedHouseId != houseData.houseId) {
        self.selectedTabIndex = 0;
        self.selectedHouseId = houseData.houseId;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SWRevealViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuVC"];
    
    [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    MainDelegate.window.rootViewController = vc;
}
#pragma mark - Navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyEHouseData *houseData;
    MyETerminalData *thermostatData;
    if ([[segue identifier] isEqualToString:@"ShowMainTabViewRemoteNo"] ||
        [[segue identifier] isEqualToString:@"ShowMainTabViewRemoteYes"] ||
        [[segue identifier] isEqualToString:@"ShowMainTabViewRemoteYesConnected"] )
    {

        houseData = [self.accountData validHouseInListAtIndex:[self.tableView indexPathForSelectedRow].row];
        [self saveSettings:houseData.houseId];
    }
    if([[segue identifier] isEqualToString:@"ShowMainTabViewByDefaultHouseId"] )
    {
        houseData = [self.accountData houseDataByHouseId:_defaultHouseId];
    }
    
    MainDelegate.houseData = houseData;
    
    thermostatData = [houseData firstConnectedThermostat];
    MainDelegate.terminalData = thermostatData;
    
    //在NSDefaults里面记录这次要进入的房屋
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *tid = [prefs objectForKey:KEY_FOR_TID_LAST_VIEWED];
    for (MyETerminalData *temp in MainDelegate.houseData.terminals)
    {
        if ([tid isEqualToString:temp.tId])
        {
            MainDelegate.terminalData = temp;
            break;
        }
    }
    if (MainDelegate.terminalData == nil)
    {
        MainDelegate.terminalData = [MainDelegate.houseData firstConnectedThermostat];
    }
    
    //在NSDefaults里面记录这次要进入的房屋
    [prefs setInteger:houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
    [prefs setValue:thermostatData.tId forKey:KEY_FOR_TID_LAST_VIEWED];
    [prefs synchronize];

    if (self.selectedHouseId != houseData.houseId) {
        self.selectedTabIndex = 0;
        self.selectedHouseId = houseData.houseId;
    }
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
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@",GetRequst(URL_FOR_HOUSELIST_VIEW), self.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"HouseListDownloader"  userDataDictionary:nil];
    NSLog(@"HouseListDownloader is %@",downloader.name);
}
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"houselist received string: %@", string);
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    } else {
        [HUD hide:YES];
    }
    if([name isEqualToString:@"HouseListDownloader"]) {
        if (![self.accountData updateHouseListByJSONString:string]) {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                          message:@"Communication error. Please try again."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        } else {
            [self.tableView reloadData];//重新加载数据,这一步骤是重要的，用来现实更新后的数据。
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
