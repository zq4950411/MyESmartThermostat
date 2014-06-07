//
//  MyEHomePanelViewController.h
//  MyE
//
//  Created by Ye Yuan on 4/14/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACPbutton.h"
@class MyEDashboardData;

@interface MyEHomePanelViewController : UIViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate> {

    MBProgressHUD *HUD;
}
@property (strong, nonatomic) MyEDashboardData *dashboardData;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UILabel *weatherTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherTemperatureRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *indoorTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;



@property (weak, nonatomic) IBOutlet ACPButton *elecUsageTile;
@property (weak, nonatomic) IBOutlet ACPButton *thermostatTile;
@property (weak, nonatomic) IBOutlet ACPButton *faultInfoTile;



- (IBAction)goElecUsage:(id)sender;
//- (IBAction)goThermostat:(id)sender;
//- (IBAction)goFaultInfo:(id)sender;
- (IBAction)goToDeviceList:(id)sender;
- (IBAction)goAlerts:(id)sender;
@end
