//
//  MyEUtil.h
//  MyE
//
//  Created by Ye Yuan on 2/23/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define URL_FOR_LOGIN @"http://www.myenergydomain.com/user/user_login4mobile.do"
//#define URL_FOR_HOUSELIST_VIEW @"http://www.myenergydomain.com/house_view.do"
//#define URL_FOR_DASHBOARD_VIEW @"http://www.myenergydomain.com/dashboard_view.do"
//#define URL_FOR_TODAY_SCHEDULE_VIEW @"http://www.myenergydomain.com/programToday_view.do"
//#define URL_FOR_TODAY_DEFAULT_SCHEDULE_VIEW @"http://www.myenergydomain.com/programToday_reset.do"
//#define URL_FOR_WEEKLY_SCHEDULE_VIEW @"http://www.myenergydomain.com/masterProgram_view.do"
//#define URL_FOR_NEXT24HRS_SCHEDULE_VIEW @"http://www.myenergydomain.com/next24Program_view.do"
//#define URL_FOR_NEXT24HRS_DEFAULT_SCHEDULE_VIEW @"http://www.myenergydomain.com/next24Program_reset.do"
//#define URL_FOR_VACATION_VIEW @"http://www.myenergydomain.com/vacation_view.do"
//#define URL_FOR_SETTINGS_VIEW @"http://www.myenergydomain.com/setting_view.do"
//
//#define URL_FOR_DASHBOARD_SAVE @"http://www.myenergydomain.com/dashboard_save.do"
//#define URL_FOR_TODAY_SCHEDULE_SAVE @"http://www.myenergydomain.com/programToday_save.do"
//#define URL_FOR_TODAY_HOLD_SAVE @"http://www.myenergydomain.com/programToday_hold_save.do"
//#define URL_FOR_WEEKLY_SCHEDULE_SAVE @"http://www.myenergydomain.com/masterProgram_save.do"
//#define URL_FOR_NEXT24HRS_SCHEDULE_SAVE @"http://www.myenergydomain.com/next24Program_save.do"
//#define URL_FOR_NEXT24HRS_HOLD_SAVE @"http://www.myenergydomain.com/next24Program_hold_save.do"
//#define URL_FOR_VACATION_SAVE @"http://www.myenergydomain.com/vacation_save.do"
//#define URL_FOR_SETTINGS_SAVE @"http://www.myenergydomain.com/setting_save.do"

#define GetServer [ServerUtils getServierIp]
//#define GetRequst(API) [@"http://www.myenergydomain.com:80" stringByAppendingFormat:@"%@",API]

#define GetRequst(API) [@"http://192.168.0.80:4000" stringByAppendingFormat:@"%@",API]

//#define GetRequst(API) [@"http://117.42.212.152:65533" stringByAppendingFormat:@"%@",API]

#define URL_FOR_LOGIN @"/user/userJson_login_phone.do"
#define URL_FOR_ADD_ADDRESS @"/house_add4mobile.do"
#define URL_FOR_HOUSELIST_VIEW @"/house_findHouseList.do"
#define URL_FOR_DASHBOARD_VIEW @"/dashboard_view.do"
#define URL_FOR_TODAY_SCHEDULE_VIEW @"/programToday_view.do"
#define URL_FOR_TODAY_DEFAULT_SCHEDULE_VIEW @"/programToday_reset.do"
#define URL_FOR_WEEKLY_SCHEDULE_VIEW @"/masterProgram_view.do"
#define URL_FOR_NEXT24HRS_SCHEDULE_VIEW @"/next24Program_view.do"
#define URL_FOR_NEXT24HRS_DEFAULT_SCHEDULE_VIEW @"/next24Program_reset.do"
#define URL_FOR_VACATION_VIEW @"/vacation_view.do"
#define URL_FOR_SETTINGS_VIEW @"/setting_view.do"
#define URL_FOR_USAGE_STATS_VIEW @"/usage_electric_stati.do"

#define URL_FOR_DASHBOARD_SAVE @"/dashboard_save.do"
#define URL_FOR_TODAY_SCHEDULE_SAVE @"/programToday_save.do"
#define URL_FOR_TODAY_HOLD_SAVE @"/programToday_hold_save.do"
#define URL_FOR_WEEKLY_SCHEDULE_SAVE @"/masterProgram_save.do"
#define URL_FOR_NEXT24HRS_SCHEDULE_SAVE @"/next24Program_save.do"
#define URL_FOR_NEXT24HRS_HOLD_SAVE @"/next24Program_hold_save.do"
#define URL_FOR_VACATION_SAVE @"/vacation_save.do"
#define URL_FOR_SETTINGS_SAVE @"/setting_save.do"
#define URL_FOR_SETTINGS_DELETE_THERMOSTAT  @"/setting_delete.do"
#define URL_FOR_SETTINGS_DELETE_THERMOSTAT_QUERY_STATUS  @"/setting_findThermostat.do"

#define URL_FOR_SMARTUP_LIST @"/smartUp_findDeviceList.do"
#define URL_FOR_SAVE_SORT @"/smartUp_saveSort.do"
#define URL_FOR_SMARTUP_PlUG_CONTROL @"/socket_plugContro.do"
#define URL_FOR_FIND_DEVICE @"/smartUp_findDevice.do"
#define URL_FOR_SAVE_DEVICE @"/smartUp_saveDevice.do"
#define URL_FOR_FIND_INSTRUCTION @"/smartUp_findInstruction.do"
#define URL_FOR_INSTRUCTION_CONTROL @"/smartUp_instructionControl.do"
#define URL_FOR_INSTRUCTION_VERIFY @"/smartUp_instructionVerify.do"
#define URL_FOR_INSTRUCTION_FIND_RECORD @"/smartUp_findRecord.do"
#define URL_FOR_INSTRUCTION_TIME_OUT @"/smartUp_recordTimeOut.do"

#define URL_FOR_ROOMLIST_VIEW @"/smartUp_findRoom.do"

#define URL_FOR_SOCKET_FIND @"/socket_findPlug.do"
#define URL_FOR_SOCKET_INFO @"/socket_findPlugDevice.do"
#define URL_FOR_FIND_SOCKET_AUTO @"/socket_findSocketAuto.do"
#define URL_FOR_SAVE_SOCKET_AUTO @"/socket_saveAutoMode.do"
#define URL_FOR_SOCKET_GET_SCHEDULELIST @"/socket_findSocketScheduleList.do"

#define URL_FOR_SOCKET_TIMER_CONTROL @"/socket_timerContro.do"
#define URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE @"/socket_savePlugSchedule.do"
#define URL_FOR_SOCKET_SAVEPLUG @"/socket_savePlug.do"
#define URL_FOR_SOCKET_Reset @"/socket_resetPlug.do"
#define URL_FOR_SOCKET_MUTEX_DELAY @"/socket_mutex_delay_timing.do"
#define URL_FOR_SOCKET_DELAY_SAVE @"/socket_timing_save.do"
#define URL_FOR_SOCKET_ELEC_INFO @"/socket_electric_stati.do"

#define URL_FOR_IRDEVICE_CONTROL @"/smartUp_irControl.do"
#define URL_FOR_UNIVERSAL_CONTROL_MANUEL_CONTROL @"/universalcontroller_ucControl.do"
#define URL_FOR_UNIVERSAL_CONTROL_MANUAL_VIEW @"/universalcontroller_manual_view.do"
#define URL_FOR_UNIVERSAL_CONTROLLER_MANUAL_SAVE @"/universalcontroller_manual_save.do"
#define URL_FOR_UNIVERSAL_CONTROLLER_AUTO_VIEW @"/universalcontroller_auto_view.do"
#define URL_FOR_UNIVERSAL_CONTROLLER_AUTO_SCHEDULE @"/universalcontroller_auto_schedule.do"
#define URL_FOR_UNIVERSAL_CONTROLLER_SAVE_PLUG_SCHEDULE @"/universalcontroller_save_schedule.do"

#define URL_FOR_UNIVERSAL_CONTROLLER_SEQUENTIAL_VIEW @"/universalcontroller_sequential_view.do"
#define URL_FOR_UNIVERSAL_CONTROLLER_SEQUENTIAL_Save @"/universalcontroller_sequential_save.do"

#define URL_FOR_UNIVERSAL_CONTROLLER_AUTO_SAVE @"/universalcontroller_auto_save.do"
#define URL_FOR_UNIVERSAL_CONTROLLER_VIEW @"/universalcontroller_view.do"
#define URL_FOR_UNIVERSAL_CONTROLLER_SAVE @"/universalcontroller_save.do"

#define URL_FOR_SCENES_CONDITION_TIME @"/scenes_saveSceneTimeParameter.do"
#define URL_FOR_SCENES_DETAIL @"/scenes_findSceneDeviceParameterList.do"
#define URL_FOR_SCENES_LIST @"/scenes_findSceneList.do"
#define URL_FOR_SCENES_VIEW @"/scenes_view.do"
#define URL_FOR_SCENES_FIND_SCENE_DEVICE @"/scenes_findSDevice.do"
#define URL_FOR_SCENES_SAVE_SCENE @"/scenes_saveScene.do"
#define URL_FOR_SCENES_FIND_DEVICE @"/scenes_findDevice.do"
#define URL_FOR_SCENES_SAVE_SCENE_DEVICE @"/scenes_saveSceneDevice.do"
#define URL_FOR_SCENES_DELETE_SCENE_DEVICE @"/scenes_deleteSceneDevice.do"

#define SETTING_FIND_GATEWAY @"/setting_findGateways.do"
#define SETTING_REGISTER_GATEWAY @"/setting_register.do"
#define SETTING_DELETE_GATEWAY @"/setting_deleteGateways.do"

#define SETTING_SAVETIMEZONE @"/setting_saveTimeZone.do"
#define SETTING_EDITT @"/setting_editT.do"
#define SETTING_DELETE_T @"/setting_deleteT.do"
#define SETTING_FIND_THERMOSTAT @"/setting_findThermostat.do"

#define MORE_NOTIFICATION @"/account_findNotification.do"
#define MORE_SAVE_NOTIFICATION @"/account_saveNotification.do"

#define MORE_REPWD @"/account_save.do"

#define URL_FOR_LOCATION_EDIT @"/smartUp_saveLaction.do"
#define URL_FOR_INSTRUCTIONLIST_VIEW @"/smartUp_findInstructionList.do"
#define URL_FOR_INSTRUCTION_STUDY @"/smartUp_instructionStudy.do"

/*--------------------------smart switch-----------------------------------*/

#define URL_FOR_SWITCH_CONTROL   @"/switch_switch_control.do"
#define URL_FOR_SWITCH_VIEW      @"/switch_switch_view.do"
#define URL_FOR_SWITCH_SAVE      @"/switch_switch_save.do"
#define URL_FOR_SWITCH_FIND_SWITCH_CHANNERL          @"/switch_find_switch_channel_list.do"
#define URL_FOR_SWITCH_TIME_DELAY  @"/switch_mutex_delay_timing.do"
#define URL_FOR_SWITCH_TIME_DELAY_SAVE    @"/switch_timing_save.do"
#define URL_FOR_SWITCH_SCHEDULE_LIST   @"/switch_find_switch_schedule_list.do"
#define URL_FOR_SWITCH_SCHEDULE_SAVE   @"/switch_schedule_save.do"
#define URL_FOR_SWITCH_SCHEDULE_ENABLE  @"/switch_auto_control_enable_save.do"
#define URL_FOR_SWITCH_ELECT_STATUS   @"/switch_electric_stati.do"


// 定义tip显示的标志位的key，该可以会用于NSDefaults里面存储此标志位
#define KEY_FOR_HIDE_TIP_OF_DASHBOARD1 @"hide_tip_of_dashboard1"
#define KEY_FOR_HIDE_TIP_OF_DASHBOARD2 @"hide_tip_of_dashboard2"
#define KEY_FOR_HIDE_TIP_OF_SCHEDULE_TODAY1 @"hide_tip_of_schedule1"
#define KEY_FOR_HIDE_TIP_OF_SCHEDULE_TODAY2 @"hide_tip_of_schedule2"
#define KEY_FOR_HIDE_TIP_OF_SCHEDULE_NEXT24HRS1 @"hide_tip_of_schedule1"
#define KEY_FOR_HIDE_TIP_OF_SCHEDULE_NEXT24HRS2 @"hide_tip_of_schedule2"
#define KEY_FOR_HIDE_TIP_OF_SCHEDULE_WEEKLY @"hide_tip_of_schedule1"
#define KEY_FOR_HIDE_TIP_OF_VACATION @"hide_tip_of_vacation"
#define KEY_FOR_HIDE_TIP_OF_SETTINGS @"hide_tip_of_settings"

// 定义App是否加载过的标志Key
#define KEY_FOR_APP_HAS_LAUNCHED_ONCE @"AppHasLaunchedOnce"

// 定义NSDefaults里面用于保存上次浏览房屋houseId的Key, tId的key
#define KEY_FOR_HOUSE_ID_LAST_VIEWED @"house_id_last_viewed"
#define KEY_FOR_TID_LAST_VIEWED @"thermostat_id_last_viewed"

// 定义默认无效颜色为空
#define DEFAULT_VOID_COLOR [UIColor clearColor]

// 定义绘制Schedule上圆环扇形梯形的一些常量信息
// 此处ALPHA = 2*M_PI/48 , 是一个sector的弧度
#define ALPHA 0.13089969
#define NUM_SECTOR 48
// 定义sector view的高度是宽度的几倍
#define SECTOR_ASPECT_RATIO 3.2 // original: 3
// Weekly 面板的DoughnutView的边长
#define WEEKLY_DOUGHNUT_VIEW_SIZE 270.0f  // original : 240.0f   changed @ 2014-2-25
// Next24Hrs 面板的DoughnutView的边长
#define NEXT24HRS_DOUGHNUT_VIEW_SIZE 290.0f  // original : 260.0f   changed @ 2014-2-24
// Weekly 面板上mode picker view 的宽度和高度
#define MODE_PICKER_VIEW_WIDTH 205
#define MODE_PICKER_VIEW_HEIGHT 35
////定义Schedule模块中每个子模块的id编号
//typedef enum {SCHEDULE_PANEL_TODAY, SCHEDULE_PANEL_WEEKLY, SCHEDULE_PANEL_NEXT24HRS} SCHEDULE_PANEL_TYPE;     
// 定义Schedule模块中每个子模块的id编号,用于指定当前图形是为Today模块的还是Weekly模块的。
typedef enum
{
    SCHEDULE_TYPE_TODAY,
    SCHEDULE_TYPE_NEXT24HRS,
    SCHEDULE_TYPE_WEEKLY,
    SCHEDULE_TYPE_VACATION
} ScheduleType;

//定义双击延迟。大于此延迟的算做两次单击，否则算双击
#define DOUBLE_TAP_DELAY 0.35



// 定义heating和cooling setpoint之间允许的最小差距，单位是华氏度，整数
#define MINIMUM_HEATING_COOLING_GAP 2

// 定义Thermostat Dashboard 的 hold状态
// hold 对应 MyEDashboardData.isOvrried  分别对应0(Run), 1(Permanent Hold), 2(Temporary Hold)。
typedef enum
{
    HOLD_TYPE_RUN,
    HOLD_TYPE_PERMANENT,
    HOLD_TYPE_TEMPORARY
} HoldType;


// 定义Schedule模块中mode所能使用的16中颜色
#define MODE_COLOR0 0xc12e08
#define MODE_COLOR1 0xf93907
#define MODE_COLOR2 0xfa6748
#define MODE_COLOR3 0xff8d7a
#define MODE_COLOR4 0xb38710
#define MODE_COLOR5 0xd6b32a
#define MODE_COLOR6 0xf2cf45
#define MODE_COLOR7 0xf9e655
#define MODE_COLOR8 0x0065a2
#define MODE_COLOR9 0x0082c0
#define MODE_COLOR10 0x5598cb
#define MODE_COLOR11 0x8db9e5
#define MODE_COLOR12 0x7e1676
#define MODE_COLOR13 0xb028a5
#define MODE_COLOR14 0xc468bd
#define MODE_COLOR15 0xdd99d8

typedef struct hsv_color {
    float hue;
    float sat;
    float val;
    float alpha;
} MyEHSVColorStruct;
typedef struct rgb_color {
    float r;
    float g;
    float b;
    float alpha;
} MyERGBColorStruct;


// 创建位图 Graphics Context的一个例程
CGContextRef MyECreateBitmapContext (int pixelsWide,
                                    int pixelsHigh);
CGPoint midpointBetweenPoints(CGPoint a, CGPoint b);

float distanceBetweenPoints(CGPoint a, CGPoint b);

NSInteger getDaysBetweenDates(NSDate *startDate, NSDate *endDate);


@interface MyEUtil : NSObject
//如何根据HEX字符串创建UIColor, hex字符串必须必须是“0xffffff”这样的格式
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

// 如何根据HEX值创建UIColor, hex值必须是8位16进制整数，最后两位是alpha
+ (UIColor *) colorWithHexInteger8:(NSInteger)hexInteger;
// 如何根据HEX值创建UIColor, hex值必须是6位16进制整数，不包括alpha
+ (UIColor *) colorWithHexInteger6:(NSInteger)hexInteger;

// 根据HEX值创建各颜色分量，并返回float数组， hex值必须是8位16进制整数。 usage:  CGContextSetStrokeColor(c, HexToFloats(0x808080ff));
+ (MyERGBColorStruct) HexToFloats:(int) hexInteger;

// 获取UIColor的RGBA值
+ (MyERGBColorStruct) componetsWithUIColor:(UIColor *)uicolor;

// 获取UIColor的16进制字符串，不包含alpha值，输出形式为@"0xffffff"
+ (NSString *) hexStringWithUIColor:(UIColor *)uicolor;

// 获取UIColor的16进制数字，不包含alpha值，输出形式为0xffffff
+ (int) hexIntegerWithUIColor:(UIColor *)uicolor;

// 创建16个样本颜色的UIColor对象构成的数组，这些样本颜色是不变的，用于Schedule的mode的颜色
+ (NSArray *) sampleColorArrayForScheduleMode;

// 根据颜色取得其在Scheudle模块中mode所使用颜色的样本颜色数组的序号，返回-1表示没找到
+ (NSInteger) colorIndexInSampleColorArrayForColor:(UIColor *)color;


// 根据Ajax 的json 字符串，进行解析，取得其中result 字段的取值
+ (NSInteger)getResultFromAjaxString:(NSString *)jsonString;

// Toast mothod
//@see http://stackoverflow.com/questions/18680891/displaying-a-message-in-ios-which-have-the-same-functionality-as-toast-in-androi
+(void)showThingsSuccessOn:(UIView *)view WithMessage:(NSString *)message;
+ (void)showToastOn:(UIView *)view withMessage:(NSString *)message backgroundColor:(UIColor *)bgColor;
+ (void)showToastOn:(UIView *)view withMessage:(NSString *)message;
+ (void)showErrorOn:(UIView *)view withMessage:(NSString *)message;
+ (void)showSuccessOn:(UIView *)view withMessage:(NSString *)message;
+ (void)showMessageOn:(UIView *)view withMessage:(NSString *)message;
+(void)showInstructionStatusWithYes:(BOOL)yes andView:(UIView *)view andMessage:(NSString *)message;
// given half hour id (0 - 48), return the time string in 24 hour format
+ (NSString *)timeStringForHhid:(NSInteger)hhid;
//将传入的字符串改变成数字，从而利于比较
+ (NSInteger)hhidForTimeString:(NSString *)string;
+ (void)getFrameDetail:(UIView *)view andName:(NSString *)name;
@end

