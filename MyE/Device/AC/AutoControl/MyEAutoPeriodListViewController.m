//
//  MyEPeriodListViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoPeriodListViewController.h"
#import "MyEAutoControlPeriod.h"
#import "MyEAcUtil.h"
#import "MyEAutoPeriodViewController.h"
#import "MyEAutoProcessViewController.h"
#import "MyEAutoControlProcess.h"

@interface MyEAutoPeriodListViewController ()

@end

@implementation MyEAutoPeriodListViewController
@synthesize periodList = _periodList,device;
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
}
- (void)viewWillAppear:(BOOL)animated
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
    return [self.periodList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PeriodCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    MyEAutoControlPeriod *period = [self.periodList objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@-%@", period.startTimeString, period.endTimeString]];
    if (self.device.typeId.intValue == 1) {
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@, %@, %@",
                                       [MyEAcUtil getStringForRunMode:period.runMode],
                                       [MyEAcUtil getStringForSetpoint:period.setpoint],
                                       [MyEAcUtil getStringForWindLevel:period.windLevel]]];
    }
    
    
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

#pragma mark - tableView delegate methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.periodList removeObjectAtIndex:indexPath.row];
        [(MyEAutoProcessViewController *)self.parentViewController decideIfProcessedChanged];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
#pragma mark - Navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AcPeriodListToEditPeriod"]) {
        MyEAutoProcessViewController *parentVC = (MyEAutoProcessViewController *)self.parentViewController;
        MyEAutoPeriodViewController *pvc = [segue destinationViewController];
        pvc.delegate = self;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MyEAutoControlPeriod *period = [self.periodList objectAtIndex:indexPath.row];
        pvc.period = [period copy];
        pvc.device = parentVC.device;
        pvc.isAddNew = NO;
    }
}

#pragma mark - method for MyEAcPeriodViewControllerDelegate
- (void)didFinishEditPeriod:(MyEAutoControlPeriod *)period isAddNew:(BOOL)flag
{
    if (flag) {
        [[NSException exceptionWithName:@"代理类型错误" reason:@"此处不应该是添加新的时段，而应该是编辑时段" userInfo:Nil] raise];
    }
    for (MyEAutoControlPeriod *p in self.periodList) {
        if(period.pId == p.pId){
            p.stid = period.stid;
            p.etid = period.etid;
            p.runMode = period.runMode;
            p.setpoint = period.setpoint;
            p.windLevel = period.windLevel;
        }
    }
    [self.tableView reloadData];
}
- (BOOL)isTimeFrameValidForPeriod:(MyEAutoControlPeriod *)period{
    MyEAutoProcessViewController *pvc = (MyEAutoProcessViewController *)[self parentViewController];
    return [pvc.process validatePeriodWithId:period.pId newStid:period.stid newEtid:period.etid];
}
@end
