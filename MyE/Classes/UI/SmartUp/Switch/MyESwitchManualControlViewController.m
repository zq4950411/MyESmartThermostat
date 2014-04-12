//
//  MyESwitchManualControlViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-24.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchManualControlViewController.h"

@implementation MyESwitchManualControlViewController

-(void)viewDidLoad{
//    [(UICollectionView *)self.view.subviews[0] setDelaysContentTouches:NO];
    self.collectionView.delaysContentTouches = NO;
    [self downloadInfo];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    if (!IS_IOS6) {
        [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }else{
        [btn setBackgroundImage:[UIImage imageNamed:@"back-ios6"] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"Back" forState:UIControlStateNormal];
    }
    
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    _timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(downloadInfo) userInfo:nil repeats:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadInfo];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (_timer.isValid) {
        [_timer invalidate];
    }
}
#pragma mark - private methods
-(void)downloadInfo{
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@",GetRequst(URL_FOR_SWITCH_FIND_SWITCH_CHANNERL),(long)MainDelegate.houseData.houseId, self.device.tid] andName:@"dowmloadChannelInfo" andDictionary:nil];
}
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name andDictionary:(NSDictionary *)dic{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:dic];
    NSLog(@"%@ is %@",name,loader.name);
}
-(void)setDelayTimeWithStatus:(MyESwitchChannelStatus *)status{
    //#warning 这里是精简至极的MZFormSheetController用法
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"timeDelay"];
    MyEDelayTimeSetViewController *vc = nav.childViewControllers[0];
    MZFormSheetController *formsheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(260, 294) viewController:nav];
    vc.index = _selectedIndex;
    vc.status = status;
    vc.control = self.control;
    vc.device = self.device;
    formsheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
        if (vc.selectedBtnIndex == 100) {  //说明是从确定按钮过来的
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_selectedIndex];
            UIButton *btn = (UIButton *)[cell viewWithTag:102];
            UILabel *delayTimeLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *remainTimeLabel = (UILabel *)[cell viewWithTag:104];
            delayTimeLabel.text = [NSString stringWithFormat:@"Duration:%i Minute(s)",status.delayMinute];
            remainTimeLabel.text = [NSString stringWithFormat:@"Remain:%i Minute(s)",status.delayMinute];
            delayTimeLabel.hidden = NO;
            remainTimeLabel.hidden = NO;
            btn.selected = NO;
            
            UINavigationController *nav = self.tabBarController.childViewControllers[1];
            MyESwitchAutoViewController *vc = nav.childViewControllers[0];
            vc.needRefresh = YES;
            
            if (status.switchStatus == 1) {
            }else
                remainTimeLabel.text = [NSString stringWithFormat:@"Remain:0 Minute"];
//            [self.collectionView reloadData];  //这里不能够刷新数据，否则容易造成数据上的错误
        }
    };
    
    [formsheet presentAnimated:YES completionHandler:nil];
}
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - collectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.control.SCList count];  //这里就是按照有多少通道就新建多少item，没有将数据写死，有助于以后的修改
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    MyESwitchChannelStatus *status = self.control.SCList[indexPath.row];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UIButton *switchBtn = (UIButton *)[cell viewWithTag:101];
    UIButton *timeBtn = (UIButton *)[cell viewWithTag:102];
    UILabel *delayTimeLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *remainTimeLabel = (UILabel *)[cell viewWithTag:104];
//    [_UIArray addObject:@[switchBtn,remainTimeLabel]];
    titleLabel.text = [NSString stringWithFormat:@"Light %li",(long)indexPath.row+1];
    if (status.switchStatus == 1) {
        switchBtn.selected = NO;
        if (status.delayStatus == 1) {
            timeBtn.selected = NO;
            delayTimeLabel.hidden = NO;
            remainTimeLabel.hidden = NO;
            delayTimeLabel.text = [NSString stringWithFormat:@"Duration:%li Minute(s)",(long)status.delayMinute];
            remainTimeLabel.text = [NSString stringWithFormat:@"Remain:%li Minute(s)",(long)status.remainMinute];
        }else{
            timeBtn.selected = YES;
            delayTimeLabel.hidden = YES;
            remainTimeLabel.hidden = YES;
        }
    }else{
        switchBtn.selected = YES;
        if (status.delayStatus == 1) {
            timeBtn.selected = NO;
            delayTimeLabel.hidden = NO;
            remainTimeLabel.hidden = NO;
            delayTimeLabel.text = [NSString stringWithFormat:@"Duration:%li Minute(s)",(long)status.delayMinute];
            remainTimeLabel.text = [NSString stringWithFormat:@"Remain:0 Minute(s)"];
        }else{
            timeBtn.selected = YES;
            delayTimeLabel.hidden = YES;
            remainTimeLabel.hidden = YES;
        }
    }
    return cell;
}
#pragma mark - IBActionMethods
- (IBAction)switchControl:(UIButton *)sender {
    UICollectionViewCell *cell = (UICollectionViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];   //这里有两个方法来指定当前的collectionView
//    NSIndexPath *indexPath = [(UICollectionView *)self.view.subviews[0] indexPathForCell:cell];
    MyESwitchChannelStatus *status = self.control.SCList[indexPath.row];
    _selectedIndex = indexPath;
    NSString *url = [NSString stringWithFormat:@"%@?houseId=%li&tId=%@&id=%li&switchStatus=%li&action=2",GetRequst(URL_FOR_SWITCH_CONTROL),(long)MainDelegate.houseData.houseId, self.device.tid, (long)status.channelId,1-(long)status.switchStatus];
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:url andName:@"controlSwitch"andDictionary:@{@"button": sender,@"status":status}];
}
- (IBAction)timeControl:(UIButton *)sender {
    UICollectionViewCell *cell = (UICollectionViewCell *)sender.superview.superview;
//    NSIndexPath *indexPath = [(UICollectionView *)self.view.subviews[0] indexPathForCell:cell];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    MyESwitchChannelStatus *status = self.control.SCList[indexPath.row];
    if (!sender.selected) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alter" contentText:@"Are you sure to turn off delay setting of current light?" leftButtonTitle:@"Cancel" rightButtonTitle:@"OK"];
        alert.rightBlock = ^{
            UILabel *delayTimeLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *remainTimeLabel = (UILabel *)[cell viewWithTag:104];
            delayTimeLabel.hidden = YES;
            remainTimeLabel.hidden = YES;
            sender.selected = YES;
            status.delayStatus = 0;
            [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&allChannel=%@",GetRequst(URL_FOR_SWITCH_TIME_DELAY_SAVE),(long)MainDelegate.houseData.houseId, self.device.tid,[[MyESwitchChannelStatus alloc] jsonStringWithStatus:status]] andName:@"powerOffDelayTime" andDictionary:nil];
        };
        [alert show];
        return;
    }
    _selectedIndex = indexPath;
    [self setDelayTimeWithStatus:status];
}
- (IBAction)refreshData:(UIBarButtonItem *)sender {
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@",GetRequst(URL_FOR_SWITCH_FIND_SWITCH_CHANNERL),(long)MainDelegate.houseData.houseId, self.device.tid] andName:@"dowmloadChannelInfo" andDictionary:nil];
}

#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"dowmloadChannelInfo"]) {
        NSLog(@"dowmloadChannelInfo string is %@",string);
        if (![string isEqualToString:@"fail"]) {
            MyESwitchManualControl *control = [[MyESwitchManualControl alloc] initWithString:string];
            self.control = control;
            [self.collectionView reloadData];
        }else {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to communicate with server."];
        }
    }
    if ([name isEqualToString:@"controlSwitch"]) {
        NSLog(@"controlSwitch string is %@",string);
        if (![string isEqualToString:@"fail"]) {
            UIButton *btn = (UIButton *)dict[@"button"];
            btn.selected = !btn.selected;
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_selectedIndex];
            UILabel *label = (UILabel *)[cell viewWithTag:104];
            MyESwitchChannelStatus *status = (MyESwitchChannelStatus *)dict[@"status"];
            status.switchStatus = 1 - status.switchStatus;
            if (status.switchStatus == 1) {
                if (status.delayStatus == 1) {
                    label.text = [NSString stringWithFormat:@"Remain:%i Minute(s)",status.delayMinute];
                }
            }else{
                label.text = [NSString stringWithFormat:@"Remain:0 Minute(s)"];
            }
        } else {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to control the switch"];
        }
    }
    if ([name isEqualToString:@"powerOffDelayTime"]) {
        NSLog(@"powerOffDelayTime string is %@",string);
        if ([string isEqualToString:@"OK"]) {
            
        } else {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to communicate with server."];
        }
    }
}
@end