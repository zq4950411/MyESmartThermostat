//
//  MyESwitchEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchEditViewController.h"

@interface MyESwitchEditViewController ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.nameTextField becomeFirstResponder];
        }else if (indexPath.row == 1){
            [self.nameTextField endEditing:YES];
            NSMutableArray *array = [NSMutableArray array];
            for (MyERoom *r in self.switchInfo.rooms) {
                [array addObject:r.roomName];
            }
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"Select Room" andDelegate:self andTag:1 andArray:@[array] andSelectRow:[self.roomLabel.text length]!=0?@[@([array indexOfObject:self.roomLabel.text])]:@[@0] andViewController:self];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    if ([self.nameTextField.text length] < 1 || [self.nameTextField.text length] > 10) {
        [MyEUtil showMessageOn:nil withMessage:@"Make sure name length between 1 and 10"];
        return;
    }
    [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&name=%@&roomId=%i",
                                  GetRequst(URL_FOR_SWITCH_SAVE),
                                  MainDelegate.houseData.houseId,
                                  self.device.tid,
                                  self.device.deviceId,
                                  self.nameTextField.text,
                                  _room.roomId] loaderName:@"uploadSwitchInfo"];
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
    if ([name isEqualToString:@"downloadSwitchInfo"]) {
        NSLog(@"download switch string is %@",string);
        if ([string isEqualToString:@"fail"]) {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to download data"];
        }else{
            MyESwitchInfo *info = [[MyESwitchInfo alloc] initWithString:string];
            self.switchInfo = info;
            [self.tableView reloadData];  //这里一定要记得更新表格
        }
    }
    if ([name isEqualToString:@"uploadSwitchInfo"]) {
        NSLog(@"uploadSwitchInfo string is %@",string);
        if ([string isEqualToString:@"OK"]) {
            self.device.deviceName = self.nameTextField.text;
            self.device.locationName = _room.roomName;
            self.device.locationId = [NSString stringWithFormat:@"%i",_room.roomId];
            [self.navigationController popViewControllerAnimated:YES];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"Failed to upload data"];
    }
}
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    if (pickerView.tag == 1) {
        self.roomLabel.text = titles[0];
        [self.tableView reloadData];
        for (MyERoom *r in self.switchInfo.rooms) {
            if ([r.roomName isEqualToString:titles[0]]) {
                _room = r;
            }
        }
    }
}
@end
