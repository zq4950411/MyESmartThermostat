//
//  MyEHomePanelViewController.h
//  MyE
//
//  Created by Ye Yuan on 4/14/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACPbutton.h"
@class MyEHomePanelData;
@class MyETerminalData;

@interface MyEHomePanelViewController : UIViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate> {

    MBProgressHUD *HUD;
}
@property (copy, nonatomic) NSString *thermostatId_for_indoor_th;// 仅用于显示当前选择的某个温控器的温度， 需要知道该温控器的tId
@property (strong, nonatomic) MyEHomePanelData *homeData;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UILabel *weatherTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherTemperatureRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *indoorTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertsTileLabel;
@property (weak, nonatomic) IBOutlet UIImageView *alertsTileImageView;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;


@property (weak, nonatomic) IBOutlet ACPButton *indoorInforTile;

@property (weak, nonatomic) IBOutlet ACPButton *elecUsageTile;
@property (weak, nonatomic) IBOutlet ACPButton *thermostatTile;
@property (weak, nonatomic) IBOutlet ACPButton *faultInfoTile;


- (IBAction)selectThermostatForIndoorInformation:(id)sender;

- (IBAction)goElecUsage:(id)sender;
- (IBAction)goToDeviceList:(id)sender;
- (IBAction)goAlerts:(id)sender;
@end
