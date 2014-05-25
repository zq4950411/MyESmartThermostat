//
//  MyEUsageStatsViewController.h
//  MyE
//
//  Created by Ye Yuan on 5/22/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>


@interface MyEUsageStatsViewController : UIViewController<CPTPlotDataSource>
{
@private
    CPTXYGraph *barChart;
}
@property (assign, nonatomic) BOOL fromHome;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end
