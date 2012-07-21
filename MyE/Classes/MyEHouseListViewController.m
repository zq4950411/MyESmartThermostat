//
//  MyEHouseListViewController.m
//  MyE
//
//  Created by Ye Yuan on 1/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEHouseListViewController.h"
#import "MyEMainTabBarController.h"
#import "MyEDashboardViewController.h"
#import "MyEScheduleViewController.h"
#import "MyEVacationMasterViewController.h"
#import "MyESettingsViewController.h"
#import "MyEHouseListRemoteYesCell.h"
#import "MyEHouseListRemoteNoCell.h"
#import "MyEAccountData.h"
#import "MyEHouseData.h"
#import "MyEDashboardData.h"
#import "MyEUtil.h"
#import "SBJson.h"

@implementation MyEHouseListViewController
@synthesize accountData = _accountData;
@synthesize rememberHouseIdSwitch = _rememberHouseIdSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 隐藏backButton
    self.navigationItem.hidesBackButton = YES;
    
    //设置表格的背景
//    UIColor *bgcolor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgpattern.png"]];
//    [self.tableView setBackgroundColor:bgcolor];
    
    _hasLoadedDefaultHouseId = NO;
}

- (void)viewDidUnload
{
    [self setRememberHouseIdSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                      target:self 
                                      action:@selector(refreshAction)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [self.tableView reloadData];//重新加载数据,这一步骤是重要的，用来现实更新后的数据。
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!_hasLoadedDefaultHouseId) {// 如果是第一次出现这个house list 面板，就要从系统偏好里面取得是否由默认的houseId
        [self loadSettings];// 获取当前存储在系统偏好里的用户默认的houseId
        _hasLoadedDefaultHouseId = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)loadSettings{
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
    
     NSInteger count = [self.accountData.houseList count];
     MyEHouseData *defaultHouseData;
     for (NSInteger i = 0; i < count; i++ ) {
     defaultHouseData = [self.accountData.houseList objectAtIndex:i];
     if( defaultHouseData.houseId == _defaultHouseId )
     break;
     }
     if ( _defaultHouseId > 0 && defaultHouseData.thermostat==0) {
     [self performSegueWithIdentifier:@"ShowMainTabViewByDefaultHouseId" sender:self];
     
     }
     
}

-(void)saveSettings:(NSInteger)defaultHouseId{   
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.rememberHouseIdSwitch.isOn) {
        [prefs setInteger:defaultHouseId  forKey:@"defaulthouseid"];
    }else {
        [prefs setInteger:-1  forKey:@"defaulthouseid"];
    }
    [prefs synchronize];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.accountData countOfHouseList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    MyEHouseData *houseDataAtIndex = [self.accountData objectInHouseListAtIndex:indexPath.row];
    
    if(houseDataAtIndex.thermostat == 0) {// 如果温控器正常连接
        if (houseDataAtIndex.remote == 1) {
            MyEHouseListRemoteYesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseListCellRemoteYes"];
            if (cell == nil) {
                cell = [[MyEHouseListRemoteYesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseListCellRemoteYes"];
            }
            [[cell textLabel] setText:houseDataAtIndex.houseName];
            NSLog(@"%i", houseDataAtIndex.houseId);
//            [[cell detailTextLabel] setText:@"Remote YES"];
            return cell;
        } else {
            MyEHouseListRemoteNoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseListCellRemoteNo"];
            if (cell == nil) {
                cell = [[MyEHouseListRemoteNoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseListCellRemoteNo"];
            }
            [[cell textLabel] setText:houseDataAtIndex.houseName];
//            [[cell detailTextLabel] setText:@"Remote NO"];
            return cell;
        }
        
    }
    if(houseDataAtIndex.thermostat == 1) {// 如果温控器没有正常连接
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseListCellNoConnection"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseListCellNoConnection"];
        }
        [[cell textLabel] setText:houseDataAtIndex.houseName];
        [[cell detailTextLabel] setText:@"No Connection"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // Mac's native DigitalColor Meter reads exactly {R:143, G:143, B:143}.
        cell.textLabel.alpha = 0.439216f; // (1 - alpha) * 255 = 143
        cell.detailTextLabel.alpha = 0.439216f; // (1 - alpha) * 255 = 143
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    if(houseDataAtIndex.thermostat >= 2)// 如果没有购买温控器，就不显示
        NSLog(@"Error for Developer: thermostat值大于1，表明温控器不存在或程序发生错误");
        
    return nil;
}

/* @see http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableViewCell_Class/Reference/Reference.html
 * excerpt from the UITableViewCell class reference below:
 * Note: If you want to change the background color of a cell (by setting the background color of a cell via the backgroundColor property declared by UIView) you must do it in the tableView:willDisplayCell:forRowAtIndexPath: method of the delegate and not in tableView:cellForRowAtIndexPath: of the data source. Changes to the background colors of cells in a group-style table view has an effect in iOS 3.0 that is different than previous versions of the operating system. It now affects the area inside the rounded rectangle instead of the area outside of it.
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //设置单元格的背景
    //从NSDefaults里面取得上次进入过的房屋
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger houseIdLastViewed = [prefs integerForKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
    
    MyEHouseData *houseDataAtIndex = [self.accountData objectInHouseListAtIndex:indexPath.row];
    
    if (houseDataAtIndex.houseId == houseIdLastViewed) {
        [cell setBackgroundColor:[UIColor yellowColor]];
    }else {
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MyEHouseData *houseData;
    if ([[segue identifier] isEqualToString:@"ShowMainTabViewRemoteNo"] ||
        [[segue identifier] isEqualToString:@"ShowMainTabViewRemoteYes"]) {

        houseData = [self.accountData objectInHouseListAtIndex:[self.tableView indexPathForSelectedRow].row];
        [self saveSettings:houseData.houseId];
    }
    if([[segue identifier] isEqualToString:@"ShowMainTabViewByDefaultHouseId"] ) {
        houseData = [self.accountData houseDataByHouseId:_defaultHouseId];
    }
    //在NSDefaults里面记录这次要进入的房屋
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
    [prefs synchronize];
   
    
    //在这里为每个tab view设置houseId和userId, 同时要为每个tab viewController中定义这两个变量，并实现一个统一的签名方法，以保存这个变量。
    MyEMainTabBarController *tabBarController = [segue destinationViewController];
    
    [tabBarController setTitle:@"Dashboard"];
    tabBarController.userId = self.accountData.userId;
    tabBarController.houseId = houseData.houseId;
    tabBarController.houseName = houseData.houseName;
    
    MyEDashboardViewController *dashboardViewController = [[tabBarController childViewControllers] objectAtIndex:0];
    dashboardViewController.userId = self.accountData.userId;
    dashboardViewController.houseId = houseData.houseId;
    dashboardViewController.houseName = houseData.houseName;
    dashboardViewController.isRemoteControl = houseData.remote == 0? NO:YES;
    
    
    MyEScheduleViewController *scheduleViewController = [[tabBarController childViewControllers] objectAtIndex:1];
    scheduleViewController.userId = self.accountData.userId;
    scheduleViewController.houseId = houseData.houseId;
    scheduleViewController.houseName = houseData.houseName;
    scheduleViewController.isRemoteControl = houseData.remote == 0? NO:YES;
    
    MyEVacationMasterViewController *vacationViewController = [[tabBarController childViewControllers] objectAtIndex:2];
    vacationViewController.userId = self.accountData.userId;
    vacationViewController.houseId = houseData.houseId;
    vacationViewController.houseName = houseData.houseName;
    vacationViewController.isRemoteControl = houseData.remote == 0? NO:YES;
    
    MyESettingsViewController *settingsViewController = [[tabBarController childViewControllers] objectAtIndex:3];
    settingsViewController.userId = self.accountData.userId;
    settingsViewController.houseId = houseData.houseId;
    settingsViewController.houseName = houseData.houseName;
    settingsViewController.isRemoteControl = houseData.remote == 0? NO:YES;    
}


#pragma mark -
#pragma mark URL Loading System methods
- (void) downloadModelFromServer
{
    ///////////////////////////////////////////////////////////////////////
    // Demo 用户登录
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [prefs objectForKey:@"username"];
    
    if (username != nil && [username caseInsensitiveCompare:@"demo"] == NSOrderedSame) // 如果是demo账户
        return;
    ///////////////////////////////////////////////////////////////////////
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@",URL_FOR_HOUSELIST_VIEW, self.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"HouseListDownloader"  userDataDictionary:nil];
    NSLog(@"HouseListDownloader is %@",downloader.name);
}
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
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
        
        [HUD hide:YES];

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
#pragma mark
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

@end
