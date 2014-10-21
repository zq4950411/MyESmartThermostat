//
//  MyESwitchEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchEditViewController.h"
#import "MyEDevicesViewController.h"
@interface MyESwitchEditViewController (){
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}

@end

@implementation MyESwitchEditViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _room = [[MyERoom alloc] init];
	self.nameTextField.text = self.device.deviceName;
    self.roomLabel.text = [self.device.locationName isEqualToString:@""]?@"unspecified":self.device.locationName;
    self.terminalID.text = self.device.tid;
    //下载开关信息
    [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@",GetRequst(URL_FOR_SWITCH_VIEW),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId] loaderName:@"downloadSwitchInfo"];
    [self defineTapGestureRecognizer];
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.nameTextField becomeFirstResponder];
        }else if (indexPath.row == 1){
            [self.nameTextField endEditing:YES];
            NSMutableArray *array = [NSMutableArray array];
            for (MyERoom *r in self.switchInfo.rooms) {
                [array addObject:r.roomName];
            }
            MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"Select Room" dataSource:array andSelectRow:[self.roomLabel.text length]!=0?[array indexOfObject:self.roomLabel.text]:0];
            picker.delegate = self;
            [picker showInView:self.view];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:2 title:@"Bulb Type" dataSource:[self.switchInfo typeArray] andSelectRow:self.switchInfo.type];
            picker.delegate = self;
            [picker showInView:self.view];
        }else{
            if (self.switchInfo.type == 1) {
                return;
            }
            NSArray *array = @[@"0.5",@"0.55",@"0.6",@"0.65",@"0.7",@"0.75",@"0.8",@"0.85",@"0.9",@"0.95",@"1"];
            NSInteger i = [array containsObject:self.switchInfo.powerFactor]?[array indexOfObject:self.switchInfo.powerFactor]:0;
            MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:3 title:@"Power Factor" dataSource:array andSelectRow:i];
            picker.delegate = self;
            [picker showInView:self.view];
        }
    }
//    if (indexPath.section == 1) {
//        _selectedIndex = indexPath.row;
//        if (indexPath.row == 0) {
//            self.table0.accessoryType = UITableViewCellAccessoryCheckmark;
//            self.table1.accessoryType = UITableViewCellAccessoryNone;
//            [self checkIfChange];
//        }else{
//            self.table1.accessoryType = UITableViewCellAccessoryCheckmark;
//            self.table0.accessoryType = UITableViewCellAccessoryNone;
//            NSMutableArray *array = [NSMutableArray array];
//            for (int i = 1; i < 7; i++) {
//                [array addObject:[NSString stringWithFormat:@"%i Minute(s)",i*10]];
//            }
//            [MyEUniversal doThisWhenNeedPickerWithTitle:@"Please select report time" andDelegate:self andTag:2 andArray:array andSelectRow:@[@(_reportTime/10-1)] andViewController:self];
//        }
//    }
}
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    [self.nameTextField resignFirstResponder];
    if ([self.nameTextField.text length] < 1 || [self.nameTextField.text length] > 10) {
        [MyEUtil showMessageOn:nil withMessage:@"Make sure name length between 1 and 10"];
        return;
    }
    [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&name=%@&roomId=%i&loadType=%i&powerFactor=%@",
                                  GetRequst(URL_FOR_SWITCH_SAVE),
                                  MainDelegate.houseData.houseId,
                                  self.device.tid,
                                  self.device.deviceId,
                                  self.nameTextField.text,
                                  _room.roomId,self.switchInfo.type,self.switchInfo.powerFactor] loaderName:@"uploadSwitchInfo"];
}

#pragma mark - private methods
-(void)urlLoaderWithUrlString:(NSString *)url loaderName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.nameTextField endEditing:YES];
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([name isEqualToString:@"downloadSwitchInfo"]) {
        NSLog(@"download switch string is %@",string);
        if ([string isEqualToString:@"fail"]) {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to download data"];
        }else{
            MyESwitchInfo *info = [[MyESwitchInfo alloc] initWithString:string];
            self.switchInfo = info;
            self.typeLbl.text = [self.switchInfo changeTypeToString];
            self.valueLbl.text = self.switchInfo.powerFactor;
            [self.tableView reloadData];  //这里一定要记得更新表格
        }
    }
    if ([name isEqualToString:@"uploadSwitchInfo"]) {
        NSLog(@"uploadSwitchInfo string is %@",string);
        if ([string isEqualToString:@"OK"]) {
            self.device.deviceName = self.nameTextField.text;
            self.device.locationName = _room.roomName;
            self.device.locationId = [NSString stringWithFormat:@"%i",_room.roomId];
            MyEDevicesViewController *vc = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];
            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"Failed to upload data"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    if (pickerView.tag == 1) {
        self.roomLabel.text = title;
        [self.tableView reloadData];
        for (MyERoom *r in self.switchInfo.rooms) {
            if ([r.roomName isEqualToString:title]) {
                _room = r;
            }
        }
    }else if(pickerView.tag == 2){
        self.typeLbl.text = title;
        if ([title isEqualToString:@"Incandescent Lamp"]) {
            self.valueLbl.text = @"1";
            self.switchInfo.powerFactor = @"1";
            self.switchInfo.type = 1;
        }else{
            self.valueLbl.text = @"0.65";
            self.switchInfo.powerFactor = @"0.65";
            self.switchInfo.type = 0;
        }
    }else if (pickerView.tag == 3){
        self.valueLbl.text = title;
        self.switchInfo.powerFactor = title;
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
    [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@",GetRequst(URL_FOR_SWITCH_VIEW),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId] loaderName:@"downloadSwitchInfo"];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}
@end
