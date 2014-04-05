//
//  MyEVacationEditFromStaycationViewController.h
//  MyE
//
//  Created by Ye Yuan on 3/15/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEVacationDetailViewController.h"


@class MyEVacationItemData;

@interface MyEVacationEditFromStaycationViewController : UITableViewController <UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate, UIAlertViewDelegate>{
    BOOL isSelfViewTransformed;
    //记录当前正在编辑、弹出了setpointPicker的textField，用于这个setpointPicker变化时，设置对应的textField的文字。
    UITextField *_currentEditingTextField;
   
    //编辑类型，因为我们用同一套view来表示修改和新增vacation条目的功能。此变量表示本view是用来进行修改现有条目的，还是增加新条目的。
    int _editType; //0表示修改现有条目，1表示添加条目, 2表示删除
}
@property(nonatomic) int editType;
@property (nonatomic, weak) id <MyEVacationDetailViewControllerDelegate> delegate;
@property (strong, nonatomic) MyEVacationItemData *vacationItem;
@property (retain, nonatomic) UIBarButtonItem *doneButton;
@property (retain, nonatomic) UIBarButtonItem *saveButton;
@property (retain, nonatomic) UIBarButtonItem *deleteButton;
@property (retain, nonatomic) UIDatePicker *datePicker;
@property (retain, nonatomic) UIPickerView *setpointPicker;
@property (retain, nonatomic) NSDateFormatter *dateFormatter;
@property (retain, nonatomic) NSDateFormatter *timeFormatter;
@property (retain, nonatomic) NSDateFormatter *dateTimeFormatter;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *leaveDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *leaveTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *returnDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *returnTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *heatingTextField;
@property (weak, nonatomic) IBOutlet UITextField *coolingTextField;

- (void) updateDataModelByView;//用户可能编辑了界面控件的东西，调用此函数把修改的东西更新到数据模型里
- (IBAction)switchTypeToStaycation:(id)sender;

@end
