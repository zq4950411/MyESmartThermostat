//
//  ScheduleViewController.h
//  MyE
//
//  Created by space on 13-8-15.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "TwoDatePicker.h"

@class WeekCell;
@class ScheduleEntity;

@interface ScheduleViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,TwoDatePickerDelegate>
{
    WeekCell *weekCell;
    TwoDatePicker *twoDatePickerView;
    __weak ScheduleEntity *schedule;
    
    int currentAddIndex;
    
    BOOL isAddAction;
}

@property (nonatomic,strong) WeekCell *weekCell;
@property (nonatomic,strong) TwoDatePicker *twoDatePickerView;
@property (nonatomic,weak) ScheduleEntity *schedule;

-(id) initWithSchedule:(ScheduleEntity *) s;

@end
