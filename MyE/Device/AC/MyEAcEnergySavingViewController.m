//
//  MyEAcComfortViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcEnergySavingViewController.h"

#define AC_COMFORT_DOWNLOADER_NMAE @"AcComfortDownloader"
#define AC_COMFORT_UPLOADER_NMAE @"AcComfortUploader"
@interface MyEAcEnergySavingViewController ()

@end

@implementation MyEAcEnergySavingViewController
@synthesize device, comfort = _comfort;

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _timeArray = [NSMutableArray array];
    for (int i = 0; i < 48; i++) {
        [_timeArray addObject:[NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:i]]];
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    
    [self downloadComfortDataFromServer];
    UIView *view1 = [self.view viewWithTag:200];
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag == 201) {
            v.layer.masksToBounds = YES;
            v.layer.borderWidth = 0.5;
            v.layer.borderColor = [UIColor lightGrayColor].CGColor;
            v.layer.cornerRadius = 4;
        }
    }
    for (UIButton *btn in view1.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
        }
    }
}
#pragma mark - private methods
-(void)_refreshUI
{
    [self.comfortFlagSwitch setOn:self.comfort.comfortFlag animated:YES ];
    self.overView.hidden = self.comfort.comfortFlag;
    if (self.comfort.comfortRiseTime) {  //这里是要进行判断该值是否存在
        [self.riseTimeBtn setTitle:self.comfort.comfortRiseTime forState:UIControlStateNormal];
    }else
        [self.riseTimeBtn setTitle:@"0:00" forState:UIControlStateNormal];
    if (self.comfort.comfortSleepTime) {
        [self.sleepTimeBtn setTitle:self.comfort.comfortSleepTime forState:UIControlStateNormal];
    }else
        [self.sleepTimeBtn setTitle:@"0:00" forState:UIControlStateNormal];
}

-(void)setBtnTitle{
    //    NSString *provinceName,*cityName;
    //    MyEProvinceAndCity *provinceAndCity = [[MyEProvinceAndCity alloc] init];
    //    for (MyEProvince *p in provinceAndCity.provinceAndCity) {
    //        NSLog(@"%@",p.provinceName);
    //        if ([p.provinceId isEqualToString:self.comfort.provinceId]) {
    //            provinceName = p.provinceName;
    //            for (MyECity *c in p.cities) {
    //                if ([c.cityId isEqualToString:self.comfort.cityId]) {
    //                    cityName = c.cityName;
    //                    break;
    //                }
    //            }
    //            break;   //break的必要性，这个可以加快程序的运行
    //        }
    //    }
    //    //这里特别值得注意，btn在enable未被选中的前提下，不允许修改btn的title
    //    UIView *view = (UIView *)[self.view viewWithTag:201];
    //    UIButton *btn = (UIButton *)[view viewWithTag:100];
    //    [btn setTitle:[NSString stringWithFormat:@"%@ %@",provinceName,cityName] forState:UIControlStateNormal];
}
- (void)decideIfComfortChanged
{
    if (self.comfort != Nil && _comfort_copy != Nil) {
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *original = [writer stringWithObject:[self.comfort JSONDictionary]];
        NSString *copy = [writer stringWithObject:[_comfort_copy JSONDictionary]];
        if ([original isEqualToString:copy]) {
            self.saveBtn.enabled = NO;
        }else
            self.saveBtn.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - setter methods
-(void)setComfort:(MyEAcComfort *)comfort
{
    if(_comfort != comfort){
        _comfort = comfort;
        _comfort_copy = [comfort copy];
        [self _refreshUI];
    }
}
#pragma mark - URL private methods
- (void)downloadComfortDataFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%@&houseId=%i",
                        GetRequst(URL_FOR_AC_COMFORT_VIEW),
                        self.device.tid,
                        self.device.deviceId,MainDelegate.houseData.houseId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil delegate:self
                                 loaderName:AC_COMFORT_DOWNLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"ac comfort string is %@",string);
    if([name isEqualToString:AC_COMFORT_DOWNLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [SVProgressHUD showErrorWithStatus:@"fail"];
        } else  {
            MyEAcComfort *comfort = [[MyEAcComfort alloc] initWithJSONString:string];
            if(comfort){
                self.comfort = comfort;
            }
            [self setBtnTitle];
        }
        [self decideIfComfortChanged];
    }
    if([name isEqualToString:AC_COMFORT_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [SVProgressHUD showErrorWithStatus:@"fail"];
            self.comfort = [_comfort_copy copy];// revert the value
        } else  {
            _comfort_copy = [self.comfort copy];// clone the backup data
        }
        [self decideIfComfortChanged];
    }
    
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

#pragma mark - IBAction methods
- (IBAction)comfortSwitchChanged:(UISwitch *)sender {
    self.overView.hidden = sender.isOn;
    self.comfort.comfortFlag = self.comfortFlagSwitch.on;
    [self decideIfComfortChanged];
}
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)riseTimeAction:(UIButton *)sender {
    MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:0 title:@"Rise Time" dataSource:_timeArray andSelectRow:[_timeArray containsObject:sender.currentTitle]?[_timeArray indexOfObject:sender.currentTitle]:0];
    picker.delegate = self;
    [picker showInView:self.view];
}
- (IBAction)sleepTimeAction:(UIButton *)sender {
    MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"Sleep Time" dataSource:_timeArray andSelectRow:[_timeArray containsObject:sender.currentTitle]?[_timeArray indexOfObject:sender.currentTitle]:0];
    picker.delegate = self;
    [picker showInView:self.view];
}

- (IBAction)saveComfortAction:(UIBarButtonItem *)sender {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?houseId=%i&tId=%@&comfortFlag=%ld&comfortRiseTime=%@&comfortSleepTime=%@",
                        GetRequst(URL_FOR_AC_COMFORT_SAVE),MainDelegate.houseData.houseId,
                        self.device.tid,
                        (long)(self.comfort.comfortFlag?1:0),
                        self.comfort.comfortRiseTime,
                        self.comfort.comfortSleepTime];
    MyEDataLoader *uploader = [[MyEDataLoader alloc]
                               initLoadingWithURLString:urlStr
                               postData:nil delegate:self
                               loaderName:AC_COMFORT_UPLOADER_NMAE
                               userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}

//    [self.mainContainer setFrame:CGRectMake(self.mainContainer.frame.origin.x, 0, self.mainContainer.frame.size.width, self.mainContainer.frame.size.height)];

#pragma mark - MYEPickerView delegate method
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
//    if (pickerView.tag == 0) {
//        self.comfort.comfortRiseTime = [NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:row]];
//    }else {
//        self.comfort.comfortSleepTime = [NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:row]];
//    }
    if (pickerView.tag == 0) {
        self.comfort.comfortRiseTime = title;
    }else
        self.comfort.comfortSleepTime = title;
    [self _refreshUI];
    [self decideIfComfortChanged];
}
@end
