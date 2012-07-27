//
//  MyEDoughnutView.h
//  MyE
//
//  Created by Ye Yuan on 2/7/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MyEUtil.h"


@class MyESectorView;



// 用于指定当前用户手指按在某个sector上，下来的触摸操作类型是涂抹、拖动时段边界还是不允许操作。
typedef enum {
    SectorTouchTypePainting, //当前选中了一个mode，允许用户用这个mode涂抹所有手指划过的sector
    SectorTouchTypeDraggingBorder,//当前按在一个边界sector，允许手指拖动边界移动时段的开始结束边界时间
    SectorTouchTypeDisable   //当前条件不允许任何触摸操作
} SectorTouchType;

@protocol MyEDoughnutViewDelegate;

@interface MyEDoughnutView : UIView <UIGestureRecognizerDelegate>
{
    NSMutableArray *_sectorViews;
    NSMutableArray *_timeArrowViews;
    
    // 每次用户手指按下一个sector，或选中一个Mode后，标记当前允许的触摸操作类型是涂抹、拖动时段边界还是不允许操作。
    SectorTouchType _sectorTouchType; 
    //记录每次触摸sector view时，手指触摸并进行涂色过的最后一个sector的id，取值：0~47，如果取值为-1，表示当前没有在触摸
    int _lastSectorViewIdTouched;

    //仅用于触摸开始、运动、结束时，记录是否用户通过触摸doughnut view上的sector修改了shcedule
    BOOL _isScheduleChanged;
    
    // ------------下面的变量其实是为了本Doughnut类能够应用于Today模块的情形。---------------
    ScheduleType _scheduleType;// 用于指定当前图形是为Today模块的还是Weekly模块的。
    NSInteger _sectorIdSpaningCurrentTime;//指定刚好跨越当前时刻的sector，如果时刻刚好在整半点处，那么就取下一个sector的id

    // ------------------------------------------------------------------------------
    
    
    UITapGestureRecognizer *_singleTapRecognizer;// 单击姿势识别器
    UITapGestureRecognizer *_doubleTapRecognizer;// 单击姿势识别器
}

@property (retain, nonatomic) id <MyEDoughnutViewDelegate> delegate;

// 模式数组，保持48个sector的模式，对于Weekly和Today面板，分别由它们负责生成此数组并传递进来
@property (retain, nonatomic) NSMutableArray *modeIdArray;// 每个半点对应一个modeId，一共48个

@property (nonatomic)NSInteger sectorIdSpaningCurrentTime;

// 这是一个48个元素的数组，每个元素是一个字符串，对应于一个sector，表示是该sector所在period的hold字符。
// 该字符串如果为none，表示没有hold，否则就表示hold了。
@property (retain, nonatomic) NSArray *holdArray;//hold字符串数组，每个时段对应一个hold字符串

@property (nonatomic) BOOL isRemoteControl;

// 每次用户手指按下一个sector，或选中一个Mode后，标记当前允许的触摸操作类型是涂抹、拖动时段边界还是不允许操作。
@property (nonatomic) SectorTouchType sectorTouchType;

// 主要是用于Next24Hrs面板，用于表明0点所在的sector的index，取值范围是0~48，对于today面板和weekly面板，这个值的取值始终是0
@property (nonatomic) NSInteger zeroHourSectorId;


- (id)initWithFrame:(CGRect)frame  delegate:(id <MyEDoughnutViewDelegate>)delegate;

- (void)createViewsWithModeArray:(NSArray *)modeIdArray scheduleType:(NSInteger)type;
- (void)updateWithModeIdArray:(NSArray *)modeIdArray;
- (void)updateSectorViewAtIndex:(int)index modeId:(NSInteger)modeId;
- (void)updateSectorViewFrom:(int)fromIndex to:(int)toIndex modeId:(NSInteger)modeId;


// 下面函数可以考虑放到MyESectorViewDelegate中，以后如果有时间可以考虑再修改
//下面几个函数是某个MyESectorView被触摸时调用的函数，其中的sectorId是tap事件第一次触摸的MyESectorView对象。而touchLocation已经被转换到了本View的坐标空间
- (void)handleTouchBeganAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId;
- (void)handleTouchMovedAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId;
- (void)handleTouchEndedAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId;
- (void)handleTouchCanceledAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId;

// 当Tap并拖动SectorView后，在view上绘制一个拖动的矩形块，类似鼠标拖曳效果，测试用
-(void)manageTouches:(NSSet*)touches;
-(void)dragView:(UIView*)aView withPoint:(CGPoint)point;
-(void)touchMoveWithPoint:(CGPoint)touchPos;
@end



@protocol MyEDoughnutViewDelegate <NSObject>
@required
// 当前选择的模式的id。用于用户手触摸修改sector，或者编辑这个mode。这个值和容器类MyEWeeklyScheduleSubviewController、MyETodayScheduleController中的成员变量相同
@property (nonatomic) NSInteger currentSelectedModeId; 
@property (nonatomic) BOOL isRemoteControl;//表示是否允许远程控制

/** 每当用户手指触摸修改了若干sector的模式，用户手指抬起来后，就向delegate发送这个消息。
 * 如果用户真正修改了schedule，那么传来的参数modeIdArray里面就是最新的schedule数据，
 * 如果用户仅仅是触摸了一下，并没修改schedule，那么传来的参数modeIdArray就是nil，此时，
 * 此函数需要做的就是:self.currentSelectedModeId = -1, 把设置当前默认没有选中任何模式。
 * 下面这个函数就根据用户改变的48个sector的modeId，重构一个时段数组，构成当天的dayItem
 */
- (void)didSchecduleChangeWithModeIdArray:(NSArray *)modeIdArray;
- (UIColor *)currentModeColor;// 获取当前选择的mode(for weekly)、当前选择的secotr(for today)的颜色的
- (UIColor *)colorForModeId:(NSInteger)modeId; // 给定modeId，获取它对应的颜色

@optional
// 当用户单击一个Secotr时，表示要显示heating/cooling数据，把这个sector的序号传递回去
- (void)didSingleTapSectorIndex:(NSUInteger)sectorInedx;
// 当用户双击一个Secotr时，表示要修改这个sector所在period的heating/cooling或颜色，把这个sector的序号传递回去
- (void)didDoubleTapSectorIndex:(NSUInteger)sectorInedx;
@end