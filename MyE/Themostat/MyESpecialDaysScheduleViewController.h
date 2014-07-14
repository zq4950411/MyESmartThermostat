//
//  MyESpecialDaysScheduleViewController.h
//  MyE
//
//  Created by Ye Yuan on 5/18/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MyEWeeklyModeEditingView.h"
#import "MyEWeeklyDaySelectionView.h"
#import "MyEDoughnutView.h"
#import "MyEModePickerView.h"
#import "MBProgressHUD.h"
#import "MyEPeriodInforDoughnutView.h"
#import "TableViewWithBlock.h"
#import "KxMenu.h"

@class MyEThermostatScheduleData;
@class MyEScheduleModeData;
@class MyEScheduleViewController;
@interface MyESpecialDaysScheduleViewController : UIViewController<MyEDoughnutViewDelegate, MyEModePickerViewDelegate, MyEWeeklyModeEditingViewDelegate,MyEApplyToDaysSelectionViewDelegate, MyEDataLoaderDelegate, MBProgressHUDDelegate,MyEPeriodInforDoughnutViewDelegate,UIAlertViewDelegate>
{
    MyEDoughnutView *_doughnutView;
    
    MyEModePickerView *_modePickerView;
    
    MyEWeeklyModeEditingView *_modeEditingView;
    BOOL _modeEditingViewShowing;
    
    MyEWeeklyDaySelectionView *_weeklyDaySelectionView;
    BOOL _applyToDaysSelectionViewShowing;
    
    // 当用户点击了一下Sector后，就toggle显示、隐藏Doughnut圆环形式的heating/cooling信息
    MyEPeriodInforDoughnutView *_periodInforDoughnutView;
    BOOL _periodInforDoughnutViewShowing;
    
    
    // 下面用于编辑、新添加或者删除模式时，向服务器异步上传此操作，等服务器返回ok时，
    //再回头把这个被操作的mode加入数据Model，下面这个变量就是用于记录正在操作待决的mode
    MyEScheduleModeData *_editingPendingMode;
    
    // 下面变量用于表示是不是当前Schedule被用户通过触摸改变了
    BOOL _scheduleChangedByUserTouch;
    
    MBProgressHUD *HUD;
    
    // 用于记录是不是第一次从服务器获取数据。如果是第一次获取数据，那么_currentDayId就重新计算为当天的星期几，并把view的初始显示设置这个星期几，否则就不计算，下载新数据后view的显示仍然是用户选择的星期几。在本类初始化时会用设备当前时间初始化这个值，但服务器时间和设备时间可能不同，所以需要用服务器时间来在第一次初始化这个值。
    BOOL _hasLoadFromServer;
}
@property (nonatomic) BOOL isRemoteControl;

@property (weak, nonatomic) IBOutlet UIView *centerContainerView;// 用于容纳Doughnut view的中间view，用于进行touch处理和动画处理而添加的
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet UIButton *addNewModeButton;
@property (weak, nonatomic) IBOutlet UIButton *editModeButton;
@property (weak, nonatomic) IBOutlet UIView *modeToolContainer;
@property (weak, nonatomic) IBOutlet UIButton *dayBtn;

@property (strong, nonatomic) MyEThermostatScheduleData *dataModel;
// 当前选择的模式的id。用于用户手触摸修改sector，或者编辑这个mode。这个值和MyEDoughnutView中的成员变量相同
@property (nonatomic) NSInteger currentSelectedModeId;
@property (nonatomic) NSUInteger currentDayId;

- (IBAction)editSelectedMode:(id)sender;
- (IBAction)addNewMode:(id)sender;
- (IBAction)applyNewSchedule:(id)sender;
- (IBAction)changeDay:(id)sender;
- (IBAction)saveAsNewDay:(id)sender;
- (IBAction)deleteCurrentDay:(id)sender;

@end
