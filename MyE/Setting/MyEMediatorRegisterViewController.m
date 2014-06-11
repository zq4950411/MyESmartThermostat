//
//  MyEMediatorRegisterViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-11.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEMediatorRegisterViewController.h"
#import "MyETimeZoneViewController.h"
#import "MyEHouseUsefullViewController.h"

@interface MyEMediatorRegisterViewController (){
    NSInteger _timeZone;
    NSInteger _houseId;
    NSArray *_data;
    NSArray *_usefullHouses;
}

@end

@implementation MyEMediatorRegisterViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self refreshUI];
#warning 这里是做测试
    NSLog(@"time zone is %i",_timeZone);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountData = MainDelegate.accountData;
    _timeZone = 1;
    _data = @[@"EST",@"CST",@"MST",@"PST",@"AKST",@"HST"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)refreshUI{
    NSIndexPath *houseIndex = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *houseCell = [self.tableView cellForRowAtIndexPath:houseIndex];
    if ([_usefullHouses count]) {
        MyEHouseData *house = _usefullHouses[0];
        _houseId = house.houseId;
        houseCell.detailTextLabel.text = house.houseName;
    }else
        houseCell.detailTextLabel.text = @"No House";
    NSIndexPath *timeZoneIndex = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *timeZoneCell = [self.tableView cellForRowAtIndexPath:timeZoneIndex];
    timeZoneCell.detailTextLabel.text = _data[_timeZone];
}
-(void)getUsefullHouse{
    NSMutableArray *array = [NSMutableArray array];
    for (MyEHouseData *d in self.accountData.houseList) {
        if ([d.mId isEqualToString:@""]) {
            [array addObject:d];
        }
    }
    _usefullHouses = array;
}
#pragma mark - IBAction methods
- (IBAction)regestMediator:(ACPButton *)sender {
    
}
- (IBAction)scanCode:(ACPButton *)sender {
    
}

#pragma mark URL Loading System methods
- (void) downloadModelFromServer
{
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@",GetRequst(URL_FOR_HOUSELIST_VIEW), self.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"HouseListDownloader"  userDataDictionary:nil];
    NSLog(@"HouseListDownloader is %@",downloader.name);
}
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"houselist received string: %@", string);
    if([name isEqualToString:@"HouseListDownloader"]) {
        if (![self.accountData updateHouseListByJSONString:string]) {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Communication error. Please try again."
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }else
            [self getUsefullHouse];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"house"]) {
        MyEHouseUsefullViewController *vc = segue.destinationViewController;
        vc.accountData = self.accountData;
    }else{
        MyETimeZoneViewController *vc = segue.destinationViewController;
        vc.timeZone = _timeZone;
    }
}

@end
