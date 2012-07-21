//
//  MyETodayPeriodEditingView.h
//  MyE
//
//  Created by Ye Yuan on 3/12/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyETodayPeriodEditingViewDelegate;

@interface MyETodayPeriodEditingView : UIView <UIPickerViewDelegate,UIPickerViewDataSource>{
    id <MyETodayPeriodEditingViewDelegate> delegate;
    NSInteger _periodIndex;//当前正在编辑的period的index
    NSInteger _cooling;
    NSInteger _heating;

    UIPickerView *_setpointPickerView;
    
    UIButton *_doneButton;
}
@property (nonatomic, retain) id <MyETodayPeriodEditingViewDelegate> delegate;
@property  (nonatomic, retain)UIButton *doneButton;
@property (nonatomic) NSInteger periodIndex;

- (void) setHeatingCooling:(NSInteger)heating cooling:(NSInteger)cooling;

@end

/*
 Protocol for the MyETodayPeriodEditingView's delegate.
 */
@protocol MyETodayPeriodEditingViewDelegate <NSObject>
@required
- (void) didFinishEditingPeriodIndex:(NSInteger)periodIndex cooling:(float)cooling heating:(float)heating;
@end

