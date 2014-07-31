//
//  MyESubSwitchEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESubSwitchEditViewController.h"

@interface MyESubSwitchEditViewController (){
    MBProgressHUD *HUD;
    NSMutableArray *_mainSwitchList;
}

@end

@implementation MyESubSwitchEditViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _mainSwitchList = [NSMutableArray array];
    self.lblName.text = self.subSwitch.name;
    self.lblTid.text = self.subSwitch.tid;
    self.imgSignal.image = [self.subSwitch getImage];
    self.lblMainTid.text = [self.subSwitch.mainTid isEqualToString:@""]?@"Not Paired":self.subSwitch.mainTid;
    [self.tableView reloadData];
    self.navigationItem.title = self.subSwitch.name;
    [self downloadInfoFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    if ([self.lblMainTid.text isEqualToString:@"Not Paired"]) {
        [SVProgressHUD showErrorWithStatus:@"Not Paired"];
        return;
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?mainTId=%@&subTId=%@&houseId=%i",GetRequst(URL_FOR_SUBSWITCH_BIND),[self.lblMainTid.text isEqualToString:@"Reset"]?@"":self.lblMainTid.text,self.subSwitch.tid,MainDelegate.houseData.houseId] postData:nil delegate:self loaderName:@"save" userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (![_mainSwitchList count]) {
            return;
        }
        MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"Main Switch" dataSource:_mainSwitchList andSelectRow:[_mainSwitchList containsObject:self.lblMainTid.text]?[_mainSwitchList indexOfObject:self.lblMainTid.text]:0];
        picker.delegate = self;
        [picker showInView:self.view];
//        [MyEUniversal doThisWhenNeedPickerWithTitle:@"Main Switch" andDelegate:self andTag:1 andArray:_mainSwitchList andSelectRow:[_mainSwitchList containsObject:self.lblMainTid.text]?[_mainSwitchList indexOfObject:self.lblMainTid.text]:0 andViewController:self];
    }
}

#pragma mark - private methods
-(void)downloadInfoFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?tId=%@&houseId=%i",GetRequst(URL_FOR_SUBSWITCH_INFO),self.subSwitch.tid,MainDelegate.houseData.houseId] postData:nil delegate:self loaderName:@"download" userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}

#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"download"]) {
        NSDictionary *dic = [string JSONValue];
        if (dic[@"tSwitchList"]) {
            for (NSDictionary *d in dic[@"tSwitchList"]) {
                [_mainSwitchList addObject:d[@"TId"]];
            }
        }
        if (self.subSwitch.mainTid.length > 0) {
            [_mainSwitchList addObject:@"Reset"];
        }
    }
    if ([name isEqualToString:@"save"]) {
//        int i = [MyEUtil getResultFromAjaxString:string];
        int i = string.intValue;
        if (i == 1) {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            self.subSwitch.mainTid = self.lblMainTid.text;
            if ([_mainSwitchList containsObject:@"Reset"]) {
                [_mainSwitchList removeObject:@"Reset"];
            }else
                [_mainSwitchList addObject:@"Reset"];
        }else if (i == 0){
            [SVProgressHUD showErrorWithStatus:@"Fail"];
        }else if (i == -1){
            [SVProgressHUD showErrorWithStatus:@"Fail"];
        }else if (i == 2){
            [SVProgressHUD showSuccessWithStatus:@"Reset Success"];
            self.subSwitch.mainTid = @"";
            if ([_mainSwitchList containsObject:@"Reset"]) {
                [_mainSwitchList removeObject:@"Reset"];
            }else
                [_mainSwitchList addObject:@"Reset"];
        }else
            [SVProgressHUD showErrorWithStatus:@"Fail"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    self.lblMainTid.text = title;
}
@end
