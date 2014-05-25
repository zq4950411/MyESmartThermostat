//
//  MyESwitchElecInfoViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchElecInfoViewController.h"
#import "EColumnDataModel.h"
#import "EColumnChartLabel.h"
#import "EFloatBox.h"
#import "EColor.h"
#include <stdlib.h>

@interface MyESwitchElecInfoViewController ()

@end

@implementation MyESwitchElecInfoViewController
@synthesize device;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadElecInfoFromServer];
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)changeDate:(id)sender {
    [self downloadElecInfoFromServer];
}

#pragma mark - private methods
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)defineGestureWith:(EColumnChart *)eco{
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [eco addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [eco addGestureRecognizer:recognizer];
}
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        if (self.eColumnChart == nil) return;
        [self.eColumnChart moveRight];
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        if (self.eColumnChart == nil) return;
        [self.eColumnChart moveLeft];
    }
    
}
-(void)doThisToChangeChart{
    [_eColumnChart removeFromSuperview];
    _eColumnChart = nil;
    _eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 78, 270, 200)];
    [self defineGestureWith:_eColumnChart];
    [_eColumnChart setColumnsIndexStartFromLeft:YES];
    [_eColumnChart setDataSource:self];
    [_eColumnChart setShowHighAndLowColumnWithColor:YES];
    [self.view addSubview:_eColumnChart];
}
-(void)downloadElecInfoFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    NSString *str = [NSString stringWithFormat:@"%@?houseId=%li&tId=%@&action=%i",GetRequst(URL_FOR_SWITCH_ELECT_STATUS),(long)MainDelegate.houseData.houseId, self.device.tid,self.dateSegment.selectedSegmentIndex+1];
    NSLog(@"download elec string is %@",str);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:str postData:nil delegate:self loaderName:@"downloadElecInfo" userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"downloadElecInfo string is %@",string);
    if (![string isEqualToString:@"fail"]) {
        MyEUsageStat *elct = [[MyEUsageStat alloc] initWithString:string];
        
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < [elct.powerRecordList count]; i++)
        {
            MyEUsageStatus *status = elct.powerRecordList[i];
            EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:status.date value:status.totalPower/1000 index:i unit:@"kWh"];
            [temp addObject:eColumnDataModel];
        }
        _data = [NSArray arrayWithArray:temp];
        
        [self doThisToChangeChart];
        //这里说明了小数点后保留几位有效数字
        self.currentLabel.text = [NSString stringWithFormat:@"%0.2f W",elct.currentPower*110];
        self.totalLabel.text = [NSString stringWithFormat:@"%0.2f%@",elct.totalPower/1000, @"\u00B0"];
    }
     else {
        [MyEUtil showMessageOn:nil withMessage:@"Failed to download data"];
    }
}
#pragma -mark- EColumnChartDataSource

- (NSInteger)numberOfColumnsInEColumnChart:(EColumnChart *)eColumnChart
{
    return [_data count];
}

- (NSInteger)numberOfColumnsPresentedEveryTime:(EColumnChart *)eColumnChart
{
    return 6;
}

- (EColumnDataModel *)highestValueEColumnChart:(EColumnChart *)eColumnChart
{
    EColumnDataModel *maxDataModel = nil;
    float maxValue = -FLT_MIN;
    for (EColumnDataModel *dataModel in _data)
    {
        if (dataModel.value > maxValue)
        {
            maxValue = dataModel.value;
            maxDataModel = dataModel;
        }
    }
    return maxDataModel;
}

- (EColumnDataModel *)eColumnChart:(EColumnChart *)eColumnChart valueForIndex:(NSInteger)index
{
    if (index >= [_data count] || index < 0) return nil;
    return [_data objectAtIndex:index];
}

@end
