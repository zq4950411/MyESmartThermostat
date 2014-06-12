//
//  MyEUCScheduleViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-7.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCScheduleViewController.h"

@interface MyEUCScheduleViewController (){
    MyEUCSchedule *_newSchedule;
}

@end

@implementation MyEUCScheduleViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _newSchedule = [self.schedule copy];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.weekBtns.selectedButtons = self.schedule.weeks;
    self.weekBtns.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    if (_newSchedule.channels.intValue == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select Channels"];
        return;
    }
    if (![_newSchedule.weeks count]) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select weekDay"];
        return;
    }
    if (![_newSchedule.periods count]) {
        [MyEUtil showMessageOn:nil withMessage:@"Please add a period"];
        return;
    }
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&scheduleId=%i&schedules=%@&action=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_SAVE_PLUG_SCHEDULE),MainDelegate.houseData.houseId,self.device.tid,_newSchedule.scheduleId,[_newSchedule jsonSchedule],self.isAdd?@"addSchedule":@"editSchedule"] postData:nil delegate:self loaderName:self.isAdd?@"add":@"edit" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}

#pragma mark UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.schedule.periods.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MyEUCPeriod *period = self.schedule.periods[indexPath.row];
    UIView *view = (UIView *)[cell.contentView viewWithTag:1024];
    view.layer.cornerRadius = 4;
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:100];
    name.text = [NSString stringWithFormat:@"%@ - %@",[MyEUtil timeStringForHhid:period.stid],[MyEUtil timeStringForHhid:period.edid]];
    return cell;
}
#pragma mark - MYEWeekBtns Delegate methods
-(void)weekButtons:(UIView *)weekButtons selectedButtonTag:(NSArray *)buttonTags{
    
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyEUCPeriodViewController *vc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"add"]) {
        MyEUCPeriod *period = [[MyEUCPeriod alloc] init];
        vc.period = period;
        vc.isAdd = YES;
        vc.schedule = self.schedule;
    }else{
        MyEUCPeriod *period = self.schedule.periods[[self.tableView indexPathForCell:sender].row];
        vc.isAdd = NO;
        vc.period = period;
        vc.schedule = self.schedule;
    }
}
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
#warning 此处缺少对新增和编辑结果的处理
}
@end