//
//  MyEEventDetailViewController.m
//  MyE
//
//  Created by 翟强 on 14-8-29.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventDetailViewController.h"

#import "MyEEventConditionEditViewController.h"
#import "MyEEventTimeEditViewController.h"
#import "MyEEventDeviceEditViewController.h"

@interface MyEEventDetailViewController (){
    MBProgressHUD *HUD;
    NSIndexPath *_selectIndex;
    UITapGestureRecognizer *_tableTap;
    UILongPressGestureRecognizer *_tableLong;
}

@end

@implementation MyEEventDetailViewController

#pragma mark - life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _isAdd?@"Add Event":@"Edit Event";
    [self downloadDevicesFromServer];  //编辑的时候要获取数据
    _tableLong = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginTableViewEditing:)];
    [self.tableView addGestureRecognizer:_tableLong];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadDevicesFromServer];
    }
}
#pragma mark - IBAction methods
- (IBAction)deviceSort:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self editSceneToServerWithAction:@"sceneSort"];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    [self editSceneToServerWithAction:@"save"];
}
#pragma mark - private methods
-(void)beginTableViewEditing:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.tableView.editing) {
            return;
        }
        [self.tableView setEditing:!self.tableView.editing animated:YES];
        _tableTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTableView:)];
        _tableTap.numberOfTapsRequired = 1;
        [self.tableView removeGestureRecognizer:_tableLong];
        [self.tableView addGestureRecognizer:_tableTap];
    }
}
// 对于双击和单击事件，不需要对状态进行判断，主要是他这个状态维持的时间很短
-(void)tapOnTableView:(UITapGestureRecognizer *)sender{
    if (!self.tableView.editing) {
        return;
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [self.tableView removeGestureRecognizer:_tableTap];
    [self.tableView addGestureRecognizer:_tableLong];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventDetail.customConditions count]+[self.eventDetail.timeConditions count]+[self.eventDetail.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row < self.eventDetail.timeConditions.count) {
        MyEEventConditionTime *time = self.eventDetail.timeConditions[indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"time"];
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:100];
        timeLabel.text = [time changeDateToString];
    }else if (indexPath.row > (NSInteger)self.eventDetail.timeConditions.count - 1 && indexPath.row < (self.eventDetail.customConditions.count + self.eventDetail.timeConditions.count)){
        MyEEventConditionCustom *custom = self.eventDetail.customConditions[indexPath.row - self.eventDetail.timeConditions.count];
        cell = [tableView dequeueReusableCellWithIdentifier:@"weather"];
        UILabel *conditionLabel = (UILabel *)[cell.contentView viewWithTag:100];
        conditionLabel.text = [custom changeDataToString];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"device"];
        MyEEventDevice *device = self.eventDetail.devices[indexPath.row - self.eventDetail.timeConditions.count - self.eventDetail.customConditions.count];
        UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *instruction = (UILabel *)[cell.contentView viewWithTag:102];
        image.image = [device changeTypeToImage];
        nameLabel.text = device.name;
        instruction.text = [device getDeviceInstructionName];
    }
    UIView *view = (UIView *)[cell.contentView viewWithTag:1024];
    view.layer.cornerRadius = 4;
    
    return cell;
}
#pragma mark - UITable View delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectIndex = indexPath;
    if (indexPath.row < [self.eventDetail.timeConditions count]) {
        MyEEventConditionTime *_newTime = self.eventDetail.timeConditions[indexPath.row];
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Do you want to delete this conditon?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
        alert.rightBlock = ^{
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&id=%i&timeType=%i&triggerDate=%@&weekly=%@&hour=%i&minute=%i&action=3",GetRequst(URL_FOR_SCENES_CONDITION_TIME),MainDelegate.houseData.houseId,self.eventInfo.sceneId,_newTime.conditionId,_newTime.timeType,_newTime.date,[_newTime.weeks componentsJoinedByString:@","],_newTime.hour,_newTime.minute] andName:@"deleteTime"];
        };
        [alert show];
    }else if(indexPath.row > (NSInteger)self.eventDetail.timeConditions.count - 1 && indexPath.row < self.eventDetail.customConditions.count + self.eventDetail.timeConditions.count){
        MyEEventConditionCustom *_newCustom = self.eventDetail.customConditions[indexPath.row - self.eventDetail.timeConditions.count];
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Do you want to delete this conditon?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
        alert.rightBlock = ^{
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&tId=%@&id=%i&dataType=%i&parameterType=%i&parameterValue=%i&action=3",GetRequst(URL_FOR_SCENES_CONDITION_CUSTOM),MainDelegate.houseData.houseId,self.eventInfo.sceneId,_newCustom.tId,_newCustom.conditionId,_newCustom.dataType,_newCustom.parameterType,_newCustom.parameterValue] andName:@"deleteCustom"];
        };
        [alert show];
    }else{
        MyEEventDevice *device = self.eventDetail.devices[indexPath.row - self.eventDetail.timeConditions.count - self.eventDetail.customConditions.count];
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Are you sure to remove this device from the event?" leftButtonTitle:@"Cancel" rightButtonTitle:@"YES"];
        alert.rightBlock = ^{
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneSubId=%i&sceneId=%i",GetRequst(URL_FOR_SCENES_DELETE_SCENE_DEVICE),MainDelegate.houseData.houseId,device.sceneSubId,self.eventInfo.sceneId] andName:@"deleteDevice"];
        };
        [alert show];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.eventDetail.timeConditions.count + self.eventDetail.customConditions.count) {
        return 33;
    }
    return 48;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < (self.eventDetail.customConditions.count + self.eventDetail.timeConditions.count)) {
        return NO;
    }
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    MyEEventDevice *device = self.eventDetail.devices[fromIndexPath.row- self.eventDetail.timeConditions.count - self.eventDetail.customConditions.count];
    [self.eventDetail.devices removeObject:device];
    [self.eventDetail.devices insertObject:device atIndex:toIndexPath.row- self.eventDetail.timeConditions.count - self.eventDetail.customConditions.count];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&sceneSubId=%i&sortId=%i",GetRequst(URL_FOR_SCENES_DEVICE_REORDER),MainDelegate.houseData.houseId,self.eventInfo.sceneId,device.sceneSubId,toIndexPath.row- self.eventDetail.timeConditions.count - self.eventDetail.customConditions.count] andName:@"reorder"];
}

#pragma mark - URL  methods
-(void)downloadDevicesFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i",GetRequst(URL_FOR_SCENES_DETAIL),MainDelegate.houseData.houseId,self.eventInfo.sceneId] andName:@"download"];
}
-(void)editSceneToServerWithAction:(NSString *)action{
    int i = [self.eventDetail.customConditions count]+[self.eventDetail.timeConditions count];
    self.eventInfo.type = i > 0?0:1;  //0是自动，1是手动
    NSLog(@" type is %i",self.eventInfo.type);
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&sceneName=%@&type=%i&sortFlag=%i&action=editScene",GetRequst(URL_FOR_SCENES_SAVE_SCENE),MainDelegate.houseData.houseId,self.eventInfo.sceneId,self.eventInfo.sceneName,self.eventInfo.type,self.sortBtn.selected] andName:action];
}
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)url andName:(NSString *)name{
    
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}
#pragma mark - URL DELEGATE methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if (string.intValue == -999){
        [SVProgressHUD showErrorWithStatus:@"NO Connection"];
        return;
    }
    if ([string isEqualToString:@"fail"]) {
        [SVProgressHUD showErrorWithStatus:@"Error!"];
        return;
    }
    
    if ([name isEqualToString:@"download"]) {
        MyEEventDetail *detail = [[MyEEventDetail alloc] initWithJsonString:string];
        self.eventDetail = detail;
        //        NSLog(@"%@\n %@\n %@\n",self.eventDetail.timeConditions,self.eventDetail.customConditions,self.eventDetail.devices);
        //        NSLog(@"%i  %i  %i",[self.eventDetail.timeConditions count],[self.eventDetail.customConditions count],[self.eventDetail.devices count]);
        self.sortBtn.selected = self.eventDetail.sortFlag == 0? NO:YES;
        [self.tableView reloadData];
    }
    if ([name isEqualToString:@"sceneSort"]) {
        
    }
    if ([name isEqualToString:@"reorder"]) {
        
    }
    if ([name isEqualToString:@"deleteDevice"]) {
        if ([string isEqualToString:@"OK"]) {
            MyEEventDevice *device = self.eventDetail.devices[_selectIndex.row-self.eventDetail.timeConditions.count - self.eventDetail.customConditions.count];
            if ([self.eventDetail.devices containsObject:device]) {
                [self.eventDetail.devices removeObject:device];
                [self.tableView reloadData];
            }
        }
    }
    if ([name isEqualToString:@"deleteTime"]) {
        MyEEventConditionTime *time = self.eventDetail.timeConditions[_selectIndex.row];
        if ([self.eventDetail.timeConditions containsObject:time]) {
            [self.eventDetail.timeConditions removeObject:time];
            [self.tableView reloadData];
        }
    }
    if ([name isEqualToString:@"deleteCustom"]) {
        MyEEventConditionCustom *custom = self.eventDetail.customConditions[_selectIndex.row - [self.eventDetail.timeConditions count]];
        if ([self.eventDetail.customConditions containsObject:custom]) {
            [self.eventDetail.customConditions removeObject:custom];
            [self.tableView reloadData];
        }
    }
    if ([name isEqualToString:@"save"]) {
        if ([string isEqualToString:@"OK"]) {
            self.eventInfo.timeTriggerFlag = [self.eventDetail.timeConditions count] > 0?1:0;
            self.eventInfo.conditionTriggerFlag = [self.eventDetail.customConditions count] > 0?1:0;
            if (self.isAdd) {
                [self.events.scenes addObject:self.eventInfo];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - Navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"time"] || [segue.identifier isEqualToString:@"timeEdit"]) {
        MyEEventTimeEditViewController *vc = segue.destinationViewController;
        vc.eventDetail = self.eventDetail;
        vc.isAdd = [segue.identifier isEqualToString:@"time"];
        MyEEventConditionTime *time;
        if ([segue.identifier isEqualToString:@"time"]) {
            time = [[MyEEventConditionTime alloc] init];
        }else
            time = self.eventDetail.timeConditions[[self.tableView indexPathForCell:sender].row];
        NSLog(@"%@",[time changeDateToString]);
        vc.conditionTime = time;
        vc.eventInfo = self.eventInfo;
    }
    if ([segue.identifier isEqualToString:@"condition"] || [segue.identifier isEqualToString:@"conditionEdit"]) {
        MyEEventConditionEditViewController *vc = segue.destinationViewController;
        vc.eventDetail = self.eventDetail;
        MyEEventConditionCustom *custom;
        vc.isAdd = [segue.identifier isEqualToString:@"condition"];
        if ([segue.identifier isEqualToString:@"condition"]) {
            custom = [[MyEEventConditionCustom alloc] init];
        }else
            custom = self.eventDetail.customConditions[[self.tableView indexPathForCell:sender].row - self.eventDetail.timeConditions.count];
        vc.conditionCustom = custom;
        vc.eventInfo = self.eventInfo;
    }
    if ([segue.identifier isEqualToString:@"device"] || [segue.identifier isEqualToString:@"deviceEdit"]) {
        MyEEventDeviceEditViewController *vc = segue.destinationViewController;
        vc.eventInfo = self.eventInfo;
        vc.eventDetail = self.eventDetail;
        vc.isAdd = [segue.identifier isEqualToString:@"device"];
        if ([segue.identifier isEqualToString:@"deviceEdit"]) {
            vc.device = self.eventDetail.devices[[self.tableView indexPathForCell:sender].row- self.eventDetail.timeConditions.count -self.eventDetail.customConditions.count];
        }else
            vc.device = [[MyEEventDevice alloc] init];
    }
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"device"]) {
        if (![[self.eventDetail getDeviceType] count]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"There is no device to be added" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    if ([identifier isEqualToString:@"time"]) {
        if (self.eventDetail.timeConditions.count > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You can add only one time condition." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    if ([identifier isEqualToString:@"condition"]) {
        if (self.eventDetail.customConditions.count > 3) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You can add up to 4 temperature/humidity conditions" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}
@end
