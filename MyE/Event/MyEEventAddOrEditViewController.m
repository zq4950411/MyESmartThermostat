//
//  MyEEventDetailViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventAddOrEditViewController.h"
#import "MyEEventConditionEditViewController.h"
#import "MyEEventTimeEdtiViewController.h"
#import "MyEEventDeviceEditViewController.h"

#define newSize CGSizeMake(280, 35*([self.eventDetail.timeConditions count] + [self.eventDetail.customConditions count]));
@interface MyEEventAddOrEditViewController (){
    BOOL _isShow;  //表示顶部的view是否显示出来了
    MBProgressHUD *HUD;
}

@end

@implementation MyEEventAddOrEditViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [self.conditionTable reloadData];
    [self.deviceTable reloadData];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self changeTopViewFrameWithBool:NO];
    if (self.topBtn.selected) {
        self.topBtn.selected = NO;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.conditionTable.frame = CGRectMake(20, 30, 280, 0);
    self.deviceTable.frame = CGRectMake(20, 30, 280, 0);
    self.conditionTable.tableFooterView = view;
    self.deviceTable.tableFooterView = view;
    self.conditionTable.dataSource = self;
    self.conditionTable.delegate = self;
    self.deviceTable.dataSource = self;
    self.deviceTable.delegate = self;
    self.navigationItem.title = self.eventInfo.sceneName;
    self.navigationController.navigationBar.translucent = NO;
    [self downloadDevicesFromServer];  //编辑的时候要获取数据

    [self.conditionTable addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    NSLog(@"001 property %@ of object %@ change %@",keyPath,object,change);
    if ([change[@"new"] isEqual:change[@"old"]]) {
        [self refreshUIWithBool:NO];
    }
}
-(void)dealloc{  //这个是特别值得注意的
    [self.conditionTable removeObserver:self forKeyPath:@"contentSize"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)deviceSort:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self editSceneToServerWithAction:@"editScene"];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)downOrUpView:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self changeTopViewFrameWithBool:sender.selected];
}

#pragma mark - private methods
-(void)changeTopViewFrameWithBool:(BOOL)flag{
    if (flag) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = self.topView.frame;
            newFrame.origin.y += 70;
            self.topView.frame = newFrame;
            
            CGRect frame = self.conditionTable.frame;
            frame.origin.y += 70;
            self.conditionTable.frame = frame;
        } completion:^(BOOL finished){
        }];
    }else
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = self.topView.frame;
            newFrame.origin.y -= 70;
            self.topView.frame = newFrame;
            CGRect frame = self.conditionTable.frame;
            frame.origin.y -= 70;
            self.conditionTable.frame = frame;
            
        } completion:^(BOOL finished){}];
    [self refreshUIWithBool:NO];
}
-(void)refreshUIWithBool:(BOOL)yes{
    CGFloat x = self.conditionTable.frame.origin.x;
    CGFloat y = self.conditionTable.frame.origin.y;
    CGFloat width = self.conditionTable.contentSize.width;
    CGFloat height = self.conditionTable.contentSize.height;
    CGFloat viewHeight = self.view.bounds.size.height;
    if (yes) {
        self.conditionTable.frame = CGRectMake(x, y, width, height);  //35是conditionTable的行高
        self.deviceTable.frame = CGRectMake(x, y + height, width, viewHeight - y - height-50);
    }else
    [UIView animateWithDuration:0.3 animations:^{
        self.conditionTable.frame = CGRectMake(x, y, width, height);  //35是conditionTable的行高
        self.deviceTable.frame = CGRectMake(x, y + height, width, viewHeight - y - height-50);
    }];
}
#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 100) {
        return [self.eventDetail.customConditions count]+[self.eventDetail.timeConditions count];
    }else
        return [self.eventDetail.devices count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell ;
    if (tableView.tag == 100) {
        if (indexPath.row < [self.eventDetail.timeConditions count]) {
            MyEEventConditionTime *time = self.eventDetail.timeConditions[indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
            UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:100];
            timeLabel.text = [time changeDateToString];
        }else{
            MyEEventConditionCustom *custom = self.eventDetail.customConditions[indexPath.row - [self.eventDetail.timeConditions count]];
            cell = [tableView dequeueReusableCellWithIdentifier:@"weatherCell"];
            UILabel *conditionLabel = (UILabel *)[cell.contentView viewWithTag:100];
            conditionLabel.text = [custom changeDataToString];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        MyEEventDevice *device = self.eventDetail.devices[indexPath.row];
        UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *instruction = (UILabel *)[cell.contentView viewWithTag:102];
        image.image = [device changeTypeToImage];
        nameLabel.text = device.name;
        instruction.text = [device getDeviceInstructionName];
    }
    return cell;
}
#pragma mark - UITable View delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 100) {
        if (indexPath.row < [self.eventDetail.timeConditions count]) {
            MyEEventConditionTime *_newTime = self.eventDetail.timeConditions[indexPath.row];
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Do you want to delete this conditon?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
            alert.rightBlock = ^{
                [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&id=%i&timeType=%i&triggerDate=%@&weekly=%@&hour=%i&minute=%i&action=3",GetRequst(URL_FOR_SCENES_CONDITION_TIME),MainDelegate.houseData.houseId,self.eventInfo.sceneId,_newTime.conditionId,_newTime.timeType,_newTime.date,[_newTime.weeks componentsJoinedByString:@","],_newTime.hour,_newTime.minute] andName:@"deleteTime"];
            };
            [alert show];
        }else{
            MyEEventConditionCustom *_newCustom = self.eventDetail.customConditions[indexPath.row - self.eventDetail.timeConditions.count];
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Do you want to delete this conditon?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
            alert.rightBlock = ^{
                [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&tId=%@&id=%i&dataType=%i&parameterType=%i&parameterValue=%i&action=3",GetRequst(URL_FOR_SCENES_CONDITION_CUSTOM),MainDelegate.houseData.houseId,self.eventInfo.sceneId,_newCustom.tId,_newCustom.conditionId,_newCustom.dataType,_newCustom.parameterType,_newCustom.parameterValue] andName:@"deleteCustom"];
            };
            [alert show];
        }
    }else{
        MyEEventDevice *device = self.eventDetail.devices[indexPath.row];
        
    }
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
    self.eventInfo.type = i > 0?1:0;
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&sceneName=%@&type=%i&sortFlag=%i&action=%@",GetRequst(URL_FOR_SCENES_SAVE_SCENE),MainDelegate.houseData.houseId,self.eventInfo.sceneId,self.eventInfo.sceneName,self.eventInfo.type,self.sortBtn.selected?1:0,action] andName:action];
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
        
        [self.conditionTable reloadData];
        [self.deviceTable reloadData];
        self.sortBtn.selected = self.eventDetail.sortFlag == 0? NO:YES;
        //如果没有可以添加的设备，则该按钮置灰
        if (![[self.eventDetail getDeviceType] count]) {
            self.addBtn.enabled = NO;
        }
    }
    if ([name isEqualToString:@"editScene"]) {
        
    }
    if ([name isEqualToString:@"addScene"]) {
        NSDictionary *dic = [string JSONValue];
        self.eventInfo.sceneId = [dic[@"sceneId"] intValue];
    }
}
#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        self.eventInfo.sceneName = txt.text;
        [self editSceneToServerWithAction:@"editScene"];
    }
}
#pragma mark - Navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"time"] || [segue.identifier isEqualToString:@"timeEdit"]) {
        MyEEventTimeEdtiViewController *vc = segue.destinationViewController;
        vc.eventDetail = self.eventDetail;
        vc.isAdd = [segue.identifier isEqualToString:@"time"];
        MyEEventConditionTime *time;
        if ([segue.identifier isEqualToString:@"time"]) {
            time = [[MyEEventConditionTime alloc] init];
        }else
            time = self.eventDetail.timeConditions[[self.conditionTable indexPathForCell:sender].row];
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
            custom = self.eventDetail.customConditions[[self.conditionTable indexPathForCell:sender].row - self.eventDetail.timeConditions.count];
        vc.conditionCustom = custom;
        vc.eventInfo = self.eventInfo;
    }
    if ([segue.identifier isEqualToString:@"device"] || [segue.identifier isEqualToString:@"deviceEdit"]) {
        MyEEventDeviceEditViewController *vc = segue.destinationViewController;
        vc.eventInfo = self.eventInfo;
        vc.eventDetail = self.eventDetail;
        vc.isAdd = [segue.identifier isEqualToString:@"device"];
        if ([segue.identifier isEqualToString:@"deviceEdit"]) {
            vc.device = self.eventDetail.devices[[self.deviceTable indexPathForCell:sender].row];
        }
    }
}
@end
