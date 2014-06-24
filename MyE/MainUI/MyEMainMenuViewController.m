//
//  MyEMainMenuViewController.m
//  MyE
//
//  Created by Ye Yuan on 4/15/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEMainMenuViewController.h"
#import "MyEHouseListViewController.h"
#import "SWRevealViewController.h"
#import "MyEUsageStatsViewController.h"
#import "MyESettingsViewController.h"

@interface MyEMainMenuViewController ()
//- (void)goHouseList;
@end

@implementation MyEMainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
    _menuItems = @[@"houseList",@"home", @"devices", @"events", @"usage", @"alerts", @"settings",@"signout"];

    self.houseName.text = MainDelegate.houseData.houseName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//#warning 下面根据房间的设备的情况, 来确定对应的菜单按钮是否允许访问.下面代码参考原来的MyEMainTabBarController,- (void)viewDidLoad 里面的代码
    //b)	网关在线，但尚未绑定任何一个智能终端：则后面显示文字“Connected”和红叉，点击后进入settings页面，其他主菜单置灰（不能进入）。
    
//    BOOL hasT = NO;
//    BOOL hasS = NO;
//    
//    int index = -1;
//    
//    for (MyEThermostatData *t in MainDelegate.houseData.thermostats)
//    {
//        if (t.deviceType == 0 && t.thermostat == 0)
//        {
//            hasT = YES;
//        }
//        else if((t.deviceType == 1 || t.deviceType == 2 || t.deviceType == 3 || t.deviceType == 6) && t.thermostat == 0 )
//        {
//            hasS = YES;
//        }
//    }
//    
//    if (hasT )
//    {
//        index = 0;
//        [[vc.tabBar.items objectAtIndex:0] setEnabled:YES];
//    }
//    else
//    {
//        [[vc.tabBar.items objectAtIndex:0] setEnabled:NO];
//    }
//    
//    if (hasS)
//    {
//        if (!hasT)
//        {
//            index = 1;
//        }
//        [[vc.tabBar.items objectAtIndex:1] setEnabled:YES];
//    }
//    else
//    {
//        [[vc.tabBar.items objectAtIndex:1] setEnabled:NO];
//    }
//    
//    if (index == -1)
//    {
//        vc.selectedIndex = 3;
//    }
//    else
//    {
//        vc.selectedIndex = index;
//    }
///////////////////////////////////////////
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

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) {
//        [self goHouseList];
//    }
    
    if (self.menuItems.count-1 == indexPath.row) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        MyELoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        MainDelegate.window.rootViewController = vc;
        
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@",GetRequst(URL_FOR_SIGNOUT)] postData:nil delegate:vc loaderName:@"signout" userDataDictionary:nil];
    }
    if (indexPath.row == self.menuItems.count - 2) {
        MyESettingsViewController *vc = [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:@"settings"];
        UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
        [navController setViewControllers: @[vc] animated: NO ];
        [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[_menuItems objectAtIndex:indexPath.row] capitalizedString];
    if(self.tableView.indexPathForSelectedRow.row == 4){
        MyEUsageStatsViewController *dvc = (MyEUsageStatsViewController*)segue.destinationViewController;
        dvc.fromHome = NO;
    }
     
//    // Set the photo if it navigates to the PhotoView
//    if ([segue.identifier isEqualToString:@"showPhoto"]) {
//        PhotoViewController *photoController = (PhotoViewController*)segue.destinationViewController;
//        NSString *photoFilename = [NSString stringWithFormat:@"%@_photo.jpg", [_menuItems objectAtIndex:indexPath.row]];
//        photoController.photoFilename = photoFilename;
//    }
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (self.tableView.indexPathForSelectedRow.row == 4) {
        if([MainDelegate.houseData terminalsForUsageStats].count == 0)
        {
            [SVProgressHUD showSuccessWithStatus:@"No devcie with electricity usage stats."];
            return NO;
        }
    }
    return YES;
}
@end
