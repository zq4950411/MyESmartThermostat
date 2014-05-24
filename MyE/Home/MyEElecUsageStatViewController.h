//
//  MyEElecUsageStatViewController.h
//  MyE
//
//  Created by Ye Yuan on 5/22/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>


@interface MyEElecUsageStatViewController : UIViewController<CPTPlotDataSource>
{
@private
    CPTXYGraph *barChart;
}
@end
