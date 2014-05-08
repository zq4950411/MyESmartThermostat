//
//  ControlViewController.h
//  MyE
//
//  Created by space on 13-8-22.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"

#import "TemperatureCell.h"
#import "WeekCell.h"

#import "LocationViewController.h"
#import "ChooseChannelViewController.h"

@class Sequential;

@interface ControlViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,LocationDelegate>
{
    int type;
    __strong NSMutableArray *channels;
    __weak NSMutableDictionary *currentDic;
    
    Sequential *seq;
    
    TemperatureCell *temperatureCell;
    WeekCell *sequentialWeekCell;
    
    ChooseChannelViewController *chooseVc;
}

@property (nonatomic,strong) Sequential *seq;
@property (nonatomic,strong) ChooseChannelViewController *chooseVc;

-(IBAction) click:(UIBarButtonItem *) sender;

-(void) refreshWithChannel:(NSString *) string;
-(void) refreshWithChannel:(NSString *) string andIndex:(int) index;
-(id) initWithEditType;

@end
