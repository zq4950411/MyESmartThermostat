//
//  MyEAcAutoControlProcessListViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/17/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoProcessListViewController.h"
#import "MyEAutoControlProcessList.h"
#import "MyEAutoControlProcess.h"
#import "MyEAutoProcessViewController.h"
#import "MyEAutoControlViewController.h"
#import "MyEAutoControlViewController.h"
#import "MyEAccountData.h"
#import "MyEDevice.h"
#import "MyEUtil.h"
#import "SBJson.h"

#define AUTO_CONTROL_PROCESS_UPLOADER_NMAE @"AutoControlProcessUploader"

@interface MyEAutoProcessListViewController ()

@end

@implementation MyEAutoProcessListViewController

@synthesize processList = _processList, accountData, device;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - setter methods
- (void)setProcessList:(MyEAutoControlProcessList *)processList{
    _processList = processList;
    [self.tableView reloadData];//重新加载Table数据,这一步骤是重要的，用来现实更新后的数据。
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_IPHONE_5) {
        self.tableView.frame = CGRectMake(0, 0, 320, 366);
    }else
        self.tableView.frame = CGRectMake(0, 0, 320, 278);
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor whiteColor];
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
    return [self.processList.mainArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AcAutoControlProcessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MyEAutoControlProcess *process = [self.processList.mainArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:process.name];
    NSString *dayString = @"星期：";
    for (NSNumber *day in process.days) {
        dayString = [NSString stringWithFormat:@"%@ %@", dayString, day];
    }
    [cell.detailTextLabel setText:dayString];
    
    return cell;
}
#pragma mark - tableView delegate methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        } else
            [HUD show:YES];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:indexPath forKey:@"indexPath"];
        MyEAutoControlViewController *parentVC = (MyEAutoControlViewController *)self.parentViewController;
        MyEAutoControlProcess *process = [self.processList.mainArray objectAtIndex:indexPath.row];
        
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *dataString = [writer stringWithObject:[process JSONDictionary]];
        if (self.device.typeId.intValue == 1){
            NSString *urlStr = [NSString stringWithFormat:@"%@?houseId=%i&tId=%@&id=%ld&deviceId=%ld&action=2&data=%@",
                                GetRequst(URL_FOR_AC_UPLOAD_AC_AUTO_PROCESS_SAVE),
                                MainDelegate.houseData.houseId,
                                self.device.tid,
                                (long)process.pId,
                                (long)parentVC.device.deviceId,
                                dataString];
            MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                         initLoadingWithURLString:urlStr
                                         postData:nil
                                         delegate:self loaderName:AUTO_CONTROL_PROCESS_UPLOADER_NMAE
                                         userDataDictionary:dict];
            NSLog(@"%@",downloader.name);
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
#pragma mark - Navigation methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AcProcessListToEditProcess"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        MyEAutoControlViewController *parentVC = (MyEAutoControlViewController *)self.parentViewController;
        MyEAutoProcessViewController *pvc = [segue destinationViewController];

        MyEAutoControlProcess *process = [self.processList.mainArray objectAtIndex:selectedIndexPath.row];
        pvc.process = [process copy];
        pvc.unavailableDays = [self.processList getUnavailableDaysForProcessWithId:process.pId];
        pvc.delegate = self;
        pvc.isAddNew = NO;
        pvc.device = parentVC.device;
    }
}

#pragma mark - method for MyEAcProcessViewControllerDelegate
- (void)didFinishEditProcess:(MyEAutoControlProcess *)process isAddNew:(BOOL)flag
{
    if (flag) {
        [[NSException exceptionWithName:@"代理类型错误" reason:@"此处不应该是添加新的进程，而应该是编辑进程" userInfo:Nil] raise];
    }
    NSLog(@"更新数据");
    [self.processList updateProcessWith:process];
    [self.tableView reloadData];
}

#pragma mark - URL Loading System methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AUTO_CONTROL_PROCESS_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1){
            [SVProgressHUD showErrorWithStatus:@"fail"];
            } else{
            NSIndexPath *indexPath = (NSIndexPath *)[dict objectForKey:@"indexPath"];
            // Delete the row from the data source
            [self.processList.mainArray removeObjectAtIndex:indexPath.row];
            [self.processList renameProcessInList];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            MyEAutoControlViewController *vc = (MyEAutoControlViewController *)self.parentViewController;
            
/*            MyEAutoControlViewController *vc = (MyEAutoControlViewController *)self.view.superview.superview.nextResponder;  这里是两种不同的寻找VC的方法,这个得注意咯
*/
            if (!vc.navigationItem.rightBarButtonItem.enabled) {
                vc.navigationItem.rightBarButtonItem.enabled = YES;
            }
            if ([self.processList.mainArray count] == 0) {
                [vc.enableProcessSegmentedControl setEnabled:NO forSegmentAtIndex:0];
                [vc.enableProcessSegmentedControl setSelectedSegmentIndex:1];
            }
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

@end
