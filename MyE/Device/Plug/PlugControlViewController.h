//
//  PlugControlViewController.h
//  MyE
//
//  Created by space on 13-8-15.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "LocationViewController.h"

@class PlugEntity;

@interface PlugControlViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,LocationDelegate>
{
    int type;//0:mannual 1:Timer 2:Auto 3:Edit
    UIPickerView *pickerView;
    NSString *selectedTime;
    
    PlugEntity *plug;
    BOOL isStart; //start为1，stop为0
    
    NSTimer *timer;
    BOOL isTimerStart;
}

@property (nonatomic,strong) NSString *selectedTime;
@property (nonatomic,strong) PlugEntity *plug;
@property (nonatomic,strong) NSTimer *timer;

-(IBAction) toolbarClick:(UIBarButtonItem *) sender;




-(void) resetName:(NSString *) name;
-(void) resetLocation:(NSString *) locationId andName:(NSString *) name;
-(void) resetCurrent:(NSString *) current;

-(id) initWithEditType;
-(void) chooseType:(int) t;

@end
