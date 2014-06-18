//
//  MyEEventDetailViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventAddOrEditViewController.h"
#import "MyEEventConditionEditViewController.h"
#import "MyEEventTimeEditViewController.h"
#import "MyEEventDeviceEditViewController.h"

#define newSize CGSizeMake(280, 35*([self.eventDetail.timeConditions count] + [self.eventDetail.customConditions count]));
@interface MyEEventAddOrEditViewController (){
    BOOL _isShow;  //表示顶部的view是否显示出来了
    MBProgressHUD *HUD;
    NSIndexPath *_selectIndex;
    UITapGestureRecognizer *_tableTap;
    UILongPressGestureRecognizer *_tableLong;
}

@end

@implementation MyEEventAddOrEditViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadDevicesFromServer];
    }else{
        [self.conditionTable reloadData];
        [self.deviceTable reloadData];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [self performSelector:@selector(refreshUIWithTime:) withObject:0 afterDelay:0.05];
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
    self.conditionTable.tableFooterView = view;
    self.deviceTable.tableFooterView = view;
    self.conditionTable.dataSource = self;
    self.conditionTable.delegate = self;
    self.deviceTable.dataSource = self;
    self.deviceTable.delegate = self;
    self.navigationItem.title = self.eventInfo.sceneName;
    self.navigationController.navigationBar.translucent = NO;
    [self downloadDevicesFromServer];  //编辑的时候要获取数据
    _tableLong = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginTableViewEditing:)];
    [self.deviceTable addGestureRecognizer:_tableLong];
}
/*  ----------------------这里讲的是KVO编程机制，不过对于此处用处不是很大----------------------
    [self.conditionTable addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
}
-(void)dealloc{  //这个是特别值得注意的
    [self.conditionTable removeObserver:self forKeyPath:@"contentSize"];
}
----------------------------------------------------------------------------------------*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)deviceSort:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self editSceneToServerWithAction:@"sceneSort"];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    [self editSceneToServerWithAction:@"save"];
}

- (IBAction)downOrUpView:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self changeTopViewFrameWithBool:sender.selected];
}

#pragma mark - private methods
-(void)beginTableViewEditing:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        if (self.deviceTable.editing) {
            return;
        }
        [self.deviceTable setEditing:!self.deviceTable.editing animated:YES];
        _tableTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTableView:)];
        _tableTap.numberOfTapsRequired = 1;
        [self.deviceTable removeGestureRecognizer:_tableLong];
        [self.deviceTable addGestureRecognizer:_tableTap];
    }
}
// 对于双击和单击事件，不需要对状态进行判断，主要是他这个状态维持的时间很短
-(void)tapOnTableView:(UITapGestureRecognizer *)sender{
    if (!self.deviceTable.editing) {
        return;
    }
    [self.deviceTable setEditing:!self.deviceTable.editing animated:YES];
    [self.deviceTable removeGestureRecognizer:_tableTap];
    [self.deviceTable addGestureRecognizer:_tableLong];
}

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
    [self refreshUIWithTime:0.3];
}
-(void)refreshUIWithTime:(double)time{
    [UIView animateWithDuration:time animations:^{
        CGFloat x = self.conditionTable.frame.origin.x;
        CGFloat y = self.conditionTable.frame.origin.y;
        CGFloat width = self.conditionTable.contentSize.width;
        CGFloat height = 35*(self.eventDetail.timeConditions.count + self.eventDetail.customConditions.count);
        CGFloat viewHeight = self.view.bounds.size.height;
        self.conditionTable.alpha = 1;
        self.deviceTable.alpha = 1;
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
    UIView *view = (UIView *)[cell.contentView viewWithTag:1024];
    view.layer.cornerRadius = 4;
    return cell;
}
#pragma mark - UITable View delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectIndex = indexPath;
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
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Do you want to delete this device?" leftButtonTitle:@"Cancel" rightButtonTitle:@"OK"];
        alert.rightBlock = ^{
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneSubId=%i&sceneId=%i",GetRequst(URL_FOR_SCENES_DELETE_SCENE_DEVICE),MainDelegate.houseData.houseId,device.sceneSubId,self.eventInfo.sceneId] andName:@"deleteDevice"];
        };
        [alert show];
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleNone;
//}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    MyEEventDevice *device = self.eventDetail.devices[fromIndexPath.row];
    [self.eventDetail.devices removeObject:device];
    [self.eventDetail.devices insertObject:device atIndex:toIndexPath.row];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&sceneSubId=%i&sortId=%i",GetRequst(URL_FOR_SCENES_DEVICE_REORDER),MainDelegate.houseData.houseId,self.eventInfo.sceneId,device.sceneSubId,toIndexPath.row] andName:@"reorder"];
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
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&sceneName=%@&type=%i&sortFlag=%i&action=editScene",GetRequst(URL_FOR_SCENES_SAVE_SCENE),MainDelegate.houseData.houseId,self.eventInfo.sceneId,self.eventInfo.sceneName,self.eventInfo.type,self.sortBtn.selected?1:0] andName:action];
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
        [self performSelector:@selector(refreshUIWithTime:) withObject:@(0.3) afterDelay:0.1];
    }
    if ([name isEqualToString:@"sceneSort"]) {
        
    }
    if ([name isEqualToString:@"reorder"]) {
        
    }
    if ([name isEqualToString:@"deleteDevice"]) {
        if ([string isEqualToString:@"OK"]) {
            MyEEventDevice *device = self.eventDetail.devices[_selectIndex.row];
            if ([self.eventDetail.devices containsObject:device]) {
                [self.eventDetail.devices removeObject:device];
                [self.deviceTable reloadData];
//                [self.deviceTable deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];   //这个不能用，否则frame会发生变化
                [self performSelector:@selector(refreshUIWithTime:) withObject:@(0.1) afterDelay:0.1];
            }
        }
    }
    if ([name isEqualToString:@"deleteTime"]) {
        MyEEventConditionTime *time = self.eventDetail.timeConditions[_selectIndex.row];
        if ([self.eventDetail.timeConditions containsObject:time]) {
            [self.eventDetail.timeConditions removeObject:time];
            [self.conditionTable deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.conditionTable reloadData];
            [self performSelector:@selector(refreshUIWithTime:) withObject:@(0.1) afterDelay:0.1];
        }
    }
    if ([name isEqualToString:@"deleteCustom"]) {
        MyEEventConditionCustom *custom = self.eventDetail.customConditions[_selectIndex.row - [self.eventDetail.timeConditions count]];
        if ([self.eventDetail.customConditions containsObject:custom]) {
            [self.eventDetail.customConditions removeObject:custom];
            [self.conditionTable deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.conditionTable reloadData];
            [self performSelector:@selector(refreshUIWithTime:) withObject:@(0.1) afterDelay:0.1];
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
        }else
            vc.device = [[MyEEventDevice alloc] init];
    }
}
@end
