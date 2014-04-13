//
//  MyEWeeklyModeEditingView.h
//  MyE
//
//  Created by Ye Yuan on 3/5/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEThumbColorView.h"
@protocol MyEWeeklyModeEditingViewDelegate;

typedef enum {
   ModeEditingViewTypeEditing, ModeEditingViewTypeNew, ModeEditingViewTypeCancel
} ModeEditingViewType;

@interface MyEWeeklyModeEditingView : UIView <UIScrollViewDelegate,MyEThumbColorViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate>
{
    id <MyEWeeklyModeEditingViewDelegate> delegate;
    NSInteger _modeId;//当前正在编辑的mode的id
    NSString *_modeName;
    NSInteger _cooling;
    NSInteger _heating;
    UIColor *_modeColor;
    NSArray *_sampleColorArray;
    
    UIScrollView *thumbScrollView;
    NSTimer *autoscrollTimer;  // Timer used for auto-scrolling.
    float autoscrollDistance;  // Distance to scroll the thumb view when auto-scroll timer fires.
    
    UITextField *_nameTextField;
    ModeEditingViewType _typeOfEditing;
    UIPickerView *_setpointPickerView;
    
    UIButton *_delButton;
    UIButton *_doneButton;
    
    UIView *_bottomView;//下部放置各个组件的view。本身这个view是个全屏的透明view，用于接受手指触摸后可以隐藏。
}
@property (nonatomic, retain) id <MyEWeeklyModeEditingViewDelegate> delegate;
@property (strong, nonatomic) UIButton *delButton;
// 有可能在编辑mode name的时候，键盘弹出，但这时候再次点击了父容器的编辑按钮，就需要把编辑面板隐藏，但键盘不隐藏，就需要调用下面nameTextField的resingFirstResponder来隐藏键盘，
@property (nonatomic, retain)UITextField *nameTextField;

@property (nonatomic) NSInteger cooling;
@property (nonatomic) NSInteger heating;
@property (nonatomic, retain) UIColor *modeColor;
@property (nonatomic) NSInteger modeId;
@property (nonatomic, retain) NSString *modeName;
@property (nonatomic) ModeEditingViewType typeOfEditing;

- (void) setRemoteControlEnabled:(BOOL)isEnabled;

@end

/*
 Protocol for the MyEModeEditingView's delegate.
 */
@protocol MyEWeeklyModeEditingViewDelegate <NSObject>
@required
@property (nonatomic) BOOL isRemoteControl;//表示是否允许远程控制
- (BOOL) isModeNameInUse:(NSString *)name exceptCurrentModeId:(NSInteger)modeId;
- (BOOL) isModeColorInUse:(UIColor *)color exceptCurrentModeId:(NSInteger)modeId;
- (void) didFinishModeEditingType:(ModeEditingViewType)editingType modeId:(NSInteger)modeId modeName:(NSString *)modeName color:(UIColor *)color cooling:(float)cooling heating:(float)heating;
- (void) didFinishDeletingModeId:(NSInteger)modeId;

@end
