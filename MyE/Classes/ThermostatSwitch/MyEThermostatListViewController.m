//
//  MyEThermostatListViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/3/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import "MyEThermostatListViewController.h"
#import "MyEThermostatData.h"

@interface MyEThermostatListViewController ()

@end

@implementation MyEThermostatListViewController
@synthesize userId = _userId;
@synthesize houseId = _houseId;
@synthesize houseName = _houseName;


@synthesize thermostats = _thermostats;


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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.thermostats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyEThermostatData *thermostat = (MyEThermostatData *)[self.thermostats objectAtIndex:indexPath.row];
    
    if(thermostat.thermostat ==0 ) {// 如果温控器正常连接
        if (thermostat.remote == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThermostatCellRemoteYes"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThermostatCellRemoteYes"];
            }
            [[cell textLabel] setText:thermostat.tName];
            [[cell detailTextLabel] setText:@"Remote YES"];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThermostatCellRemoteNo"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThermostatCellRemoteNo"];
            }
            [[cell textLabel] setText:thermostat.tName];
            [[cell detailTextLabel] setText:@"Remote NO"];
            [cell.detailTextLabel setBackgroundColor:[UIColor
                                                      redColor]];
            return cell;
        }
        
    } else {// 如果温控器没有正常连接
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThermostatCellNoConnection"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThermostatCellNoConnection"];
        }
        [[cell textLabel] setText:thermostat.tName];
        [[cell detailTextLabel] setText:@"No Connection"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // Mac's native DigitalColor Meter reads exactly {R:143, G:143, B:143}.
        cell.textLabel.alpha = 0.439216f; // (1 - alpha) * 255 = 143
        cell.detailTextLabel.alpha = 0.439216f; // (1 - alpha) * 255 = 143
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    //    if(houseDataAtIndex.thermostat >= 2)// 如果没有购买温控器，就不显示
    //        NSLog(@"Error for Developer: thermostat值大于1，表明温控器不存在或程序发生错误");


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

- (IBAction)switchThermostatAction:(id)sender {
    UITabBarController *tbc = [[[self navigationController] childViewControllers] objectAtIndex:0];
    [tbc setSelectedIndex:0];
    NSLog(@"test");
}
@end
