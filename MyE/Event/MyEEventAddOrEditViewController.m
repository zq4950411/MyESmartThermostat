//
//  MyEEventDetailViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventAddOrEditViewController.h"

@interface MyEEventAddOrEditViewController (){
    BOOL _isShow;  //表示顶部的view是否显示出来了
    MBProgressHUD *HUD;
}

@end

@implementation MyEEventAddOrEditViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [self refreshUI];
    [self.conditionTable reloadData];
    [self.deviceTable reloadData];
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
    if (self.isAdd) {
        [self editSceneToServerWithAction:@"addScene"];
    }else
        [self downloadDevicesFromServer];  //编辑的时候要获取数据
    
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

- (IBAction)editName:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Enter A New Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *txt = [alert textFieldAtIndex:0];
    txt.text = self.eventInfo.sceneName;
    txt.textAlignment = NSTextAlignmentCenter;
    [alert show];
}
- (IBAction)downOrUpView:(UIButton *)sender {
    sender.selected = !sender.selected;
    _isShow = sender.selected;
    if (_isShow) {
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
    [self refreshUI];
}
- (IBAction)addDevice:(UIButton *)sender {
    [self refreshUI];
}

#pragma mark - private methods
-(void)refreshUI{
    [MyEUtil getFrameDetail:self.conditionTable andName:@"conditionTable"];
    [MyEUtil getFrameDetail:self.deviceTable andName:@"deviceTable"];
    self.sortBtn.selected = self.eventDetail.sortFlag == 0? NO:YES;
    
    CGFloat x = self.conditionTable.frame.origin.x;
    CGFloat y = self.conditionTable.frame.origin.y;
    CGFloat width = self.conditionTable.frame.size.width;
    CGFloat height = 35*([self.eventDetail.timeConditions count] + [self.eventDetail.customConditions count]);
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.conditionTable.frame = CGRectMake(x, y, width, height);  //35是conditionTable的行高
        self.deviceTable.frame = CGRectMake(x, y + height, width, screenHeight - y - height);
        
    }completion:^(BOOL finished){
        
    }];
    [MyEUtil getFrameDetail:self.conditionTable andName:@"conditionTable"];
    [MyEUtil getFrameDetail:self.deviceTable andName:@"deviceTable"];
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
//        [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:YES];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self refreshUI];
//            self.sortBtn.selected = YES;
//            self.sortBtn.selected = self.eventDetail.sortFlag == 0? NO:YES;
//        });
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
@end
