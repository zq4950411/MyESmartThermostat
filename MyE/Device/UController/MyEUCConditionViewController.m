//
//  MyEUCConditionViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-7.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCConditionViewController.h"

@interface MyEUCConditionViewController ()

@end

@implementation MyEUCConditionViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SEQUENTIAL_VIEW),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    [self upOrDownloadInfoWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&control=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SEQUENTIAL_Save),MainDelegate.houseData.houseId,self.device.tid,[self.sequential jsonSequential]] andName:@"save"];
}

#pragma mark - private methods
-(void)upOrDownloadInfoWithURL:(NSString *)url andName:(NSString *)name{
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }else
        return self.sequential.sequentialOrder.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = nil;
    if (indexPath.section == 0 && indexPath.row == 1) {
        string = @"cell1";
    }else if(indexPath.section == 1 && indexPath.row == self.sequential.sequentialOrder.count){
        string = @"cell0";
    }else
        string = @"cell";
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:string forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Time";
            cell.detailTextLabel.text = self.sequential.startTime;
        }else if (indexPath.row == 1){
            MYEWeekButtons *btns = (MYEWeekButtons *)[cell.contentView viewWithTag:100];
            btns.delegate = self;
            btns.selectedButtons = self.sequential.weeks;
        }else{
            cell.textLabel.text = @"Weather";
            cell.detailTextLabel.text = [self.sequential conditionArray][self.sequential.preConditon];
            if (self.sequential.preConditon == 5) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"If Temperature >= %iF",self.sequential.temperature];
            }
            if (self.sequential.preConditon == 6) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"If Temperature <= %iF",self.sequential.temperature];
            }
        }
    }else{
        if (indexPath.row < self.sequential.sequentialOrder.count) {
            MyEUCChannelInfo *info = self.sequential.sequentialOrder[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"Channel %i",info.channel];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Duration %imin",info.duration];
        }else{
            UIButton *btn = (UIButton *)[cell.contentView viewWithTag:100];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitle:@"Add New Channel" forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
        }
    }
    return cell;
}
#pragma mark - UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Start Condition";
    }else
        return @"Sequential Order";
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1) {
        return 73;
    }else
        return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MyEUCTimeSetViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"time"];
            vc.sequential = self.sequential;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }else{
            MyEUCWeatherViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"weather"];
            vc.sequential = self.sequential;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }else{
        MyEUCChannelSetViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"channel"];
        vc.sequential = self.sequential;
        vc.channelInfo = self.sequential.sequentialOrder[indexPath.row];
        vc.isAdd = NO;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [self.sequential.sequentialOrder removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return NO;
    }else if (indexPath.section == 1 && indexPath.row == self.sequential.sequentialOrder.count){
        return NO;
    }else
        return YES;
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyEUCChannelSetViewController *vc = segue.destinationViewController;
    vc.sequential = self.sequential;
    vc.isAdd = YES;
    MyEUCChannelInfo *info = [[MyEUCChannelInfo alloc] init];
    vc.channelInfo = info;
}

#pragma mark - MYEDataloader Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"downloadInfo"]) {
        if (![string isEqualToString:@"fail"]) {
            MyEUCSequential *seq = [[MyEUCSequential alloc] initWithJsonString:string];
            self.sequential = seq;
            NSLog(@"%@",self.sequential);
            [self.tableView reloadData];
        }
    }
    if ([name isEqualToString:@"save"]) {
        
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

#pragma mark - MYEWeekBtns delegate methods
-(void)weekButtons:(UIView *)weekButtons selectedButtonTag:(NSArray *)buttonTags{
    self.sequential.weeks = [buttonTags mutableCopy];
}
@end
