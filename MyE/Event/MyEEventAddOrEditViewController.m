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
    self.conditionTable.tableFooterView = view;
    self.deviceTable.tableFooterView = view;
    self.conditionTable.dataSource = self;
    self.conditionTable.delegate = self;
    self.deviceTable.dataSource = self;
    self.deviceTable.delegate = self;
    
    self.navigationItem.title = self.eventInfo.sceneName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)editName:(UIButton *)sender {
    
}
- (IBAction)downOrUpView:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"down"]) {
        [sender setTitle:@"up" forState:UIControlStateNormal];
        _isShow = YES;
    }else{
        [sender setTitle:@"down" forState:UIControlStateNormal];
        _isShow = NO;
    }
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

#pragma mark - private methods
-(void)refreshUI{
    CGFloat x = self.conditionTable.frame.origin.x;
    CGFloat y = self.conditionTable.frame.origin.y;
    CGFloat width = self.conditionTable.frame.size.width;
    CGFloat height = self.conditionTable.frame.size.height;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.conditionTable.frame = CGRectMake(x, y, width, 35*([self.eventDetail.timeConditions count] + [self.eventDetail.customConditions count]));  //35是conditionTable的行高
    self.deviceTable.frame = CGRectMake(x, y + height, width, screenHeight - y - height);
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
    }
    return cell;
}
#pragma mark - URL  methods
-(void)downloadDevicesFromServer{
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i",GetRequst(URL_FOR_SMARTUP_LIST),MainDelegate.houseData.houseId] andName:@"downloadDevices"];
}
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}

@end
