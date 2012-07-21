//
//  MyEVacationDetailViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/15/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEVacationDetailViewController.h"
#import "MyEStaycationEditFromVacationViewController.h"
#import "MyEStaycationDetailViewController.h"
#import "MyEVacationItemData.h"
#import "MyEStaycationItemData.h"
#import "MyEUtil.h"

@interface MyEVacationDetailViewController ()
- (void)configureView;
- (void)dateTimePickerValueChanged:(id)sender;
- (void)doneEditing;
- (void)saveVacationItem;
- (void)deleteVacationItem;
@end

@implementation MyEVacationDetailViewController
@synthesize vacationTypeSegmentedControl = _vacationTypeSegmentedControl;
@synthesize doneButton = _doneButton, saveButton = _saveButton, deleteButton = _deleteButton;
@synthesize datePicker = _datePicker, setpointPicker = _setpointPicker;
@synthesize dateFormatter = _dateFormatter, timeFormatter = _timeFormatter, dateTimeFormatter = _dateTimeFormatter;

@synthesize vacationItem = _vacationItem, nameTextField = _nameTextField;
@synthesize leaveDateTextField = _leaveDateTextField, leaveTimeTextField = _leaveTimeTextField;
@synthesize returnDateTextField = _lreturnDateTextField, returnTimeTextField = _returnTimeTextField;
@synthesize coolingTextField = _coolingTextField, heatingTextField = _heatingTextField;
@synthesize delegate = _delegate, editType = _editType;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    isSelfViewTransformed = NO;
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(dateTimePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.minuteInterval = 30;
    
    self.leaveDateTextField.inputView = self.datePicker; 
    self.leaveTimeTextField.inputView = self.datePicker; 
    self.returnDateTextField.inputView = self.datePicker; 
    self.returnTimeTextField.inputView = self.datePicker; 
    
    
    self.setpointPicker = [[UIPickerView alloc] init];
    [self.setpointPicker setDelegate:self];
    [self.setpointPicker setDataSource:self];
    self.setpointPicker.showsSelectionIndicator = YES;
    self.coolingTextField.inputView = self.setpointPicker;
    self.heatingTextField.inputView = self.setpointPicker;
      
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [self.dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"HH:mm"];
    [self.timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    
    self.dateTimeFormatter = [[NSDateFormatter alloc] init];
    [self.dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    [self.dateTimeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];

    
    // 设置各个TextField的delegate为self
    // 设置各个TextField的delegate为self
    self.nameTextField.delegate = self;
    self.leaveDateTextField.delegate = self;
    self.leaveTimeTextField.delegate = self;
    self.returnDateTextField.delegate = self;
    self.returnTimeTextField.delegate = self;
    self.coolingTextField.delegate = self;
    self.heatingTextField.delegate = self;
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self       
                                                      action:@selector(doneEditing)];
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                      target:self       
                                                      action:@selector(saveVacationItem)];
    self.deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                      target:self       
                                                      action:@selector(deleteVacationItem)];
    
    // 默认情况，此面板是可编辑的。由于在MyEVacationMasterViewController里面转到此面板的prepareForSegue::函数中，
    // 会设置_editable的值，但设置时还没系统运行到这里，所以这里随便重置_editable的值会导致前面设置的_editable的值失效。
    // 所以这里先要判断是否在MyEVacationMasterViewController的prepareForSegue::函数中已经设置了是新增vacation的编辑类型
    if(self.editType == 1)//如果编辑类型是新增。
        _editable = YES;
    
    // 有可能在从前一个view controller转入本view controller时，先调用了setEditable:函数，设置了_editable属性，但是此时view上的subviews还没加载生成，所以不能设置个subviews的enabled属性。此处，一加载完成，重新调用setEditable:函数来设置是否能编辑
    [self setEditable:_editable];
    
    // Update the view.
    [self configureView];

}

- (void)viewDidUnload
{
    self.vacationItem = nil;
    [self setDoneButton:nil];
    [self setSaveButton:nil];
    [self setDelegate:nil];
    [self setNameTextField:nil];
    [self setLeaveDateTextField:nil];
    [self setLeaveTimeTextField:nil];
    [self setReturnDateTextField:nil];
    [self setReturnTimeTextField:nil];
    [self setCoolingTextField:nil];
    [self setHeatingTextField:nil];

    [self setDateFormatter:nil];
    [self setTimeFormatter:nil];
    [self setDateTimeFormatter:nil];
    
    [self setVacationTypeSegmentedControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewWillAppear:(BOOL)animated{
    if(self.editType == 0) {//编辑类型为查看
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveButton, self.deleteButton, nil];
    }
    else {//编辑类型为新增假期
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
} 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowStaycationEditFromVacation"]) {
        MyEStaycationEditFromVacationViewController *staycationViewController = [segue destinationViewController];
        staycationViewController.delegate = (id <MyEStaycationDetailViewControllerDelegate>) self.delegate;
        staycationViewController.editType = self.editType;//editType：0-修改， 1-新增， 2-删除
        MyEStaycationItemData * staycationItem = [[MyEStaycationItemData alloc] init];
        
        //构建一个新的vacation数据，并传递到接下来要出现vacation编辑面板以供显示
        staycationItem.name = self.nameTextField.text;

        // 把本面板的name、日期传递到staycation面板
        staycationItem.startDate = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        staycationItem.endDate = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        
        // 现在不需要把Vacation的时刻time，setpoints传递到staycation了，所以注释了下面的代码
//        staycationItem.riseTime = [self.timeFormatter dateFromString:self.leaveTimeTextField.text];
//        staycationItem.sleepTime = [self.timeFormatter dateFromString:self.returnTimeTextField.text];
//        staycationItem.dayCooling = [self.coolingTextField.text intValue];
//        staycationItem.dayHeating = [self.heatingTextField.text intValue];
//        staycationItem.nightCooling = [self.coolingTextField.text intValue];
//        staycationItem.nightHeating = [self.heatingTextField.text intValue];
        staycationItem.old_end_date = self.vacationItem.old_end_date;
        staycationViewController.staycationItem = staycationItem;
    }
}


- (void)setVacationItem:(MyEVacationItemData *)vacationItem
{
    if (_vacationItem != vacationItem) {
        _vacationItem = vacationItem;
        
        // Update the view.
        [self configureView];
    }
}

// 有可能在从前一个view controller转入本view controller时，先调用了setEditable:函数，设置了_editable属性，但是此时view上的subviews还没加载生成，所以不能设置个subviews的enabled属性。在viewDidLoad中，一加载完成，重新调用setEditable:函数来设置是否能编辑
- (void) setEditable:(BOOL)editable {
    _editable = editable;
    self.nameTextField.enabled = editable;
    self.nameTextField.textColor = editable ? [UIColor blackColor] : [UIColor grayColor];
    
    self.vacationTypeSegmentedControl.enabled = editable;
    self.vacationTypeSegmentedControl.alpha = editable ? 1 : 0.439216;
    
    self.leaveDateTextField.enabled = editable;
    self.leaveDateTextField.textColor = editable ? [UIColor blackColor] : [UIColor grayColor];
    
    self.leaveTimeTextField.enabled = editable;
    self.leaveTimeTextField.textColor = editable ? [UIColor blackColor] : [UIColor grayColor];
    
    self.returnDateTextField.enabled = editable;
    self.returnDateTextField.textColor = editable ? [UIColor blackColor] : [UIColor grayColor];
    
    self.returnTimeTextField.enabled = editable;
    self.returnTimeTextField.textColor = editable ? [UIColor blackColor] : [UIColor grayColor];
    
    self.heatingTextField.enabled = editable;
    self.heatingTextField.textColor = editable ? [UIColor blackColor] : [UIColor grayColor];
    
    self.coolingTextField.enabled = editable;
    self.coolingTextField.textColor = editable ? [UIColor blackColor] : [UIColor grayColor];
    
    //editType：0-修改， 1-新增， 2-删除
    if (editable) {
        if(self.editType == 0) {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.saveButton, self.deleteButton, nil];
        } else {
            self.navigationItem.rightBarButtonItem = self.saveButton;
        }
    } else {
        if(self.editType == 0) {
            self.navigationItem.rightBarButtonItems = nil;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    
}

#pragma mark
#pragma mark private methods
- (void)dateTimePickerValueChanged:(id)sender {
    if (_currentEditingTextField == self.leaveDateTextField) {
        NSDate *oldStartDate = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        NSDate *oldEndDate = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        
        if ([oldStartDate compare:self.datePicker.date] == NSOrderedDescending || [oldStartDate compare:self.datePicker.date] == NSOrderedSame) 
            NSLog(@"	当把start date提前、或不动的时候，end date不做任何自动调整；");
        
        if ([oldStartDate compare:self.datePicker.date] == NSOrderedAscending) {
            NSLog(@"	当把start date推迟的时候：");
            if ([self.datePicker.date compare:oldEndDate] == NSOrderedAscending) {
                NSLog(@"	如果调整后start date < end date，则end date不做任何自动调整；");
            }  
            else{
                NSLog(@"	如果调整后start date >= end date，则end date自动也往后调整，保持总是比start date晚一天。");
                // 把返回日期更新为原来返回日期加上 leaveDateOffsetInDay
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:1];
                NSDate *newReturnDate = [calendar dateByAddingComponents:offsetComponents toDate:self.datePicker.date options:0];
                
                self.returnDateTextField.text = [self.dateFormatter stringFromDate:newReturnDate];
            }
        }
        
        // 最后，用DatePicker的新的日期来更新 leaveDateTextField 域的文字
        self.leaveDateTextField.text = [self.dateFormatter stringFromDate:((UIDatePicker *)self.leaveDateTextField.inputView).date];
    }
    if (_currentEditingTextField == self.leaveTimeTextField) {
        // mark mmmmm
        // 如果当前离开和返回日期是在同一天，就要设置结束时间从开始时间之后半小时到24:00.
        NSDate *startDate = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        NSDate *endDate = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        if ([startDate compare:endDate] == NSOrderedSame) {
            NSDate *oldStartDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.leaveDateTextField.text, self.leaveTimeTextField.text]];
            NSDate *oldEndDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.returnDateTextField.text, self.returnTimeTextField.text]];
            
            NSDate *newStartDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",self.leaveDateTextField.text, [self.timeFormatter stringFromDate:self.datePicker.date]]];
            
            if ([oldStartDate compare:newStartDate] == NSOrderedDescending || [oldStartDate compare:newStartDate] == NSOrderedSame) 
                NSLog(@"	当把start date提前、或不动的时候，end date不做任何自动调整；");
            

            if ([oldStartDate compare:newStartDate] == NSOrderedAscending) {
                NSLog(@"	当把start date推迟的时候：");
                if ([newStartDate compare:oldEndDate] == NSOrderedAscending) {
                    NSLog(@"	如果调整后start date < end date，则end date不做任何自动调整；");
                }  
                else{
                    NSLog(@"	如果调整后start date >= end date，则end date自动也往后调整，保持总是比start date晚一天。");
                    // 把返回日期更新为原来返回日期加上 leaveDateOffsetInDay
                    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                    [offsetComponents setMinute:30];
                    NSDate *newReturnDateTime = [calendar dateByAddingComponents:offsetComponents toDate:newStartDate options:0];
                    
                    self.returnTimeTextField.text = [self.timeFormatter stringFromDate:newReturnDateTime];
                    self.returnDateTextField.text = [self.dateFormatter stringFromDate:newReturnDateTime];//有可能离开开始时间向后推，导致结束时间一直推到下一天，所以要更新结束返回日期
                }
            }
            
        }
        
        
        
        
        
        self.leaveTimeTextField.text = [self.timeFormatter stringFromDate:self.datePicker.date ];
    }
    if (_currentEditingTextField == self.returnDateTextField) {
        // 必须先更新returnDateTextField
        self.returnDateTextField.text = [self.dateFormatter stringFromDate:self.datePicker.date ];
        
        // mark mmmmm
        // 如果更新后的结束日期和开始日期在同一天，要判定开始时间和结束时间的关系，
        NSDate *startDate = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        NSDate *endDate = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        if ([startDate compare:endDate] == NSOrderedSame) {
            NSDate *oldStartDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.leaveDateTextField.text, self.leaveTimeTextField.text]];
            NSDate *oldEndDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.returnDateTextField.text, self.returnTimeTextField.text]];

            if ([oldStartDate compare:oldEndDate] == NSOrderedAscending) {
                NSLog(@"	转到同一天后，时间先后顺序正常");
            }
            else{
                NSLog(@"	转到同一天后，时间先后顺序不正常，则结束时间自动也往后调整，保持总是比开始时间晚半小时。");
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setMinute:30];
                NSDate *newReturnDateTime = [calendar dateByAddingComponents:offsetComponents toDate:oldStartDate options:0];
                
                self.returnTimeTextField.text = [self.timeFormatter stringFromDate:newReturnDateTime];
                self.returnDateTextField.text = [self.dateFormatter stringFromDate:newReturnDateTime];//有可能离开开始时间向后推，导致结束时间一直推到下一天，所以要更新结束返回日期
                self.datePicker.date = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%@", self.returnDateTextField.text]];
            }
            
        }
    } 
    if (_currentEditingTextField == self.returnTimeTextField) {
        self.returnTimeTextField.text = [self.timeFormatter stringFromDate:self.datePicker.date ];
    } 
    
}

- (void)configureView
{
    // Update the user interface for the detail item.
    MyEVacationItemData *vacationItem = self.vacationItem;
    
    
    if (vacationItem) {
        self.nameTextField.text = vacationItem.name;
        self.leaveDateTextField.text = [self.dateFormatter stringFromDate:vacationItem.leaveDateTime];
        self.leaveTimeTextField.text = [self.timeFormatter stringFromDate:vacationItem.leaveDateTime];
        self.returnDateTextField.text = [self.dateFormatter stringFromDate:vacationItem.returnDateTime];
        self.returnTimeTextField.text = [self.timeFormatter stringFromDate:vacationItem.returnDateTime];
        self.heatingTextField.text = [NSString stringWithFormat:@"%i", vacationItem.heating];
        self.coolingTextField.text = [NSString stringWithFormat:@"%i", vacationItem.cooling];
    }

}
- (void)saveVacationItem {
    
    NSLog(@"Save a vacation starting from staycation");
    [self updateDataModelByView];
    
    if([self.vacationItem.leaveDateTime compare:self.vacationItem.returnDateTime] == NSOrderedDescending) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Alert" 
                                                      message:@"The leave time must be earlier than the return time."
                                                     delegate:self 
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*注意，必须先返回到Master view，然后再调用delegate的didFinishEditStaycation:editType:方法，
     否则在Remote从YES变成NO的时候，由于返回Master View太慢，而导致已经进入到了didReceiveString方法来处理从服务器返回的-998/-999，
     此时会导致在NavigationControlle堆栈中的view之间进行转移，但由于还没返回Master view，所以导致view之间转移出错。*/
    //下面代码返回到master view。
    [[self navigationController] popViewControllerAnimated:YES];
    
    
    if ([self.delegate respondsToSelector:@selector(didFinishEditVacation:editType:)]) {
        [self.delegate didFinishEditVacation:self.vacationItem editType:self.editType];//editType：0-修改， 1-新增， 2-删除
    }
}
- (void)doneEditing {
    [_currentEditingTextField resignFirstResponder];
    if(self.editType == 0) {//editType：0-修改， 1-新增， 2-删除
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveButton, self.deleteButton, nil];
    }
    else {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
}
-(void)deleteVacationItem {
    //弹出对话框，询问删除，并想代理发送删除指令
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Delete" 
                                                  message:@"Are you sure you want to delete this item?"
                                                 delegate:self 
                                        cancelButtonTitle:@"YES"
                                        otherButtonTitles:@"NO",nil];
    [alert show];
}
#pragma mark -
#pragma mark UIAlertViewDelegate methods
-(void)alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(int)index
{
    if([alertView.title isEqualToString:@"Delete"] && index == 0) {
        [[self navigationController] popViewControllerAnimated:YES];
        
        if ([self.delegate respondsToSelector:@selector(didFinishEditVacation:editType:)]) {
            [self.delegate didFinishEditVacation:self.vacationItem editType:2];//editType：0-修改， 1-新增， 2-删除
        }
    }
}
#pragma mark -
//用户可能编辑了界面控件的东西，调用此函数把修改的东西更新到数据模型里
- (void) updateDataModelByView {
    self.vacationItem.name = [NSString stringWithString:self.nameTextField.text];
    self.vacationItem.leaveDateTime = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.leaveDateTextField.text, self.leaveTimeTextField.text]];
    self.vacationItem.returnDateTime = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.returnDateTextField.text, self.returnTimeTextField.text]];
    self.vacationItem.cooling = [self.coolingTextField.text intValue];
    self.vacationItem.heating = [self.heatingTextField.text intValue];   
}

#pragma mark -
#pragma mark Picker Data Source Methodes 数据源方法

//选取器如果有多个滚轮，就返回滚轮的数量，我们这里有两个，就返回2
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
//返回给定的组件有多少行数据
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_currentEditingTextField == self.coolingTextField) {
        return 90 - ([self.heatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP) + 1;
    } else if (_currentEditingTextField == self.heatingTextField) {
        return ([self.coolingTextField.text intValue]- MINIMUM_HEATING_COOLING_GAP -55) + 1;
    } else
        return 36;
}

#pragma mark -
#pragma mark Picker Delegate Methods 委托方法

//官方的意思是，指定组件中的指定数据，就是每一行所对应的显示字符是什么。
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (_currentEditingTextField == self.coolingTextField) {
        return [NSString stringWithFormat:@"     %i", row + [self.heatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP];
    } else if (_currentEditingTextField == self.heatingTextField) {
        return [NSString stringWithFormat:@"     %i", row + 55];
    } else
        return [NSString stringWithFormat:@"     %i", row + 55];
}

//当选取器的行发生改变的时候调用这个方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_currentEditingTextField == self.coolingTextField) {
        _currentEditingTextField.text = [NSString stringWithFormat:@"%i", row + [self.heatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP];
    } else if (_currentEditingTextField == self.heatingTextField) {
        _currentEditingTextField.text = [NSString stringWithFormat:@"%i", row + 55];
    } else
        _currentEditingTextField.text = [NSString stringWithFormat:@"%i", row + 55];
}
// returns width of column and height of row for each component. 
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 100;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}


#pragma mark
#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentEditingTextField = textField;

    if(self.editType == 0) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.doneButton, self.deleteButton, nil];
    }
    else {
        self.navigationItem.rightBarButtonItem = self.doneButton;
    }
    
    if (textField == self.leaveDateTextField) {
        //下面设置start date picker的允许的最早和最晚时间。最早时间比当前时刻晚一天
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        
        //设置默认离开时间最早允许是当前时间的第二天
        [offsetComponents setDay:1];
        NSDate *minimumDate = [calendar dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        self.datePicker.minimumDate = minimumDate;


        /*
        // 用返回日期来约束离开日期，现在不用了。
        NSDate *returnDate = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        [offsetComponents setDay:-1];
        NSDate *maximumDate = [calendar dateByAddingComponents:offsetComponents toDate:returnDate options:0];
        self.datePicker.maximumDate = maximumDate;
        */
        
        // 下面修改成对开始离开日期不做返回日期的限制，只修改成最晚不超过5年后
        [offsetComponents setDay:0];
        [offsetComponents setYear:5];
        NSDate *maximumDate = [calendar dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        self.datePicker.maximumDate = maximumDate;

        self.datePicker.date = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    }
    if (textField == self.leaveTimeTextField) {
        // mark mmmmm
        // 如果当前离开和返回日期是在同一天，就要设置开始时间的范围是0点到23：30.
        NSDate *startDate = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        NSDate *endDate = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        if ([startDate compare:endDate] == NSOrderedSame) {
            self.datePicker.minimumDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00", self.leaveDateTextField.text]];
           
            self.datePicker.maximumDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:30", self.leaveDateTextField.text]];
        }else {// 否则取消允许时间范围限制
            self.datePicker.minimumDate = nil;
            self.datePicker.maximumDate = nil;
        }
        
        
        self.datePicker.date = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.leaveDateTextField.text, self.leaveTimeTextField.text]];
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    }
    if (textField == self.returnDateTextField) {        
        //下面设置return date picker的允许的最早和最晚时间。最早时间比最新的leave date当前时刻晚一天，最晚时刻是5年后的今天
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // now build a NSDate object for the current day
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:0];
        NSDate *leaveDate = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        NSDate *minimumDate = [calendar dateByAddingComponents:offsetComponents toDate:leaveDate options:0];
        self.datePicker.minimumDate = minimumDate;
        
        [offsetComponents setDay:0];
        [offsetComponents setYear:5];
        NSDate *maximumDate = [calendar dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        self.datePicker.maximumDate = maximumDate;

        
        self.datePicker.date = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
    }
    if (textField == self.returnTimeTextField) {
        // mark mmmmm
        // 如果当前离开和返回日期是在同一天，就要设置结束时间从开始时间之后半小时到24:00.
        NSDate *startDate = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        NSDate *endDate = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        if ([startDate compare:endDate] == NSOrderedSame) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            
            [offsetComponents setMinute:30];
            NSDate *currentStartDateTime = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.leaveDateTextField.text, self.leaveTimeTextField.text]];
            NSLog(@"%@", currentStartDateTime);
            NSDate *minimumDate = [calendar dateByAddingComponents:offsetComponents toDate:currentStartDateTime options:0];
            self.datePicker.minimumDate = minimumDate;
            
            NSDate *maximumDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59", self.leaveDateTextField.text]];
            self.datePicker.maximumDate = maximumDate;
        }else {// 否则取消允许时间范围限制
            self.datePicker.minimumDate = nil;
            self.datePicker.maximumDate = nil;
        }
        
        self.datePicker.date = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.returnDateTextField.text, self.returnTimeTextField.text]];
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    }
    
    if (textField == self.coolingTextField) {
        [self.setpointPicker selectRow:[textField.text intValue]-[self.heatingTextField.text intValue]-MINIMUM_HEATING_COOLING_GAP inComponent:0 animated:YES];
        [self.setpointPicker setNeedsLayout];
    }
    if (textField == self.heatingTextField) {
        [self.setpointPicker selectRow:[textField.text intValue]-55 inComponent:0 animated:YES];
        [self.setpointPicker setNeedsLayout];
    }
    // 虚拟键盘的高度是170
    // 如果当前View还没被上移，并如果键盘覆盖了当前的textField，就把整个view上移170高度。
    if(self.view.frame.origin.y == 0 && (textField.frame.origin.y + textField.frame.size.height > self.view.frame.size.height - 170))
    {
        isSelfViewTransformed = YES;
        CGRect newFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 170, self.view.frame.size.width ,self.view.frame.size.height);
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:0.30f];  
        self.view.frame = newFrame;
        
        [UIView commitAnimations];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(isSelfViewTransformed){
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:0.30f];  
        
        self.view.frame = self.view.bounds;
        [UIView commitAnimations];
        isSelfViewTransformed = NO;
    }
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    if(self.editType == 0) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveButton, self.deleteButton, nil];
    }
    else {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    return YES;
}

- (IBAction)switchTypeToStaycation:(id)sender {
    UISegmentedControl *segmentedControl=(UISegmentedControl *)sender;
    segmentedControl.selectedSegmentIndex = 0;//设置本view上的segmentedControl默认选择项索引指向Vacation 
    [self performSegueWithIdentifier:@"ShowStaycationEditFromVacation" sender:sender];
}
@end
