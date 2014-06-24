//
//  MyEWeeklyDaySelectionView.h
//  MyE
//
//  Created by Ye Yuan on 6/24/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyECheckBoxView;
@protocol MyEApplyToDaysSelectionViewDelegate;
@interface MyEWeeklyDaySelectionView : UIView
{
    id <MyEApplyToDaysSelectionViewDelegate> delegate;
   
    NSMutableArray *_dayCheckboxViews;
    
    UIView *_bottomView;//下部放置各个组件的view。本身这个view是个全屏的透明view，用于接受手指触摸后可以隐藏。
    
    MyECheckBoxView *_sundayCB;
    MyECheckBoxView *_mondayCB;
    MyECheckBoxView *_tuesdayCB;
    MyECheckBoxView *_wednesdayCB;
    MyECheckBoxView *_thursdayCB;
    MyECheckBoxView *_fridayCB;
    MyECheckBoxView *_saturdayCB;
    
    NSInteger _currentWeekdayIndex;//取值对应关系是：0-Sun， 1-Mon, ..., 6-Sat
}
@property (nonatomic, retain) id <MyEApplyToDaysSelectionViewDelegate> delegate;
@property (nonatomic) NSInteger currentWeekdayIndex;
@end

/*
 Protocol for the MyEModeEditingView's delegate.
 */
@protocol MyEApplyToDaysSelectionViewDelegate <NSObject>
#warning 这里这个代理得使用
@optional
@property (nonatomic)NSUInteger currentWeekdayId;//当前正在编辑的day的id, 取值对应关系是：0-Sun， 1-Mon, ..., 6-Sat
- (void) didFinishSelectApplyToDays:(NSArray *)days;

@end
