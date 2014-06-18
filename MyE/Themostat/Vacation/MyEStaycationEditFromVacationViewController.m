//
//  MyEStaycationEditFromVacationViewControllerViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/26/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEStaycationEditFromVacationViewController.h"
#import "MyEVacationDetailViewController.h"
#import "MyEStaycationItemData.h"
#import "MyEVacationItemData.h"
#import "MyEUtil.h"

@interface MyEStaycationEditFromVacationViewController ()
- (void)backToVacationList;
- (void)configureView;
- (void)dateTimePickerValueChanged:(id)sender;
- (void)doneEditing;
- (void)saveStaycationItem;
- (void)deleteVacationItem;
@end

@implementation MyEStaycationEditFromVacationViewController
@synthesize staycationItem = _staycationItem;
@synthesize doneButton = _doneButton, saveButton = _saveButton, deleteButton = _deleteButton;
@synthesize datePicker = _datePicker, setpointPicker = _setpointPicker;
@synthesize dateFormatter = _dateFormatter, timeFormatter = _timeFormatter, dateTimeFormatter = _dateTimeFormatter;

@synthesize nameTextField = _nameTextField;
@synthesize startDateTextField = _startDateTextField, endDateTextField = _endDateTextField;
@synthesize riseTimeTextField = _riseTimeTextField, dayCoolingTextField = _dayCoolingTextField, dayHeatingTextField = _dayHeatingTextField;
@synthesize sleepTimeTextField = _sleepTimeTextField, nightCoolingTextField = _nightCoolingTextField, nightHeatingTextField = _nightHeatingTextField;
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
    
    self.startDateTextField.inputView = self.datePicker; 
    self.endDateTextField.inputView = self.datePicker; 
    self.riseTimeTextField.inputView = self.datePicker; 
    self.sleepTimeTextField.inputView = self.datePicker; 
    
    
    self.setpointPicker = [[UIPickerView alloc] init];
    [self.setpointPicker setDelegate:self];
    [self.setpointPicker setDataSource:self];
    self.setpointPicker.showsSelectionIndicator = YES;
    self.nightCoolingTextField.inputView = self.setpointPicker;
    self.nightHeatingTextField.inputView = self.setpointPicker;
    self.dayCoolingTextField.inputView = self.setpointPicker;
    self.dayHeatingTextField.inputView = self.setpointPicker;
    
    
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
    self.startDateTextField.delegate = self;
    self.endDateTextField.delegate = self;
    self.riseTimeTextField.delegate = self;
    self.sleepTimeTextField.delegate = self;
    self.dayCoolingTextField.delegate = self;
    self.dayHeatingTextField.delegate = self;
    self.nightCoolingTextField.delegate = self;
    self.nightHeatingTextField.delegate = self;
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self       
                                                                    action:@selector(doneEditing)];
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self       
                                                                    action:@selector(saveStaycationItem)];
    self.deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                      target:self       
                                                                      action:@selector(deleteVacationItem)];
    // Update the view.
    [self configureView];
    
    // 系统自带的BarButtonItem没有向左的箭头
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToVacationList)];
    //    [self navigationItem].hidesBackButton = YES;
    
    // 这里用自定义的向左的箭头按钮
    // 下面使用9宫格可缩放图片作为按钮背景
//    UIImage *buttonImage = [UIImage imageNamed:@"backbutton.png"];
//    buttonImage = [buttonImage stretchableImageWithLeftCapWidth:13 topCapHeight:6];
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
//    [backButton setTitle:@" Back" forState:UIControlStateNormal];
//    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//    [backButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    backButton.frame = CGRectMake(0, 0, 50, 30);
//    [backButton addTarget:self action:@selector(backToVacationList) 
//         forControlEvents:UIControlEventTouchUpInside];
//    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
//                                             initWithCustomView:backButton];
}

- (void)viewDidUnload
{
    self.staycationItem = nil;
    [self setDoneButton:nil];
    [self setSaveButton:nil];
    [self setDelegate:nil];
    [self setNameTextField:nil];
    [self setStartDateTextField:nil];
    [self setEndDateTextField:nil];
    [self setRiseTimeTextField:nil];
    [self setSleepTimeTextField:nil];
    [self setDayCoolingTextField:nil];
    [self setDayHeatingTextField:nil];
    [self setNightCoolingTextField:nil];
    [self setNightHeatingTextField:nil];
    
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
- (void)setStaycationItem:(MyEStaycationItemData *)staycationItem
{
    if (_staycationItem != staycationItem) {
        _staycationItem = staycationItem;
        
        // Update the view.
        [self configureView];
    }
}

#pragma mark
#pragma mark private methods
- (void)dateTimePickerValueChanged:(id)sender {
    if (_currentEditingTextField == self.startDateTextField) {
        // 首先，计算在开始日期改变之前，开始和结束日期的差的天数 originalVacationDays
        NSDate *oldStartDate = [self.dateFormatter dateFromString:self.startDateTextField.text];
        NSDate *oldEndDate = [self.dateFormatter dateFromString:self.endDateTextField.text];
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
                
                self.endDateTextField.text = [self.dateFormatter stringFromDate:newReturnDate];
            }
        }
        
        // 最后，用DatePicker的新的日期来更新 leaveDateTextField 域的文字
        self.startDateTextField.text = [self.dateFormatter stringFromDate:((UIDatePicker *)self.startDateTextField.inputView).date];
    }
    if (_currentEditingTextField == self.endDateTextField) {
        self.endDateTextField.text = [self.dateFormatter stringFromDate:((UIDatePicker *)self.endDateTextField.inputView).date ];
    }
    if (_currentEditingTextField == self.riseTimeTextField) {
        // mark mmmmmm
        // 注意，我们只比较时间time，所以date要选择同一个日期
        NSDate *oldStartDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.startDateTextField.text, self.riseTimeTextField.text]];
        NSDate *oldEndDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.startDateTextField.text, self.sleepTimeTextField.text]];
        
        NSDate *newStartDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",self.startDateTextField.text, [self.timeFormatter stringFromDate:self.datePicker.date]]];
        
        if ([oldStartDate compare:newStartDate] == NSOrderedDescending || [oldStartDate compare:newStartDate] == NSOrderedSame) 
            NSLog(@"	当把rise time前、或不动的时候，sleep time不做任何自动调整；");
        
        
        if ([oldStartDate compare:newStartDate] == NSOrderedAscending) {
            NSLog(@"	当把rise time推迟的时候：");
            if ([newStartDate compare:oldEndDate] == NSOrderedAscending) {
                NSLog(@"	如果调整后rise time < sleep time，则sleep time不做任何自动调整；");
            }  
            else{
                NSLog(@"	如果调整后rise time >= sleep time，则sleep time自动也往后调整，保持总是比rise time晚半小时。");
                // 把返回日期更新为原来返回日期加上 leaveDateOffsetInDay
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setMinute:30];
                NSDate *newReturnDateTime = [calendar dateByAddingComponents:offsetComponents toDate:newStartDate options:0];
                
                self.sleepTimeTextField.text = [self.timeFormatter stringFromDate:newReturnDateTime];
            }
        }

        
        
        
        self.riseTimeTextField.text = [self.timeFormatter stringFromDate:((UIDatePicker *)self.riseTimeTextField.inputView).date ];
    } 
    if (_currentEditingTextField == self.sleepTimeTextField) {
        self.sleepTimeTextField.text = [self.timeFormatter stringFromDate:((UIDatePicker *)self.sleepTimeTextField.inputView).date ];
    } 
    
}
- (void)configureView
{
    // Update the user interface for the detail item.
    MyEStaycationItemData *staycationItem = self.staycationItem;
    
    
    
    if (staycationItem) {
        self.nameTextField.text = staycationItem.name;
        self.startDateTextField.text = [self.dateFormatter stringFromDate:staycationItem.startDate];
        self.endDateTextField.text = [self.dateFormatter stringFromDate:staycationItem.endDate];
        self.riseTimeTextField.text = [self.timeFormatter stringFromDate:staycationItem.riseTime]; 
        self.dayCoolingTextField.text = [NSString stringWithFormat:@"%i", staycationItem.dayCooling];
        self.dayHeatingTextField.text = [NSString stringWithFormat:@"%i", staycationItem.dayHeating];
        self.sleepTimeTextField.text = [self.timeFormatter stringFromDate:staycationItem.sleepTime];
        self.nightCoolingTextField.text = [NSString stringWithFormat:@"%i", staycationItem.nightCooling];
        self.nightHeatingTextField.text = [NSString stringWithFormat:@"%i", staycationItem.nightHeating];
    }
}

- (void)saveStaycationItem {    
    NSLog(@"Save a staycation starting from vacation");
    
    /*注意，必须先返回到Master view，然后再调用delegate的didFinishEditStaycation:editType:方法，
     否则在Remote从YES变成NO的时候，由于返回Master View太慢，而导致已经进入到了didReceiveString方法来处理从服务器返回的-998/-999，
     此时会导致在NavigationControlle堆栈中的view之间进行转移，但由于还没返回Master view，所以导致view之间转移出错。*/
    
    //下面代码经过两个步骤无动画形式返回到master view。这里不用此方法，而用下面的由动画的方法
    // 注意必须先取得[self navigationController]并保存到controller指针中，再在下一步中调用controller的方法
    // 否则由于第一步的popViewControllerAnimated方法，在第二步的[self navigationController]就失效了。
    //    UINavigationController *controller = [self navigationController];
    //    [[self navigationController] popViewControllerAnimated:NO];
    //    [controller popViewControllerAnimated:NO];
    
    //下面代码经过两个步骤有动画形式返回到master view。
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    int count = [allViewControllers count];
    [allViewControllers removeObjectAtIndex:count - 2];//移除前一个Vacation detail view controller
    self.navigationController.viewControllers = allViewControllers;  
    //以动画形式从staycation detail view略过vacation detail view返回master view 
    [[self navigationController] popViewControllerAnimated:YES];
    
    [self updateDataModelByView];
    if ([self.delegate respondsToSelector:@selector(didFinishEditStaycation:editType:)]) {
        [self.delegate didFinishEditStaycation:self.staycationItem editType:self.editType];
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

// 此面板虽然是Staycation面板，但是从Vacation转换来的，所以删除时也要删除的是vacation
-(void)deleteVacationItem {
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
        
        // 获取前一个vc中的vacationItem
        MyEVacationDetailViewController *vdvc = [allViewControllers objectAtIndex:count - 2];
        MyEVacationItemData *vacationItem = vdvc.vacationItem;
        
        [allViewControllers removeObjectAtIndex:count - 2];//移除前一个Vacation detail view controller
        self.navigationController.viewControllers = allViewControllers;  
        //以动画形式从staycation detail view略过vacation detail view返回master view 
        [[self navigationController] popViewControllerAnimated:YES];
        
        if ([self.delegate respondsToSelector:@selector(didFinishEditVacation:editType:)]) {
            [self.delegate didFinishEditVacation:vacationItem editType:2];//editType：0-修改， 1-新增， 2-删除
        }

    }
}


//用户可能编辑了界面控件的东西，调用此函数把修改的东西更新到数据模型里
- (void) updateDataModelByView {
    self.staycationItem.name = [NSString stringWithString:self.nameTextField.text];
    self.staycationItem.startDate = [self.dateFormatter dateFromString:self.startDateTextField.text];
    self.staycationItem.endDate = [self.dateFormatter dateFromString:self.endDateTextField.text];
    self.staycationItem.riseTime = [self.timeFormatter dateFromString:self.riseTimeTextField.text];
    self.staycationItem.sleepTime = [self.timeFormatter dateFromString:self.sleepTimeTextField.text];
    self.staycationItem.dayCooling = [self.dayCoolingTextField.text intValue];
    self.staycationItem.dayHeating = [self.dayHeatingTextField.text intValue];
    self.staycationItem.nightCooling = [self.nightCoolingTextField.text intValue];
    self.staycationItem.nightHeating = [self.nightHeatingTextField.text intValue];
}
- (void) backToVacationList {
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    int count = [allViewControllers count];
    [allViewControllers removeObjectAtIndex:count - 2];//移除前一个Vacation detail view controller
    self.navigationController.viewControllers = allViewControllers;  
    
    //以动画形式从staycation detail view略过vacation detail view返回master view 
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
    //要区分day/night分别的cooling、heating直接的约束关系
	if (_currentEditingTextField == self.dayCoolingTextField) {
        return 90 - ([self.dayHeatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP) + 1;
    } else if (_currentEditingTextField == self.nightCoolingTextField) {
        return 90 - ([self.nightHeatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP) + 1;
    } else if (_currentEditingTextField == self.dayHeatingTextField) {
        return ([self.dayCoolingTextField.text intValue]- MINIMUM_HEATING_COOLING_GAP -55) + 1;
    }else if (_currentEditingTextField == self.nightHeatingTextField) {
        return ([self.nightCoolingTextField.text intValue]- MINIMUM_HEATING_COOLING_GAP -55) + 1;
    } else
        return 36;
}

#pragma mark -
#pragma mark Picker Delegate Methods 委托方法

//官方的意思是，指定组件中的指定数据，就是每一行所对应的显示字符是什么。
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //要区分day/night分别的cooling、heating直接的约束关系
	if (_currentEditingTextField == self.dayCoolingTextField) {
        return [NSString stringWithFormat:@"     %i", row + [self.dayHeatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP];
    } else if (_currentEditingTextField == self.nightCoolingTextField) {
        return [NSString stringWithFormat:@"     %i", row + [self.nightHeatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP];
    } else if (_currentEditingTextField == self.dayHeatingTextField || _currentEditingTextField == self.nightHeatingTextField) {
        return [NSString stringWithFormat:@"     %i", row + 55];
    } else
        return [NSString stringWithFormat:@"     %i", row + 55];
}

//当选取器的行发生改变的时候调用这个方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //要区分day/night分别的cooling、heating直接的约束关系
    if (_currentEditingTextField == self.dayCoolingTextField) {
        _currentEditingTextField.text = [NSString stringWithFormat:@"%i", row + [self.dayHeatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP];
    } else if (_currentEditingTextField == self.nightCoolingTextField) {
        _currentEditingTextField.text = [NSString stringWithFormat:@"%i", row + [self.nightHeatingTextField.text intValue] + MINIMUM_HEATING_COOLING_GAP];
    } else if (_currentEditingTextField == self.dayHeatingTextField  || _currentEditingTextField == self.nightHeatingTextField) {
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
    
    if (textField == self.startDateTextField) {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        ((UIDatePicker *)(textField.inputView)).date = [self.dateFormatter dateFromString:self.startDateTextField.text];
        
        //下面设置start date picker的允许的最早和最晚时间。最早时间比当前时刻晚一天，最晚时刻比最最新的return date早一天
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // now build a NSDate object for the next day 
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        
        //原来设置默认离开时间最早允许是当前时间的第二天
        [offsetComponents setDay:1];
        NSDate *minimumDate = [calendar dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        self.datePicker.minimumDate = minimumDate;

        
        /*
         // 用结束日期来约束离开日期，现在不用了。
         NSDate *endDate = [self.dateFormatter dateFromString:self.endDateTextField.text];
         [offsetComponents setDay:-1];
         NSDate *maximumDate = [calendar dateByAddingComponents:offsetComponents toDate:endDate options:0];
         self.datePicker.maximumDate = maximumDate;
         */
        
        // 下面修改成对开始日期不做结束日期的限制，只修改成最晚不超过5年后，如果开始日期变化了，就把结束日期修改成和新的离开日期相同间距的日期
        [offsetComponents setDay:0];
        [offsetComponents setYear:5];
        NSDate *maximumDate = [calendar dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        self.datePicker.maximumDate = maximumDate;

    }
    if (textField == self.endDateTextField) {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        ((UIDatePicker *)(textField.inputView)).date = [self.dateFormatter dateFromString:self.endDateTextField.text];
        
        //下面设置return date picker的允许的最早和最晚时间。最早时间比最新的leave date当前时刻晚一天，最晚时刻是5年后的今天
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // now build a NSDate object for the current day
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:0];
        NSDate *startDate = [self.dateFormatter dateFromString:self.startDateTextField.text];
        NSDate *minimumDate = [calendar dateByAddingComponents:offsetComponents toDate:startDate options:0];
        self.datePicker.minimumDate = minimumDate;
        
        [offsetComponents setDay:0];
        [offsetComponents setYear:5];
        NSDate *maximumDate = [calendar dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        self.datePicker.maximumDate = maximumDate;
    }
    if (textField == self.riseTimeTextField) {
        // mark mmmmmm
        self.datePicker.minimumDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:30", self.startDateTextField.text]];
        
        self.datePicker.maximumDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:00", self.startDateTextField.text]];

        
        
        self.datePicker.date = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.startDateTextField.text, self.riseTimeTextField.text]];
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    }
    if (textField == self.sleepTimeTextField) {
        // mark mmmmmm
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        
        [offsetComponents setMinute:30];
        NSDate *currentStartDateTime = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.startDateTextField.text, self.riseTimeTextField.text]];
        NSDate *minimumDate = [calendar dateByAddingComponents:offsetComponents toDate:currentStartDateTime options:0];
        self.datePicker.minimumDate = minimumDate;
        
        self.datePicker.maximumDate = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:30", self.startDateTextField.text]];
        
        
        
        
        self.datePicker.date = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", self.endDateTextField.text, self.sleepTimeTextField.text]];
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    }
    
    //要区分day/night分别的cooling、heating直接的约束关系
    if (textField == self.dayCoolingTextField) {
        [self.setpointPicker selectRow:[textField.text intValue]-[self.dayHeatingTextField.text intValue]-MINIMUM_HEATING_COOLING_GAP inComponent:0 animated:YES];
        [self.setpointPicker setNeedsLayout];
    }
    if (textField == self.nightCoolingTextField) {
        [self.setpointPicker selectRow:[textField.text intValue]-[self.nightHeatingTextField.text intValue]-MINIMUM_HEATING_COOLING_GAP inComponent:0 animated:YES];
        [self.setpointPicker setNeedsLayout];
    }
    if (textField == self.dayHeatingTextField || textField == self.nightHeatingTextField) {
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

#pragma mark
- (IBAction)switchTypeToVacation:(id)sender {
    UISegmentedControl *segmentedControl=(UISegmentedControl *)sender;
    segmentedControl.selectedSegmentIndex = 1;//设置本view上的segmentedControl默认选择项索引指向Staycation 
    
    UINavigationController *controller = [self navigationController];
    [[self navigationController] popViewControllerAnimated:NO];
    
    int count = [[controller viewControllers] count];
    MyEVacationDetailViewController *vacationViewController = [[controller viewControllers] objectAtIndex:count-1];// 取得最上面的controller，就是staycation的那个
    
    //构建一个新的vacation数据，并传递到接下来要出现vacation编辑面板以供显示
    MyEVacationItemData * vacationItem = [[MyEVacationItemData alloc] init];
    
    // 把本面板的name、日期传递到vacation面板
    vacationItem.name = self.nameTextField.text;
    
    vacationItem.leaveDateTime = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 08:00",self.startDateTextField.text]];
    vacationItem.returnDateTime = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 22:00",self.endDateTextField.text]];

    // 现在不需要把Staycation的time,setpoints传递到vacation了，所以注释了下面的代码
//    vacationItem.leaveDateTime = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",self.startDateTextField.text, self.riseTimeTextField.text]];
//    vacationItem.returnDateTime = [self.dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",self.endDateTextField.text, self.sleepTimeTextField.text]];
//    vacationItem.heating = [self.dayHeatingTextField.text intValue];
//    vacationItem.cooling = [self.dayCoolingTextField.text intValue];
    
    vacationItem.old_end_date = self.staycationItem.old_end_date;
    vacationViewController.vacationItem = vacationItem;

}


@end
