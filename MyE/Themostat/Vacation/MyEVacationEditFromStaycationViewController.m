//
//  MyEVacationEditFromStaycationViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/15/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEVacationEditFromStaycationViewController.h"
#import "MyEVacationMasterViewController.h"
#import "MyEVacationItemData.h"
#import "MyEStaycationItemData.h"
#import "MyEUtil.h"

@interface MyEVacationEditFromStaycationViewController ()
- (void)backToVacationList;
- (void)configureView;
- (void)dateTimePickerValueChanged:(id)sender;
- (void)doneEditing;
- (void)saveVacationItem;
- (void)deleteStaycationItem;
@end

@implementation MyEVacationEditFromStaycationViewController
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
    self.returnDateTextField.inputView = self.datePicker; 
    self.leaveTimeTextField.inputView = self.datePicker; 
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
                                                                      action:@selector(deleteStaycationItem)];
    
    // Update the view.
    [self configureView];
    
    // 系统自带的BarButtonItem没有向左的箭头
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToVacationList)];
//    [self navigationItem].hidesBackButton = YES;
    
    // 这里用自定义的向左的箭头按钮
    
    UIImage *buttonImage = [UIImage imageNamed:@"backbutton.png" ];
    buttonImage = [buttonImage stretchableImageWithLeftCapWidth:13 topCapHeight:6];// 使用9宫格可缩放图片作为按钮背景
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [backButton setTitle:@" Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [backButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    CGRect rect = CGRectMake(0, 0, 51, 30);
    backButton.frame = rect;
    [backButton addTarget:self action:@selector(backToVacationList) 
            forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithCustomView:backButton];

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
- (void)setVacationItem:(MyEVacationItemData *)vacationItem
{
    if (_vacationItem != vacationItem) {
        _vacationItem = vacationItem;
        
        // Update the view.
        [self configureView];
    }
}

#pragma mark
#pragma mark private methods
- (void)dateTimePickerValueChanged:(id)sender {
    if (_currentEditingTextField == self.leaveDateTextField) {
        // 首先，计算在离开日期改变之前，离开和返回日期的差的天数 originalVacationDays
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
    [self updateDataModelByView];
    
    if([self.vacationItem.leaveDateTime compare:self.vacationItem.returnDateTime] == NSOrderedDescending) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Alert" 
                                                      message:@"TThe leave time must be earlier than the return time."
                                                     delegate:self 
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*注意，必须先返回到Master view，然后再调用delegate的didFinishEditStaycation:editType:方法，
     否则在Remote从YES变成NO的时候，由于返回Master View太慢，而导致已经进入到了didReceiveString方法来处理从服务器返回的-998/-999，
     此时会导致在NavigationControlle堆栈中的view之间进行转移，但由于还没返回Master view，所以导致view之间转移出错。*/
    
    //下面代码经过两个步骤无动画形式返回到master view。 这里不用此方法，而用下面的有动画的方法
    // 注意必须先取得[self navigationController]并保存到controller指针中，再在下一步中调用controller的方法
    // 否则由于第一步的popViewControllerAnimated方法，在第二步的[self navigationController]就失效了。
    //    UINavigationController *controller = [self navigationController];
    //    [[self navigationController] popViewControllerAnimated:NO];
    //    [controller popViewControllerAnimated:NO];
    
    //下面代码经过两个步骤有动画形式返回到master view。
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    int count = [allViewControllers count];
    [allViewControllers removeObjectAtIndex:count - 2];//移除前一个Staycation detail view controller
    self.navigationController.viewControllers = allViewControllers;  
    //以动画形式从vacation detail view略过staycation detail view返回master view 
    [[self navigationController] popViewControllerAnimated:YES];
    
    
    if ([self.delegate respondsToSelector:@selector(didFinishEditVacation:editType:)]) {
        [self.delegate didFinishEditVacation:self.vacationItem editType:self.editType];
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

// 此面板虽然是Vacation面板，但是从Staycation转换来的，所以删除时也要删除的是Staycation
-(void)deleteStaycationItem {
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
        //下面代码经过两个步骤有动画形式返回到master view。
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        int count = [allViewControllers count];
        
        // 获取前一个vc中的staycationItem
        MyEStaycationDetailViewController *sdvc = [allViewControllers objectAtIndex:count - 2];
        MyEStaycationItemData *staycationItem = sdvc.staycationItem;
        
        
        [allViewControllers removeObjectAtIndex:count - 2];//移除前一个Staycation detail view controller
        self.navigationController.viewControllers = allViewControllers;  
        //以动画形式从vacation detail view略过staycation detail view返回master view 
        [[self navigationController] popViewControllerAnimated:YES];
        
        if ([self.delegate respondsToSelector:@selector(didFinishEditStaycation:editType:)]) {
            [self.delegate didFinishEditStaycation:staycationItem editType:2];//editType：0-修改， 1-新增， 2-删除
        }
    }
}

#pragma mark -
//用户可能编辑了界面控件的东西，调用此函数把修改的东西更新到数据模型里
- (void) updateDataModelByView {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];

    self.vacationItem.name = [NSString stringWithString:self.nameTextField.text];
    self.vacationItem.leaveDateTime = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.leaveDateTextField.text, self.leaveTimeTextField.text]];
    self.vacationItem.returnDateTime = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.returnDateTextField.text, self.returnTimeTextField.text]];
    self.vacationItem.cooling = [self.coolingTextField.text intValue];
    self.vacationItem.heating = [self.heatingTextField.text intValue];   
}

- (void) backToVacationList {
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    int count = [allViewControllers count];
    [allViewControllers removeObjectAtIndex:count - 2];//移除前一个Staycation detail view controller
    self.navigationController.viewControllers = allViewControllers;  
    
    //以动画形式从vacation detail view略过staycation detail view返回master view 
    [[self navigationController] popViewControllerAnimated:YES];
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
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.date = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
        
        //下面设置start date picker的允许的最早和最晚时间。最早时间比当前时刻晚一天，最晚时刻比最最新的return date早一天
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // now build a NSDate object for the next day 
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
        
        // 下面修改成对开始离开日期不做返回日期的限制，只修改成最晚不超过5年后，如果开始日期变化了，就把结束日期修改成和新的离开日期相同间距的日期
        [offsetComponents setDay:0];
        [offsetComponents setYear:5];
        NSDate *maximumDate = [calendar dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        self.datePicker.maximumDate = maximumDate;
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
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.date = [self.dateFormatter dateFromString:self.returnDateTextField.text];
        
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
    
    UINavigationController *controller = [self navigationController];
    [[self navigationController] popViewControllerAnimated:NO];
    
    int count = [[controller viewControllers] count];
    MyEStaycationDetailViewController *staycationController = [[controller viewControllers] objectAtIndex:count-1];// 取得最上面的controller，就是staycation的那个
    MyEStaycationItemData *staycationItem = [[MyEStaycationItemData alloc] init];
    
    // 把本面板的name、日期传递到vacation面板
    staycationItem.name = self.nameTextField.text;
    
    //从当我文本域获得日期，而不从内部数据model获得，因为文本域上的日期文字是最新的，并且可能没有更新到内部数据model
    staycationItem.startDate = [self.dateFormatter dateFromString:self.leaveDateTextField.text];
    staycationItem.endDate = [self.dateFormatter dateFromString:self.returnDateTextField.text];

    // 现在不需要把vacation的time，setpoints传递到staycation了，所以注释了下面的代码
//    staycationItem.riseTime = [self.timeFormatter dateFromString:self.leaveTimeTextField.text];
//    staycationItem.sleepTime = [self.timeFormatter dateFromString:self.returnTimeTextField.text];
//    staycationItem.dayCooling = [self.coolingTextField.text intValue];
//    staycationItem.dayHeating = [self.heatingTextField.text intValue];
//    staycationItem.nightCooling = [self.coolingTextField.text intValue];
//    staycationItem.nightHeating = [self.heatingTextField.text intValue];
    
    staycationItem.old_end_date = self.vacationItem.old_end_date;
    staycationController.staycationItem = staycationItem;//同步vacation面板的数据到staycation面板
}
@end
