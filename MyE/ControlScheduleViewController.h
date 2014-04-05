//
//  ControlScheduleViewController.h
//  MyE
//
//  Created by space on 13-8-26.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "TwoDatePicker.h"
#import "ControlSchedule.h"
#import "SequentialCell.h"
#import "WeekCell.h"

@interface ControlScheduleViewController : BaseTableViewController
            <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,TwoDatePickerDelegate>
{
    WeekCell *weekCell;
    SequentialCell *channelCell;
    
    TwoDatePicker *twoDatePickerView;
    __weak ControlSchedule *schedule;
    
    int currentAddIndex;
    
    BOOL isAddAction;
}

@property (nonatomic,strong) WeekCell *weekCell;
@property (nonatomic,strong) SequentialCell *channelCell;

@property (nonatomic,strong) TwoDatePicker *twoDatePickerView;
@property (nonatomic,weak) ControlSchedule *schedule;

-(id) initWithSchedule:(ControlSchedule *) s;

@end
