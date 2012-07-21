//
//  MyEModePickerView.h
//  MyE
//
//  Created by Ye Yuan on 3/8/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEThumbModeView.h"
@class MyEScheduleWeeklyData;

@protocol MyEModePickerViewDelegate;

@interface MyEModePickerView : UIView <UIScrollViewDelegate,MyEThumbModeViewDelegate>
{
    id <MyEModePickerViewDelegate> _delegate;
    UIScrollView *thumbScrollView;
    NSTimer *autoscrollTimer;  // Timer used for auto-scrolling.
    float autoscrollDistance;  // Distance to scroll the thumb view when auto-scroll timer fires.
    MyEThumbModeView *_currentSelectedThumbModeView;
}
@property (nonatomic, retain) id <MyEModePickerViewDelegate> delegate;
@property (nonatomic, strong)MyEThumbModeView *currentSelectedThumbModeView;//当全选择的thumb mode view，如果当前没有选择任何一个thumb mode view，此值取nil

- (id) initWithFrame:(CGRect)frame delegate:(id<MyEModePickerViewDelegate>)delegate;
- (void)createOrUpdateThumbScrollViewIfNecessary;
@end

/*
 Protocol for the MyEMyEModePickerView's delegate.
 */
@protocol MyEModePickerViewDelegate <NSObject>

@required

@property (retain, nonatomic) MyEScheduleWeeklyData *weeklyModel;
- (void)modePickerView:(MyEModePickerView *)modePickerView didSelectModeId:(NSInteger)modeId;
- (void)modePickerView:(MyEModePickerView *)modePickerView didDoubleTapModeId:(NSInteger)modeId;
@end