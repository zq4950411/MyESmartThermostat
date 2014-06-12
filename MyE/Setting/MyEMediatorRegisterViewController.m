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
    NSLog(@"time zone is %i  house index is %i",_timeZone,_selectHouseIndex);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.midTxt.pattern = @"^([0-9a-zA-Z]{2}(?:-)){7}[0-9a-zA-Z]{2}$";
    [self.scanBtn setStyleType:ACPButtonOK];
    [self.regestBtn setStyleType:ACPButtonOK];
    self.accountData = MainDelegate.accountData;
    _timeZone = 1;
    _selectHouseIndex = 0;
    _data = @[@"EST",@"CST",@"MST",@"PST",@"AKST",@"HST"];
    [self downloadModelFromServer];
    [self defineTapGestureRecognizer];
    if (!self.jumpFromNav) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setFrame:CGRectMake(0, 0, 50, 30)];
        [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        if (!IS_IOS6) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        }
        [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.midTxt endEditing:YES];
    [self.pinTxt endEditing:YES];
}
-(void)refreshUI{
    NSIndexPath *houseIndex = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *houseCell = [self.tableView cellForRowAtIndexPath:houseIndex];
    if ([_usefullHouses count]) {
        MyEHouseData *house = _usefullHouses[_selectHouseIndex];
        _houseId = house.houseId;
        houseCell.detailTextLabel.text = house.houseName;
    }else{
        _houseId = -100;
        houseCell.detailTextLabel.text = @"No House";
    }
    NSIndexPath *timeZoneIndex = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *timeZoneCell = [self.tableView cellForRowAtIndexPath:timeZoneIndex];
    timeZoneCell.detailTextLabel.text = _data[_timeZone-1];
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
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - IBAction methods
- (IBAction)regestMediator:(ACPButton *)sender {
    if ([self.midTxt.text isEqualToString:@""]) {
        [MyEUtil showMessageOn:nil withMessage:@"M-ID is emperty"];
        return;
    }
    if ([self.pinTxt.text isEqualToString:@""]) {
        [MyEUtil showMessageOn:nil withMessage:@"PIN is emperty"];
        return;
    }
    if (_houseId == -100) {
        [MyEUtil showMessageOn:nil withMessage:@"No House"];
        return;
    }
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?mid=%@&pin=%@&associatedProperty=%i&timeZone=%@",GetRequst(SETTING_REGISTER_GATEWAY),self.midTxt.text,self.pinTxt.text,_houseId,_data[_timeZone - 1]] postData:nil delegate:self loaderName:@"regester" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
- (IBAction)scanCode:(ACPButton *)sender {
    MyEQRScanViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"scan"];
    vc.delegate = self;
    vc.jumpFromNav = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark URL Loading System methods
- (void) downloadModelFromServer
{
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@",GetRequst(URL_FOR_HOUSELIST_VIEW), self.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"HouseListDownloader"  userDataDictionary:nil];
    NSLog(@"HouseListDownloader is %@",downloader.name);
}
#pragma mark - URL delegate methods
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
        }else{
            [self getUsefullHouse];
            [self refreshUI];
        }
    }
    if ([name isEqualToString:@"regester"]) {
        
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"house"]) {
        MyEHouseUsefullViewController *vc = segue.destinationViewController;
        vc.houses = _usefullHouses;
        vc.selectHouseIndex = _selectHouseIndex;
    }else{
        MyETimeZoneViewController *vc = segue.destinationViewController;
        vc.timeZone = _timeZone;
    }
}

#pragma mark - MYEQRscan delegate methods
-(void)passMID:(NSString *)mid andPIN:(NSString *)pin{
    self.midTxt.text = mid;
    self.pinTxt.text = pin;
    [self regestMediator:nil];
}
@end
