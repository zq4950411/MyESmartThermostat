//
//  MyEUsageStatsViewController.h
//  MyE
//
//  Created by Ye Yuan on 5/22/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>
#import "MyEDropDownMenu.h"


@interface MyEUsageStatsViewController : UIViewController<CPTPlotDataSource,MyEDataLoaderDelegate,MBProgressHUDDelegate>
{
@private
    CPTXYGraph *barChart;
    MBProgressHUD *HUD;

    
    MyEUsageStat *usageData;
}
@property (assign, nonatomic) BOOL fromHome;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *chartView;
@property (weak, nonatomic) IBOutlet UILabel *currentPowerLabel;
@property (weak, nonatomic) IBOutlet UIButton *terminalBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeRangeSegment;

@property (retain, nonatomic) NSArray *validTerminals;
@property (nonatomic, strong) NSMutableArray *terminalNames;
@property (assign, nonatomic) NSUInteger currentTerminalIdx;

- (IBAction)changeTerminal:(id)sender;
- (IBAction)changeTimaeRange:(id)sender;
@end
